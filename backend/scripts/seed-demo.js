'use strict';

// DATA DEMO untuk pengembangan Mobile/Web.
//
// Membuat (atau membuat ulang) 2 akun demo beserta isinya, supaya aplikasi punya data nyata
// untuk dirender sebelum alur "PT menyetujui rencana AI -> muncul di klien" selesai dibuat:
//   klien : klien_demo / demo12345   (profil lengkap, plan & target minggu ini, log 7 hari, notifikasi)
//   PT    : pt_demo    / demo12345   (membimbing klien_demo; ada rencana AI yang menunggu review)
//
// Syarat : schema dan healthmaxxing_seed.sql (data master) sudah dimuat.
// Pakai  : npm run seed:demo        (aman diulang; akun demo dihapus lalu dibuat ulang)
// JANGAN dijalankan di database produksi: password demo diketahui publik.

require('dotenv').config();
const bcrypt = require('bcryptjs');
const pool = require('../src/config/db');
const { generateWeeklyPlan } = require('../src/services/ai/planner');
const mock = require('../src/services/ai/llm/mock');
const { DAY_MS, toISO, todayUTC, mondayOfWeek, nextMonday } = require('../src/utils/dates');

const PASSWORD = 'demo12345';

async function main() {
  if (process.env.NODE_ENV === 'production') {
    throw new Error('Menolak dijalankan saat NODE_ENV=production (akun demo berpassword publik).');
  }

  const [exercises] = await pool.query('SELECT exercise_id, category FROM exercise_reference ORDER BY exercise_id');
  const [foods] = await pool.query('SELECT food_id FROM food_reference ORDER BY food_id');
  const strength = exercises.filter((e) => e.category === 'strength');
  const cardio = exercises.filter((e) => e.category === 'cardio');
  if (strength.length < 3 || cardio.length < 1 || foods.length < 6) {
    throw new Error('Data master kosong/kurang. Jalankan dulu: mysql -u root < healthmaxxing_seed.sql');
  }

  // Hapus akun demo lama (profil, plan, log, notifikasi ikut terhapus lewat ON DELETE CASCADE).
  await pool.query(`DELETE FROM users WHERE username IN ('pt_demo', 'klien_demo')`);

  const hash = await bcrypt.hash(PASSWORD, 10);
  const [pt] = await pool.query(
    `INSERT INTO users (name, email, username, password_hash, role) VALUES ('PT Demo', 'pt_demo@demo.local', 'pt_demo', ?, 'pt')`,
    [hash]
  );
  const [kl] = await pool.query(
    `INSERT INTO users (name, email, username, password_hash, role) VALUES ('Klien Demo', 'klien_demo@demo.local', 'klien_demo', ?, 'klien')`,
    [hash]
  );
  const ptId = pt.insertId;
  const klienUserId = kl.insertId;

  const [cp] = await pool.query(
    `INSERT INTO client_profiles
       (user_id, assigned_pt_id, birth_date, gender, height_cm, weight_current, weight_target, allergies, activity_level)
     VALUES (?, ?, '2000-05-10', 'female', 160.5, 65, 58, 'kacang', 'moderate')`,
    [klienUserId, ptId]
  );
  const clientId = cp.insertId;

  const today = todayUTC();
  const monday = toISO(mondayOfWeek(today));

  // Target minggu ini
  await pool.query(
    `INSERT INTO targets (client_id, week_start_date, target_steps, target_water_liters, target_calories, source)
     VALUES (?, ?, 8000, 2.0, 1800, 'manual')`,
    [clientId, monday]
  );

  // Workout plan minggu ini (disetujui). Satu item sudah dicentang.
  const [wp] = await pool.query(`INSERT INTO workout_plans (client_id, week_start_date, status) VALUES (?, ?, 'approved')`, [clientId, monday]);
  const workout = [
    [strength[0].exercise_id, 'mon', 3, 10, true],
    [strength[1].exercise_id, 'mon', 3, 12, false],
    [cardio[0].exercise_id, 'wed', 1, 20, false], // cardio: reps = durasi menit
    [strength[2].exercise_id, 'fri', 3, 10, false],
  ];
  for (const [ex, day, sets, reps, done] of workout) {
    await pool.query(
      `INSERT INTO workout_plan_items (plan_id, exercise_id, day_of_week, \`sets\`, reps, is_completed) VALUES (?, ?, ?, ?, ?, ?)`,
      [wp.insertId, ex, day, sets, reps, done]
    );
  }

  // Meal plan minggu ini (disetujui). Catatan: skema saat ini belum punya kolom hari untuk menu.
  const [mp] = await pool.query(`INSERT INTO meal_plans (client_id, week_start_date, status) VALUES (?, ?, 'approved')`, [clientId, monday]);
  const meals = [
    ['breakfast', 0, true], ['breakfast', 1, false],
    ['lunch', 2, false], ['lunch', 3, false],
    ['dinner', 4, false], ['dinner', 5, false],
  ];
  for (const [type, i, done] of meals) {
    await pool.query(`INSERT INTO meal_plan_items (plan_id, food_id, meal_type, is_completed) VALUES (?, ?, ?, ?)`, [
      mp.insertId, foods[i].food_id, type, done,
    ]);
  }

  // Log 7 hari terakhir (hari ini = 6 hari setelah awal rentang)
  const steps = [6200, 7400, 8100, 5600, 9000, 7800, 4300];
  const water = [1.5, 1.8, 2.0, 1.2, 2.2, 1.9, 0.8];
  const weight = [65.4, 65.3, 65.3, 65.1, 65.0, 64.9, 64.8];
  for (let i = 0; i < 7; i++) {
    await pool.query(
      `INSERT INTO daily_logs (client_id, log_date, weight_kg, steps, water_liters, calories_burned) VALUES (?, ?, ?, ?, ?, ?)`,
      [clientId, toISO(today - (6 - i) * DAY_MS), weight[i], steps[i], water[i], Math.round(steps[i] * 0.04)]
    );
  }

  await pool.query(
    `INSERT INTO notifications (user_id, type, title, message) VALUES
       (?, 'ai_insight', 'Langkahmu meningkat', 'Rata-rata langkahmu minggu ini naik dibanding minggu lalu. Pertahankan!'),
       (?, 'reminder', 'Waktunya minum air', 'Targetmu hari ini 2 liter. Baru tercapai sebagian.')`,
    [klienUserId, klienUserId]
  );

  // Rencana AI (tiruan) untuk minggu depan, menunggu review PT. Ikut membuat notifikasi untuk PT.
  let aiNote = 'rencana AI pending dibuat untuk minggu ' + nextMonday();
  try {
    await generateWeeklyPlan({ db: pool, clientId, weekStart: nextMonday(), llm: mock });
  } catch (e) {
    aiNote = `GAGAL membuat rencana AI demo: ${e.message}`;
  }

  console.log('Data demo siap.\n');
  console.log(`  klien : klien_demo / ${PASSWORD}   (user_id ${klienUserId}, client_id ${clientId})`);
  console.log(`  PT    : pt_demo    / ${PASSWORD}   (user_id ${ptId})`);
  console.log(`  minggu ini mulai ${monday}: 4 latihan, 6 menu, target 8000 langkah, log 7 hari`);
  console.log(`  ${aiNote}`);
}

main()
  .catch((e) => {
    console.error('Gagal:', e.message);
    process.exitCode = 1;
  })
  .finally(() => pool.end());
