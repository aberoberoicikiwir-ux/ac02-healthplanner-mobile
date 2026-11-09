'use strict';

// Penyedia AI TIRUAN untuk pengembangan dan tes. Ia membaca blok <DATA> dari prompt
// (sehingga ikut menguji bahwa prompt memuat data yang benar) dan menyusun rencana
// sederhana berbasis aturan. Hasilnya SELALU diberi label mock; ini bukan AI sungguhan
// dan kualitas menunya sekadar contoh struktur.

const { TIMED_CATEGORIES, LIMITS } = require('../constants');

const name = 'mock';
const model = 'mock-v1';

const ACTIVITY = {
  sedentary: { factor: 1.2, days: ['mon', 'thu'], steps: 6000 },
  light: { factor: 1.375, days: ['mon', 'wed', 'fri'], steps: 7000 },
  moderate: { factor: 1.55, days: ['mon', 'tue', 'thu', 'fri'], steps: 8000 },
  active: { factor: 1.725, days: ['mon', 'tue', 'wed', 'fri', 'sat'], steps: 9000 },
  very_active: { factor: 1.9, days: ['mon', 'tue', 'wed', 'fri', 'sat'], steps: 10000 },
};
const WEEK = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

function parseData(user) {
  const m = user.match(/<DATA>\s*([\s\S]*?)\s*<\/DATA>/);
  if (!m) throw new Error('mock: blok <DATA> tidak ditemukan di prompt');
  return JSON.parse(m[1]);
}

function pick(list, i) {
  return list[((i % list.length) + list.length) % list.length];
}

async function generate({ user }) {
  const data = parseData(user);
  const c = data.client;
  const act = ACTIVITY[c.activity_level] || ACTIVITY.light;

  // Kalori: Mifflin-St Jeor x faktor aktivitas, lalu sesuaikan arah berat badan.
  const weight = c.weight_current_kg || 65;
  const bmr = 10 * weight + 6.25 * (c.height_cm || 165) - 5 * (c.age ?? 30) + (c.gender === 'male' ? 5 : -161);
  let cal = bmr * act.factor;
  if (c.weight_target_kg != null && c.weight_target_kg < weight) cal -= 400;
  else if (c.weight_target_kg != null && c.weight_target_kg > weight) cal += 300;
  const minCal = LIMITS.minCalories[c.gender] ?? LIMITS.minCalories.default;
  cal = Math.min(LIMITS.caloriesMax, Math.max(minCal, Math.round(cal / 50) * 50));
  const water = Math.min(LIMITS.waterLiters[1], Math.max(1.5, Math.round(weight * 0.033 * 2) / 2));

  // Latihan
  const timed = data.exercises.filter((e) => TIMED_CATEGORIES.includes(String(e.category).toLowerCase()));
  const strength = data.exercises.filter((e) => !TIMED_CATEGORIES.includes(String(e.category).toLowerCase()));
  const light = c.activity_level === 'sedentary';
  const workout = [];
  act.days.forEach((day, k) => {
    const chosen = new Set();
    if (strength.length) {
      chosen.add(pick(strength, k * 2).id);
      chosen.add(pick(strength, k * 2 + 1).id);
      for (const id of chosen) workout.push({ day, exercise_id: id, sets: light ? 2 : 3, reps: light ? 8 : 10 });
    }
    if (timed.length) {
      const t = pick(timed, k);
      workout.push({ day, exercise_id: t.id, sets: 1, reps: 20 });
    }
  });

  // Makanan: lewati yang namanya memuat kata kunci alergi.
  const safe = data.foods.filter((f) => !c.allergy_keywords.some((t) => f.name.toLowerCase().includes(t)));
  if (!safe.length) throw new Error('mock: tidak ada makanan yang aman untuk klien ini');
  const meals = [];
  WEEK.forEach((day, d) => {
    ['breakfast', 'lunch', 'dinner'].forEach((meal_type, s) => {
      const ids = new Set();
      for (let j = 0; j < 3; j++) ids.add(pick(safe, d * 9 + s * 3 + j).id);
      for (const food_id of ids) meals.push({ day, meal_type, food_id });
    });
  });

  const plan = {
    feedback:
      `[Mode MOCK, bukan AI sungguhan] Rencana contoh: target ${act.steps} langkah, ${water} liter air, ` +
      `dan ${cal} kkal per hari, dengan ${act.days.length} hari latihan. ` +
      'Untuk kondisi kesehatan khusus, tetap konsultasikan dengan tenaga kesehatan.',
    targets: { steps: act.steps, water_liters: water, calories: cal },
    workout,
    meals,
  };
  return JSON.stringify(plan);
}

module.exports = { name, model, generate };
