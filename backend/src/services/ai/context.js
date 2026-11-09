'use strict';

const { allergyTerms } = require('./allergies');

// Batas jumlah baris master data yang dikirim ke AI (menjaga ukuran prompt).
const MAX_MASTER_ROWS = 200;

const num = (v) => (v === null || v === undefined ? null : Number(v));

async function loadClient(db, clientId) {
  const [rows] = await db.query(
    `SELECT cp.client_id, cp.user_id, cp.assigned_pt_id, cp.status, cp.gender,
            cp.height_cm, cp.weight_current, cp.weight_target, cp.allergies, cp.activity_level,
            DATE_FORMAT(cp.birth_date, '%Y-%m-%d') AS birth_date, u.name
     FROM client_profiles cp
     JOIN users u ON u.user_id = cp.user_id
     WHERE cp.client_id = ?`,
    [clientId]
  );
  return rows[0] || null;
}

function ageOn(birthISO, refISO) {
  if (!birthISO) return null;
  const [by, bm, bd] = birthISO.split('-').map(Number);
  const [ry, rm, rd] = refISO.split('-').map(Number);
  let age = ry - by;
  if (rm < bm || (rm === bm && rd < bd)) age -= 1;
  return age >= 0 ? age : null;
}

async function adherence(db, table, itemTable, clientId, weekStart) {
  const [[r]] = await db.query(
    `SELECT COALESCE(SUM(i.is_completed), 0) AS done, COUNT(*) AS total
     FROM ${itemTable} i
     WHERE i.plan_id = (
       SELECT plan_id FROM ${table}
       WHERE client_id = ? AND week_start_date < ?
       ORDER BY week_start_date DESC LIMIT 1)`,
    [clientId, weekStart]
  );
  return Number(r.total) > 0 ? { completed: Number(r.done), total: Number(r.total) } : null;
}

// Menyusun data untuk prompt. PRIVASI: hanya data yang dibutuhkan untuk menyusun
// rencana. Tidak ada nama, email, username, atau ID pengguna/klien yang dikirim
// ke penyedia AI. Usia dihitung dari tanggal lahir (tanggal lahir tidak dikirim).
async function buildContext(db, client, weekStart) {
  const [exRows] = await db.query(
    'SELECT exercise_id, name, category FROM exercise_reference ORDER BY exercise_id LIMIT ?',
    [MAX_MASTER_ROWS]
  );
  const [foodRows] = await db.query(
    'SELECT food_id, name, calories, protein_g, carbs_g, fat_g FROM food_reference ORDER BY food_id LIMIT ?',
    [MAX_MASTER_ROWS]
  );
  const [logs] = await db.query(
    `SELECT DATE_FORMAT(log_date, '%Y-%m-%d') AS date, weight_kg, steps, water_liters
     FROM daily_logs
     WHERE client_id = ? AND log_date < ? AND log_date >= DATE_SUB(?, INTERVAL 14 DAY)
     ORDER BY log_date`,
    [client.client_id, weekStart, weekStart]
  );
  const [prevTargets] = await db.query(
    `SELECT target_steps, target_water_liters, target_calories
     FROM targets WHERE client_id = ? AND week_start_date < ?
     ORDER BY week_start_date DESC LIMIT 1`,
    [client.client_id, weekStart]
  );

  const terms = allergyTerms(client.allergies);

  const data = {
    client: {
      age: ageOn(client.birth_date, weekStart),
      gender: client.gender || null,
      height_cm: num(client.height_cm),
      weight_current_kg: num(client.weight_current),
      weight_target_kg: num(client.weight_target),
      activity_level: client.activity_level || null,
      allergy_keywords: terms,
    },
    recent_logs: logs.map((l) => ({
      date: l.date,
      weight_kg: num(l.weight_kg),
      steps: Number(l.steps),
      water_liters: num(l.water_liters),
    })),
    last_week_adherence: {
      workout: await adherence(db, 'workout_plans', 'workout_plan_items', client.client_id, weekStart),
      meals: await adherence(db, 'meal_plans', 'meal_plan_items', client.client_id, weekStart),
    },
    previous_targets: prevTargets[0]
      ? {
          steps: Number(prevTargets[0].target_steps),
          water_liters: num(prevTargets[0].target_water_liters),
          calories: Number(prevTargets[0].target_calories),
        }
      : null,
    exercises: exRows.map((e) => ({ id: e.exercise_id, name: e.name, category: e.category })),
    foods: foodRows.map((f) => ({
      id: f.food_id,
      name: f.name,
      kcal: num(f.calories),
      protein_g: num(f.protein_g),
      carbs_g: num(f.carbs_g),
      fat_g: num(f.fat_g),
    })),
  };

  const validation = {
    exercises: new Map(exRows.map((e) => [e.exercise_id, { name: e.name, category: e.category }])),
    foods: new Map(foodRows.map((f) => [f.food_id, { name: f.name, kcal: num(f.calories) || 0 }])),
    allergyTerms: terms,
    gender: client.gender || null,
  };

  return { data, validation };
}

module.exports = { loadClient, buildContext, ageOn };
