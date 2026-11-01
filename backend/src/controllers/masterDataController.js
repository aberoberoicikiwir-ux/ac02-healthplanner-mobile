const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

// GET /api/exercises
const listExercises = asyncHandler(async (req, res) => {
  const [rows] = await pool.query(`SELECT * FROM exercise_reference ORDER BY name`);
  res.json(rows);
});

// GET /api/foods
const listFoods = asyncHandler(async (req, res) => {
  const [rows] = await pool.query(`SELECT * FROM food_reference ORDER BY name`);
  res.json(rows);
});

module.exports = { listExercises, listFoods };
