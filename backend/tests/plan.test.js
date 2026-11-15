'use strict';
// Tes penerapan rencana (approve/override -> tabel klien). Jalankan:  npm run test:plan
// TIDAK butuh database: memakai koneksi palsu yang merekam semua query. Yang diuji adalah LOGIKA
// (validasi ulang, transaksi, isi baris yang ditulis, penolakan). Kebenaran SQL terhadap MySQL
// sungguhan diuji oleh test_all.sh bagian 11.

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');

const { DAYS } = require('../src/services/ai/constants');
const AiError = require('../src/services/ai/AiError');
const { reviewAnalysis } = require('../src/services/planMaterializer');

// ---------------------------------------------------------------- fixtures
const EXERCISES = [
  { exercise_id: 1, name: 'Push up', category: 'strength' },
  { exercise_id: 2, name: 'Squat', category: 'strength' },
  { exercise_id: 3, name: 'Jalan cepat', category: 'cardio' },
  { exercise_id: 4, name: 'Yoga dasar', category: 'flexibility' },
];
const FOODS = [
  { food_id: 1, name: 'Nasi putih', calories: 200, protein_g: 4, carbs_g: 44, fat_g: 0.4 },
  { food_id: 2, name: 'Dada ayam rebus', calories: 165, protein_g: 31, carbs_g: 0, fat_g: 3.6 },
  { food_id: 3, name: 'Kacang tanah rebus', calories: 100, protein_g: 4, carbs_g: 3, fat_g: 8 },
  { food_id: 4, name: 'Apel', calories: 95, protein_g: 0.5, carbs_g: 25, fat_g: 0.3 },
];
const CLIENT = {
  client_id: 7, user_id: 70, assigned_pt_id: 5, status: 'active', gender: 'female',
  height_cm: 160, weight_current: 65, weight_target: 58, allergies: null,
  activity_level: 'moderate', birth_date: '2000-05-10', name: 'Klien Uji',
};
const WEEK = '2026-11-09';

function goodPlan() {
  const meals = [];
  for (const day of DAYS) {
    for (const meal_type of ['breakfast', 'lunch', 'dinner']) {
      meals.push({ day, meal_type, food_id: 1 }, { day, meal_type, food_id: 2 }, { day, meal_type, food_id: 4 });
    }
  }
  return {
    feedback: 'Semangat! Pertahankan langkah harianmu minggu ini ya.',
    targets: { steps: 8000, water_liters: 2, calories: 1800 },
    workout: [
      { day: 'mon', exercise_id: 1, sets: 3, reps: 10 },
      { day: 'mon', exercise_id: 3, sets: 1, reps: 20 },
      { day: 'wed', exercise_id: 2, sets: 3, reps: 12 },
    ],
    meals,
  };
}

// Koneksi palsu: merekam query, meniru jawaban yang dibutuhkan, dan mencatat commit/rollback.
function makeDb({ analysis, client = CLIENT, existingWorkout = false, existingMeal = false, failOn = null } = {}) {
  const log = [];
  const state = { began: false, committed: false, rolledBack: false, released: false };
  const conn = {
    async beginTransaction() { state.began = true; },
    async commit() { state.committed = true; },
    async rollback() { state.rolledBack = true; },
    release() { state.released = true; },
    async query(sql, params) {
      const q = sql.replace(/\s+/g, ' ').trim();
      log.push({ q, params });
      if (failOn && q.startsWith(failOn)) throw new Error('simulasi kegagalan database');
      if (q.includes('FROM ai_analysis_results WHERE analysis_id = ? FOR UPDATE')) return [analysis ? [analysis] : []];
      if (q.includes('FROM client_profiles cp')) return [client ? [client] : []];
      if (q.includes('FROM exercise_reference')) return [EXERCISES];
      if (q.includes('FROM food_reference')) return [FOODS];
      if (q.includes('FROM daily_logs')) return [[]];
      if (q.includes('FROM targets WHERE')) return [[]];
      if (q.includes('COALESCE(SUM')) return [[{ done: 0, total: 0 }]];
      if (q.includes('SELECT plan_id FROM workout_plans WHERE client_id = ? AND week_start_date = ?')) return [existingWorkout ? [{ plan_id: 1 }] : []];
      if (q.includes('SELECT plan_id FROM meal_plans WHERE client_id = ? AND week_start_date = ?')) return [existingMeal ? [{ plan_id: 2 }] : []];
      if (q.startsWith('INSERT INTO workout_plans (')) return [{ insertId: 100 }];
      if (q.startsWith('INSERT INTO meal_plans (')) return [{ insertId: 200 }];
      return [{ affectedRows: 1 }];
    },
  };
  return { db: { getConnection: async () => conn }, log, state };
}

const pending = (over = {}) => ({
  analysis_id: 1, client_id: 7, status: 'pending', week_start: WEEK,
  ai_output: { ...goodPlan(), meta: { provider: 'mock' } }, ...over,
});
const find = (log, startsWith) => log.find((e) => e.q.startsWith(startsWith));
const writes = (log) => log.filter((e) => e.q.startsWith('INSERT') || e.q.startsWith('UPDATE'));

async function rejectsWith(promise, status) {
  await assert.rejects(promise, (e) => {
    assert.ok(e instanceof AiError, `seharusnya AiError, dapat: ${e && e.constructor && e.constructor.name}: ${e && e.message}`);
    assert.equal(e.status, status);
    return true;
  });
}

// ---------------------------------------------------------------- tes
describe('reviewAnalysis: approve', () => {
  it('menulis workout, meal (dengan hari), target, notifikasi, audit dalam satu transaksi', async () => {
    const m = makeDb({ analysis: pending() });
    const r = await reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'approve' });

    assert.deepEqual([m.state.began, m.state.committed, m.state.rolledBack, m.state.released], [true, true, false, true]);
    assert.equal(r.status, 'approved');
    assert.equal(r.workout_plan_id, 100);
    assert.equal(r.meal_plan_id, 200);
    assert.equal(r.week_start_date, WEEK);

    assert.deepEqual(find(m.log, 'INSERT INTO workout_plans (').params, [7, WEEK, 'approved']);
    assert.deepEqual(find(m.log, 'INSERT INTO workout_plan_items').params[0], [
      [100, 1, 'mon', 3, 10],
      [100, 3, 'mon', 1, 20],
      [100, 2, 'wed', 3, 12],
    ]);

    const mealRows = find(m.log, 'INSERT INTO meal_plan_items').params[0];
    assert.equal(mealRows.length, 7 * 3 * 3);
    assert.deepEqual(mealRows[0], [200, 1, 'breakfast', 'mon']);
    assert.ok(mealRows.every((row) => row[0] === 200 && DAYS.includes(row[3])), 'semua baris menu punya hari');

    assert.deepEqual(find(m.log, 'INSERT INTO targets').params, [7, WEEK, 8000, 2, 1800, 'ai']);

    const upd = find(m.log, 'UPDATE ai_analysis_results');
    assert.match(upd.q, /status = 'approved', final_output = ai_output/);
    assert.deepEqual(upd.params, [5, 1]);

    const notif = find(m.log, 'INSERT INTO notifications');
    assert.equal(notif.params[0], 70, 'notifikasi untuk user klien, bukan PT');
    assert.equal(notif.params[1], goodPlan().feedback);

    const audit = find(m.log, 'INSERT INTO audit_logs');
    assert.equal(audit.params[0], 5);
    assert.equal(audit.params[1], 'plan.approved');
    assert.equal(JSON.parse(audit.params[3]).workout_plan_id, 100);
  });

  it('ai_output berupa teks (MariaDB mengembalikan kolom JSON sebagai string) tetap diterima', async () => {
    const m = makeDb({ analysis: pending({ ai_output: JSON.stringify(goodPlan()) }) });
    const r = await reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'approve' });
    assert.equal(r.status, 'approved');
    assert.equal(m.state.committed, true);
  });

  it('rencana lama yang bukan format AI ditolak 422, tidak ada yang ditulis, rollback', async () => {
    const m = makeDb({ analysis: pending({ ai_output: { summary: 'rencana A' } }) });
    await rejectsWith(reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'approve' }), 422);
    assert.equal(writes(m.log).length, 0, 'tidak boleh ada INSERT/UPDATE');
    assert.deepEqual([m.state.committed, m.state.rolledBack, m.state.released], [false, true, true]);
  });

  it('klien mengubah alergi setelah rencana dibuat -> approve ditolak 422 (validasi ulang)', async () => {
    const plan = goodPlan();
    plan.meals.push({ day: 'mon', meal_type: 'breakfast', food_id: 3 }); // "Kacang tanah rebus"
    const m = makeDb({ analysis: pending({ ai_output: plan }), client: { ...CLIENT, allergies: 'kacang' } });
    await assert.rejects(
      reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'approve' }),
      (e) => e instanceof AiError && e.status === 422 && e.details.some((d) => /alergen/i.test(d))
    );
    assert.equal(writes(m.log).length, 0);
  });

  it('analisis tidak ada -> 404', async () => {
    const m = makeDb({ analysis: null });
    await rejectsWith(reviewAnalysis({ db: m.db, analysisId: 99, ptUserId: 5, decision: 'approve' }), 404);
    assert.equal(m.state.rolledBack, true);
  });

  it('sudah ditinjau (approved/overridden) -> 409, tidak ada yang ditulis', async () => {
    for (const status of ['approved', 'overridden']) {
      const m = makeDb({ analysis: pending({ status }) });
      await rejectsWith(reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'approve' }), 409);
      assert.equal(writes(m.log).length, 0);
      assert.equal(m.state.rolledBack, true);
    }
  });

  it('klien sudah punya workout plan ATAU meal plan minggu itu -> 409, tidak menimpa', async () => {
    for (const opt of [{ existingWorkout: true }, { existingMeal: true }]) {
      const m = makeDb({ analysis: pending(), ...opt });
      await rejectsWith(reviewAnalysis({ db: m.db, analysis: null, analysisId: 1, ptUserId: 5, decision: 'approve' }), 409);
      assert.equal(writes(m.log).length, 0);
    }
  });

  it('kegagalan database di tengah jalan -> rollback, koneksi dilepas, error asli diteruskan', async () => {
    const m = makeDb({ analysis: pending(), failOn: 'INSERT INTO meal_plans (' });
    await assert.rejects(
      reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'approve' }),
      (e) => !(e instanceof AiError) && /simulasi kegagalan/.test(e.message)
    );
    assert.deepEqual([m.state.committed, m.state.rolledBack, m.state.released], [false, true, true]);
  });
});

describe('reviewAnalysis: override', () => {
  it('override valid: status overridden, target source manual, final_output = rencana PT + meta', async () => {
    const edited = goodPlan();
    edited.targets.steps = 5000;
    edited.feedback = 'Klien cedera lutut, kurangi beban latihan kaki.';
    const m = makeDb({ analysis: pending() });
    const r = await reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'override', finalOutput: edited });

    assert.equal(r.status, 'overridden');
    assert.equal(find(m.log, 'INSERT INTO workout_plans (').params[2], 'overridden');
    assert.deepEqual(find(m.log, 'INSERT INTO targets').params, [7, WEEK, 5000, 2, 1800, 'manual']);

    const upd = find(m.log, 'UPDATE ai_analysis_results');
    assert.match(upd.q, /status = 'overridden'/);
    const stored = JSON.parse(upd.params[0]);
    assert.equal(stored.targets.steps, 5000, 'yang disimpan adalah hasil edit PT, bukan ai_output');
    assert.equal(stored.meta.overridden_by_pt, true);
    assert.equal(stored.meta.provider, 'mock', 'meta asal tetap dibawa');

    assert.equal(find(m.log, 'INSERT INTO notifications').params[1], edited.feedback);
    assert.equal(find(m.log, 'INSERT INTO audit_logs').params[1], 'plan.overridden');
  });

  it('override dengan JSON tidak valid ditolak 422 (PT mengedit manual -> wajib divalidasi)', async () => {
    const bad = [
      { feedback: 'terlalu pendek' },                                              // bukan rencana lengkap
      { ...goodPlan(), workout: [{ day: 'mon', exercise_id: 999, sets: 3, reps: 10 }] }, // latihan tidak ada
      { ...goodPlan(), targets: { steps: 5, water_liters: 2, calories: 1800 } },   // di luar batas
    ];
    for (const finalOutput of bad) {
      const m = makeDb({ analysis: pending() });
      await rejectsWith(reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'override', finalOutput }), 422);
      assert.equal(writes(m.log).length, 0);
      assert.equal(m.state.rolledBack, true);
    }
  });

  it('override tanpa finalOutput (bukan objek) -> 422', async () => {
    for (const finalOutput of [undefined, null, 'teks', ['array']]) {
      const m = makeDb({ analysis: pending() });
      await rejectsWith(reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'override', finalOutput }), 422);
    }
  });

  it('override pada analisis yang sudah ditinjau -> 409', async () => {
    const m = makeDb({ analysis: pending({ status: 'approved' }) });
    await rejectsWith(reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'override', finalOutput: goodPlan() }), 409);
  });
});

describe('reviewAnalysis: argumen', () => {
  it('decision tidak dikenal -> error (bug pemanggil, bukan input pengguna)', async () => {
    const m = makeDb({ analysis: pending() });
    await assert.rejects(reviewAnalysis({ db: m.db, analysisId: 1, ptUserId: 5, decision: 'hapus' }), /decision tidak dikenal/);
  });
});
