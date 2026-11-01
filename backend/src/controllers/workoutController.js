const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { getClientIdByUserId } = require('../utils/clientHelper');

// GET /api/clients/me/workout-plans/current
const getCurrentWorkoutPlan = asyncHandler(async (req, res) => {
  const clientId = await getClientIdByUserId(req.user.user_id);
  if (!clientId) return res.status(404).json({ message: 'Profil klien belum ada.' });

  const [plans] = await pool.query(
    `SELECT * FROM workout_plans
     WHERE client_id = ?
     ORDER BY week_start_date DESC LIMIT 1`,
    [clientId]
  );

  if (plans.length === 0) {
    return res.status(404).json({ message: 'Belum ada workout plan.' });
  }

  const plan = plans[0];
  const [items] = await pool.query(
    `SELECT wpi.item_id, wpi.day_of_week, wpi.sets, wpi.reps, wpi.is_completed,
            er.exercise_id, er.name AS exercise_name, er.category, er.calories_per_unit
     FROM workout_plan_items wpi
     JOIN exercise_reference er ON er.exercise_id = wpi.exercise_id
     WHERE wpi.plan_id = ?`,
    [plan.plan_id]
  );

  res.json({ ...plan, items });
});

// PATCH /api/workout-plan-items/:itemId
const updateWorkoutItem = asyncHandler(async (req, res) => {
  const { itemId } = req.params;
  const { is_completed } = req.body;

  if (typeof is_completed !== 'boolean') {
    return res.status(400).json({ message: 'is_completed harus true/false.' });
  }

  const clientId = await getClientIdByUserId(req.user.user_id);
  if (!clientId) return res.status(404).json({ message: 'Profil klien belum ada.' });

  // JOIN ke workout_plans memastikan item ini milik klien yang sedang login.
  // Tanpa ini, klien A bisa mengubah checklist klien B hanya dengan mengganti ID.
  const [result] = await pool.query(
    `UPDATE workout_plan_items wpi
     JOIN workout_plans wp ON wp.plan_id = wpi.plan_id
     SET wpi.is_completed = ?
     WHERE wpi.item_id = ? AND wp.client_id = ?`,
    [is_completed, itemId, clientId]
  );

  if (result.affectedRows === 0) {
    return res.status(404).json({ message: 'Item latihan tidak ditemukan.' });
  }

  res.json({ message: 'Checklist latihan berhasil diupdate.' });
});

module.exports = { getCurrentWorkoutPlan, updateWorkoutItem };
