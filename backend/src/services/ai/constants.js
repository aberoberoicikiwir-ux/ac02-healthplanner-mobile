'use strict';

// Aturan dan batas rencana mingguan. Dipakai bersama oleh prompt (supaya AI tahu
// batasnya) dan validator (supaya batas itu benar-benar ditegakkan). Satu sumber
// kebenaran, jadi prompt dan validator tidak bisa saling bertentangan.

const DAYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
const MEAL_TYPES = ['breakfast', 'lunch', 'dinner', 'snack'];
const REQUIRED_MEALS = ['breakfast', 'lunch', 'dinner']; // wajib ada setiap hari

// Kategori latihan berbasis durasi: reps = durasi dalam MENIT, sets selalu 1.
const TIMED_CATEGORIES = ['cardio', 'flexibility'];

const LIMITS = {
  feedbackLen: [20, 600],
  steps: [1000, 30000],
  waterLiters: [0.5, 6],
  caloriesMax: 4500,
  // Batas bawah kalori harian yang umum dipakai sebagai batas aman.
  minCalories: { female: 1200, male: 1500, default: 1500 },
  maxWorkoutItems: 28,
  maxWorkoutItemsPerDay: 4,
  maxWorkoutDays: 6, // minimal 1 hari istirahat
  maxMealItems: 84,
  maxFoodsPerSlot: 4,
  strength: { sets: [1, 6], reps: [1, 30] },
  timedMinutes: [5, 90],
  calorieDeviationWarn: 0.4, // peringatan jika kalori harian menyimpang >40% dari target
};

module.exports = { DAYS, MEAL_TYPES, REQUIRED_MEALS, TIMED_CATEGORIES, LIMITS };
