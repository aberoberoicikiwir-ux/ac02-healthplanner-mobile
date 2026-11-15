'use strict';

// Meninjau satu rencana AI (approve / override) dan MENERAPKANNYA ke tabel yang dibaca klien.
//
// Sebelumnya approve/override hanya mengubah status di ai_analysis_results, sehingga klien tidak
// pernah menerima rencana. Sekarang, dalam SATU transaksi (semua berhasil atau tidak sama sekali):
//   1. kunci baris analisis (FOR UPDATE) -> dua PT/klik tidak bisa memprosesnya bersamaan
//   2. pastikan masih 'pending'
//   3. VALIDASI ULANG rencana (untuk override: JSON hasil edit manual PT; untuk approve: pertahanan
//      berlapis, mis. klien mengubah alergi setelah rencana dibuat)
//   4. tulis workout_plans + items, meal_plans + items (dengan hari), targets, notifikasi, audit log
//   5. tandai analisis approved/overridden

const AiError = require('./ai/AiError');
const { loadClient, buildContext } = require('./ai/context');
const { validatePlan } = require('./ai/validatePlan');

const parseJson = (v) => {
  if (v === null || v === undefined) return null;
  if (typeof v !== 'string') return v; // MySQL: mysql2 sudah mengurai kolom JSON
  try {
    return JSON.parse(v); // MariaDB: kolom JSON dikembalikan sebagai teks
  } catch {
    return null;
  }
};

const isObj = (v) => v !== null && typeof v === 'object' && !Array.isArray(v);

/**
 * @param {object} p
 * @param {object} p.db           pool mysql2 (punya getConnection())
 * @param {number} p.analysisId
 * @param {number} p.ptUserId     user_id PT yang meninjau
 * @param {'approve'|'override'} p.decision
 * @param {object} [p.finalOutput] wajib untuk 'override'
 * @returns {Promise<{analysis_id, status, week_start_date, workout_plan_id, meal_plan_id, workout_items, meal_items, warnings}>}
 * @throws {AiError} 404 (tidak ada), 409 (sudah ditinjau / minggu itu sudah punya plan), 422 (rencana tidak valid)
 */
async function reviewAnalysis({ db, analysisId, ptUserId, decision, finalOutput }) {
  if (decision !== 'approve' && decision !== 'override') {
    throw new Error(`decision tidak dikenal: ${decision}`);
  }

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    const [rows] = await conn.query(
      `SELECT analysis_id, client_id, ai_output, status,
              DATE_FORMAT(week_start_date, '%Y-%m-%d') AS week_start
       FROM ai_analysis_results WHERE analysis_id = ? FOR UPDATE`,
      [analysisId]
    );
    if (rows.length === 0) throw new AiError(404, 'Analisis tidak ditemukan.');
    const analysis = rows[0];

    if (analysis.status !== 'pending') {
      throw new AiError(409, `Analisis ini sudah berstatus "${analysis.status}" dan tidak bisa ditinjau lagi.`);
    }

    const aiOutput = parseJson(analysis.ai_output);
    const rawPlan = decision === 'override' ? finalOutput : aiOutput;
    if (!isObj(rawPlan)) {
      throw new AiError(422, 'Rencana tidak ada atau bukan objek JSON, jadi tidak bisa diterapkan.');
    }

    const client = await loadClient(conn, analysis.client_id);
    if (!client) throw new AiError(404, 'Klien tidak ditemukan.');

    const { validation } = await buildContext(conn, client, analysis.week_start);
    const check = validatePlan(rawPlan, validation);
    if (!check.ok) {
      throw new AiError(422, 'Rencana tidak lolos validasi, jadi tidak diterapkan ke klien.', check.errors);
    }
    const plan = check.plan;

    // Jangan menimpa rencana yang sudah ada (progres checklist klien bisa hilang).
    const [wExisting] = await conn.query(
      'SELECT plan_id FROM workout_plans WHERE client_id = ? AND week_start_date = ? LIMIT 1',
      [analysis.client_id, analysis.week_start]
    );
    const [mExisting] = await conn.query(
      'SELECT plan_id FROM meal_plans WHERE client_id = ? AND week_start_date = ? LIMIT 1',
      [analysis.client_id, analysis.week_start]
    );
    if (wExisting.length > 0 || mExisting.length > 0) {
      throw new AiError(409, `Klien sudah punya workout/meal plan untuk minggu ${analysis.week_start}.`);
    }

    const planStatus = decision === 'override' ? 'overridden' : 'approved';

    // ---- workout ----
    const [w] = await conn.query(
      'INSERT INTO workout_plans (client_id, week_start_date, status) VALUES (?, ?, ?)',
      [analysis.client_id, analysis.week_start, planStatus]
    );
    await conn.query(
      'INSERT INTO workout_plan_items (plan_id, exercise_id, day_of_week, `sets`, reps) VALUES ?',
      [plan.workout.map((i) => [w.insertId, i.exercise_id, i.day, i.sets, i.reps])]
    );

    // ---- meals (dengan hari) ----
    const [m] = await conn.query(
      'INSERT INTO meal_plans (client_id, week_start_date, status) VALUES (?, ?, ?)',
      [analysis.client_id, analysis.week_start, planStatus]
    );
    await conn.query('INSERT INTO meal_plan_items (plan_id, food_id, meal_type, day_of_week) VALUES ?', [
      plan.meals.map((i) => [m.insertId, i.food_id, i.meal_type, i.day]),
    ]);

    // ---- target mingguan (sudah ada untuk minggu itu -> diperbarui) ----
    await conn.query(
      `INSERT INTO targets (client_id, week_start_date, target_steps, target_water_liters, target_calories, source)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE target_steps = VALUES(target_steps),
                               target_water_liters = VALUES(target_water_liters),
                               target_calories = VALUES(target_calories),
                               source = VALUES(source)`,
      [
        analysis.client_id,
        analysis.week_start,
        plan.targets.steps,
        plan.targets.water_liters,
        plan.targets.calories,
        decision === 'override' ? 'manual' : 'ai',
      ]
    );

    // ---- tandai analisis ----
    if (decision === 'approve') {
      await conn.query(
        `UPDATE ai_analysis_results
         SET status = 'approved', final_output = ai_output, reviewed_by_pt_id = ?, reviewed_at = NOW()
         WHERE analysis_id = ?`,
        [ptUserId, analysisId]
      );
    } else {
      const baseMeta = isObj(aiOutput) && isObj(aiOutput.meta) ? aiOutput.meta : {};
      const stored = { ...plan, meta: { ...baseMeta, overridden_by_pt: true } };
      await conn.query(
        `UPDATE ai_analysis_results
         SET status = 'overridden', final_output = ?, reviewed_by_pt_id = ?, reviewed_at = NOW()
         WHERE analysis_id = ?`,
        [JSON.stringify(stored), ptUserId, analysisId]
      );
    }

    // ---- notifikasi untuk klien (insight AI / catatan PT) ----
    await conn.query(
      `INSERT INTO notifications (user_id, type, title, message)
       VALUES (?, 'ai_insight', 'Rencana mingguan baru siap', ?)`,
      [client.user_id, plan.feedback]
    );

    // ---- audit log ----
    await conn.query(
      `INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details, severity)
       VALUES (?, ?, 'ai_analysis_results', ?, ?, 'info')`,
      [
        ptUserId,
        decision === 'override' ? 'plan.overridden' : 'plan.approved',
        analysisId,
        JSON.stringify({
          client_id: analysis.client_id,
          week_start_date: analysis.week_start,
          workout_plan_id: w.insertId,
          meal_plan_id: m.insertId,
          warnings: check.warnings.length,
        }),
      ]
    );

    await conn.commit();

    return {
      analysis_id: analysisId,
      status: planStatus,
      week_start_date: analysis.week_start,
      workout_plan_id: w.insertId,
      meal_plan_id: m.insertId,
      workout_items: plan.workout.length,
      meal_items: plan.meals.length,
      warnings: check.warnings,
    };
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
}

module.exports = { reviewAnalysis };
