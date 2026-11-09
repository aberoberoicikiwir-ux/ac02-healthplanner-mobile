'use strict';

const { DAYS, MEAL_TYPES, REQUIRED_MEALS, TIMED_CATEGORIES, LIMITS } = require('./constants');
const { findAllergenHits } = require('./allergies');

// Pertahanan utama terhadap hallucination dan output yang tidak aman:
// keluaran AI TIDAK dipercaya. Semua yang akan disimpan harus lolos pemeriksaan
// di sini, dan yang disimpan adalah hasil normalisasi (field tak dikenal dibuang),
// bukan teks mentah dari model.
//
// ctx = {
//   exercises: Map<id, {name, category}>,
//   foods:     Map<id, {name, kcal}>,
//   allergyTerms: string[],
//   gender: 'male' | 'female' | null,
// }
// Hasil: { ok, errors[], warnings[], plan | null }
//   errors   = pelanggaran keras, rencana ditolak
//   warnings = masalah kualitas, rencana tetap diterima, PT yang menilai

const URL_RE = /(https?:\/\/|www\.)/i;
// Heuristik kasar untuk saran medis berisiko. Bukan jaminan; PT tetap pereview akhir.
const RISKY_RE = /\b(dosis|obat|resep|suplemen|diagnosis|diagnosa|suntik|steroid|detoks|puasa\s+(ekstrem|total))\b/i;
const MAX_ERRORS = 15;

const isObj = (v) => v !== null && typeof v === 'object' && !Array.isArray(v);
const inRange = (n, [lo, hi]) => n >= lo && n <= hi;
const show = (v) => String(JSON.stringify(v)).slice(0, 30);
const dayOf = (v) => (typeof v === 'string' ? v.trim().toLowerCase() : '');

function validatePlan(raw, ctx) {
  const errors = [];
  const warnings = [];
  const err = (m) => {
    if (errors.length < MAX_ERRORS) errors.push(m);
  };

  if (!isObj(raw)) {
    return { ok: false, errors: ['output harus berupa satu objek JSON'], warnings, plan: null };
  }

  // ---------- feedback ----------
  const feedback = typeof raw.feedback === 'string' ? raw.feedback.trim() : '';
  if (!inRange(feedback.length, LIMITS.feedbackLen)) {
    err(`feedback wajib berupa teks ${LIMITS.feedbackLen[0]}-${LIMITS.feedbackLen[1]} karakter`);
  } else {
    if (URL_RE.test(feedback)) err('feedback tidak boleh berisi tautan');
    if (RISKY_RE.test(feedback)) {
      err('feedback mengandung saran medis berisiko (dosis, obat, diagnosis, suplemen, puasa ekstrem)');
    }
  }

  // ---------- targets ----------
  let targets = null;
  if (!isObj(raw.targets)) {
    err('targets wajib berupa objek');
  } else {
    const { steps, water_liters: water, calories } = raw.targets;
    const minCal = LIMITS.minCalories[ctx.gender] ?? LIMITS.minCalories.default;
    if (!Number.isInteger(steps) || !inRange(steps, LIMITS.steps)) {
      err(`targets.steps harus bilangan bulat ${LIMITS.steps[0]}-${LIMITS.steps[1]}`);
    }
    if (typeof water !== 'number' || !Number.isFinite(water) || !inRange(water, LIMITS.waterLiters)) {
      err(`targets.water_liters harus angka ${LIMITS.waterLiters[0]}-${LIMITS.waterLiters[1]}`);
    }
    if (!Number.isInteger(calories) || calories < minCal || calories > LIMITS.caloriesMax) {
      err(`targets.calories harus bilangan bulat ${minCal}-${LIMITS.caloriesMax}`);
    }
    targets = {
      steps,
      water_liters: typeof water === 'number' ? Math.round(water * 10) / 10 : water,
      calories,
    };
  }

  // ---------- workout ----------
  const workout = [];
  if (!Array.isArray(raw.workout) || raw.workout.length < 1 || raw.workout.length > LIMITS.maxWorkoutItems) {
    err(`workout wajib berupa array 1-${LIMITS.maxWorkoutItems} item`);
  } else {
    const seen = new Set();
    const perDay = {};
    raw.workout.forEach((it, i) => {
      const at = `workout[${i}]`;
      if (!isObj(it)) return err(`${at} harus berupa objek`);

      const day = dayOf(it.day);
      if (!DAYS.includes(day)) err(`${at}.day harus salah satu dari ${DAYS.join(', ')}`);

      const ex = Number.isInteger(it.exercise_id) ? ctx.exercises.get(it.exercise_id) : undefined;
      if (!ex) {
        err(`${at}.exercise_id ${show(it.exercise_id)} tidak ada di daftar exercises`);
      } else if (TIMED_CATEGORIES.includes(String(ex.category).toLowerCase())) {
        // cardio / flexibility: sets=1, reps = durasi menit
        if (it.sets !== 1) err(`${at}: "${ex.name}" (kategori ${ex.category}) harus sets=1 dan reps=durasi dalam menit`);
        if (!Number.isInteger(it.reps) || !inRange(it.reps, LIMITS.timedMinutes)) {
          err(`${at}.reps (durasi menit) harus bilangan bulat ${LIMITS.timedMinutes[0]}-${LIMITS.timedMinutes[1]}`);
        }
      } else {
        if (!Number.isInteger(it.sets) || !inRange(it.sets, LIMITS.strength.sets)) {
          err(`${at}.sets harus bilangan bulat ${LIMITS.strength.sets[0]}-${LIMITS.strength.sets[1]}`);
        }
        if (!Number.isInteger(it.reps) || !inRange(it.reps, LIMITS.strength.reps)) {
          err(`${at}.reps harus bilangan bulat ${LIMITS.strength.reps[0]}-${LIMITS.strength.reps[1]}`);
        }
      }

      if (DAYS.includes(day) && ex) {
        const key = `${day}:${it.exercise_id}`;
        if (seen.has(key)) err(`${at}: latihan yang sama dua kali pada hari ${day}`);
        seen.add(key);
        perDay[day] = (perDay[day] || 0) + 1;
        workout.push({ day, exercise_id: it.exercise_id, sets: it.sets, reps: it.reps });
      }
    });

    for (const [d, n] of Object.entries(perDay)) {
      if (n > LIMITS.maxWorkoutItemsPerDay) err(`hari ${d} punya ${n} latihan (maksimal ${LIMITS.maxWorkoutItemsPerDay})`);
    }
    const days = Object.keys(perDay).length;
    if (days > LIMITS.maxWorkoutDays) err(`latihan di ${days} hari; wajib ada minimal 1 hari istirahat`);
    if (days === 1) warnings.push('latihan hanya 1 hari dalam seminggu');
  }

  // ---------- meals ----------
  const meals = [];
  if (!Array.isArray(raw.meals) || raw.meals.length < 1 || raw.meals.length > LIMITS.maxMealItems) {
    err(`meals wajib berupa array 1-${LIMITS.maxMealItems} item`);
  } else {
    const seen = new Set();
    const perSlot = {};
    raw.meals.forEach((it, i) => {
      const at = `meals[${i}]`;
      if (!isObj(it)) return err(`${at} harus berupa objek`);

      const day = dayOf(it.day);
      if (!DAYS.includes(day)) err(`${at}.day harus salah satu dari ${DAYS.join(', ')}`);
      const type = dayOf(it.meal_type);
      if (!MEAL_TYPES.includes(type)) err(`${at}.meal_type harus salah satu dari ${MEAL_TYPES.join(', ')}`);

      const food = Number.isInteger(it.food_id) ? ctx.foods.get(it.food_id) : undefined;
      if (!food) {
        err(`${at}.food_id ${show(it.food_id)} tidak ada di daftar foods`);
      } else {
        const hits = findAllergenHits(food.name, ctx.allergyTerms);
        if (hits.length) err(`${at}: "${food.name}" mengandung alergen klien (${hits.join(', ')})`);
      }

      if (DAYS.includes(day) && MEAL_TYPES.includes(type) && food) {
        const key = `${day}:${type}:${it.food_id}`;
        if (seen.has(key)) err(`${at}: makanan yang sama dua kali pada ${day}/${type}`);
        seen.add(key);
        const slot = `${day}:${type}`;
        perSlot[slot] = (perSlot[slot] || 0) + 1;
        meals.push({ day, meal_type: type, food_id: it.food_id });
      }
    });

    for (const [slot, n] of Object.entries(perSlot)) {
      if (n > LIMITS.maxFoodsPerSlot) err(`${slot.replace(':', '/')} punya ${n} makanan (maksimal ${LIMITS.maxFoodsPerSlot})`);
    }
    const missing = [];
    for (const d of DAYS) {
      for (const t of REQUIRED_MEALS) if (!perSlot[`${d}:${t}`]) missing.push(`${d}/${t}`);
    }
    if (missing.length) {
      err(`meals belum lengkap; wajib breakfast, lunch, dinner setiap hari. Kurang: ${missing.slice(0, 6).join(', ')}${missing.length > 6 ? ', ...' : ''}`);
    }
  }

  if (errors.length) return { ok: false, errors, warnings, plan: null };

  // ---------- peringatan kualitas (tidak menolak) ----------
  const kcalPerDay = {};
  for (const m of meals) kcalPerDay[m.day] = (kcalPerDay[m.day] || 0) + (ctx.foods.get(m.food_id).kcal || 0);
  for (const d of DAYS) {
    const total = kcalPerDay[d] || 0;
    if (Math.abs(total - targets.calories) / targets.calories > LIMITS.calorieDeviationWarn) {
      warnings.push(`kalori makanan hari ${d} (${total}) menyimpang lebih dari ${LIMITS.calorieDeviationWarn * 100}% dari target (${targets.calories})`);
    }
  }

  workout.sort((a, b) => DAYS.indexOf(a.day) - DAYS.indexOf(b.day) || a.exercise_id - b.exercise_id);
  meals.sort(
    (a, b) =>
      DAYS.indexOf(a.day) - DAYS.indexOf(b.day) ||
      MEAL_TYPES.indexOf(a.meal_type) - MEAL_TYPES.indexOf(b.meal_type) ||
      a.food_id - b.food_id
  );

  return { ok: true, errors, warnings, plan: { feedback, targets, workout, meals } };
}

module.exports = { validatePlan };
