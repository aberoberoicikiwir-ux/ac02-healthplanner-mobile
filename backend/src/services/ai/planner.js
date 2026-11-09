'use strict';

const AiError = require('./AiError');
const { extractJson } = require('./parse');
const { validatePlan } = require('./validatePlan');
const { buildPrompt } = require('./prompt');
const { loadClient, buildContext } = require('./context');

const maxAttempts = () => Math.max(1, Math.min(4, Number(process.env.AI_MAX_ATTEMPTS) || 2));

// Catatan observability. Kegagalan menulis log tidak boleh menggagalkan proses utama.
async function audit(db, { action, severity = 'info', entity_type = null, entity_id = null, details = null }) {
  try {
    await db.query(
      `INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details, severity)
       VALUES (NULL, ?, ?, ?, ?, ?)`,
      [action, entity_type, entity_id, details ? JSON.stringify(details) : null, severity]
    );
  } catch (e) {
    console.error('Gagal menulis audit log:', e.message);
  }
}

// Alur: ambil data klien (anonim) -> prompt -> panggil AI -> parse -> VALIDASI ->
// (jika ditolak: coba lagi dengan daftar kesalahan, sampai maxAttempts) -> simpan sebagai
// "pending" untuk direview PT. Rencana tidak pernah sampai ke klien sebelum PT approve.
async function generateWeeklyPlan({ db, clientId, weekStart, llm }) {
  const client = await loadClient(db, clientId);
  if (!client) throw new AiError(404, 'Klien tidak ditemukan.');
  if (client.status !== 'active') throw new AiError(409, 'Klien tidak aktif.');
  if (client.weight_current == null || client.weight_target == null) {
    throw new AiError(422, 'Profil klien belum lengkap (berat saat ini dan berat target wajib).');
  }

  const [existingRows] = await db.query(
    `SELECT analysis_id, status FROM ai_analysis_results
     WHERE client_id = ? AND week_start_date = ?
     ORDER BY analysis_id DESC LIMIT 1`,
    [clientId, weekStart]
  );
  const existing = existingRows[0] || null;
  if (existing && existing.status !== 'pending') {
    throw new AiError(
      409,
      `Analisis minggu ${weekStart} sudah berstatus "${existing.status}" (sudah ditinjau PT) dan tidak bisa digenerate ulang.`
    );
  }

  const { data, validation } = await buildContext(db, client, weekStart);
  if (!validation.exercises.size || !validation.foods.size) {
    throw new AiError(422, 'Data master latihan/makanan masih kosong; isi dulu (lihat healthmaxxing_seed.sql).');
  }

  const limit = maxAttempts();
  let previousErrors = null;
  let result = null;
  let attempts = 0;
  let rawExcerpt = '';

  for (let a = 1; a <= limit; a++) {
    attempts = a;
    const prompt = buildPrompt(data, weekStart, previousErrors);

    let raw;
    try {
      raw = await llm.generate(prompt);
    } catch (e) {
      await audit(db, {
        action: 'ai.generate_plan_failed',
        severity: 'error',
        entity_type: 'client_profiles',
        entity_id: clientId,
        details: { client_id: clientId, week_start_date: weekStart, provider: llm.name, attempt: a, error: e.message },
      });
      throw new AiError(502, 'Layanan AI gagal merespons.', [e.message]);
    }
    rawExcerpt = String(raw).slice(0, 500);

    let parsed;
    try {
      parsed = extractJson(raw);
    } catch (e) {
      previousErrors = [`output bukan objek JSON yang valid (${e.message})`];
      continue;
    }

    const check = validatePlan(parsed, validation);
    if (check.ok) {
      result = check;
      break;
    }
    previousErrors = check.errors;
  }

  if (!result) {
    await audit(db, {
      action: 'ai.generate_plan_rejected',
      severity: 'warning',
      entity_type: 'client_profiles',
      entity_id: clientId,
      details: {
        client_id: clientId,
        week_start_date: weekStart,
        provider: llm.name,
        attempts,
        errors: previousErrors,
        raw_excerpt: rawExcerpt,
      },
    });
    throw new AiError(502, 'AI belum menghasilkan rencana yang lolos validasi.', previousErrors);
  }

  const output = {
    ...result.plan,
    meta: {
      provider: llm.name,
      model: llm.model ?? null,
      attempts,
      generated_at: new Date().toISOString(),
      warnings: result.warnings,
      allergy_keywords: validation.allergyTerms,
    },
  };

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    let analysisId;
    let created;
    if (existing) {
      await conn.query(
        `UPDATE ai_analysis_results
         SET ai_output = ?, final_output = NULL, reviewed_by_pt_id = NULL, reviewed_at = NULL, created_at = NOW()
         WHERE analysis_id = ?`,
        [JSON.stringify(output), existing.analysis_id]
      );
      analysisId = existing.analysis_id;
      created = false;
    } else {
      const [ins] = await conn.query(
        `INSERT INTO ai_analysis_results (client_id, week_start_date, ai_output, status)
         VALUES (?, ?, ?, 'pending')`,
        [clientId, weekStart, JSON.stringify(output)]
      );
      analysisId = ins.insertId;
      created = true;
    }

    await audit(conn, {
      action: 'ai.generate_plan',
      entity_type: 'ai_analysis_results',
      entity_id: analysisId,
      details: {
        client_id: clientId,
        week_start_date: weekStart,
        provider: llm.name,
        attempts,
        warnings: result.warnings.length,
        replaced_pending: !created,
      },
    });

    if (created && client.assigned_pt_id) {
      await conn.query(
        `INSERT INTO notifications (user_id, type, title, message)
         VALUES (?, 'system', 'Rencana AI menunggu review', ?)`,
        [client.assigned_pt_id, `Rencana mingguan AI untuk ${client.name} (minggu ${weekStart}) siap ditinjau.`]
      );
    }

    await conn.commit();
    return { analysis_id: analysisId, week_start_date: weekStart, status: 'pending', created, attempts, warnings: result.warnings, plan: output };
  } catch (e) {
    await conn.rollback();
    throw e;
  } finally {
    conn.release();
  }
}

module.exports = { generateWeeklyPlan };
