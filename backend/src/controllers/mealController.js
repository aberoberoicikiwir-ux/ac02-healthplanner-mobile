const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { getClientIdByUserId } = require('../utils/clientHelper');

// GET /api/clients/me/meal-plans/current
const getCurrentMealPlan = asyncHandler(async (req, res) => {
  const clientId = await getClientIdByUserId(req.user.user_id);
  if (!clientId) return res.status(404).json({ message: 'Profil klien belum ada.' });

  const [plans] = await pool.query(
    `SELECT * FROM meal_plans
     WHERE client_id = ?
     ORDER BY week_start_date DESC LIMIT 1`,
    [clientId]
  );

  if (plans.length === 0) {
    return res.status(404).json({ message: 'Belum ada meal plan.' });
  }

  const plan = plans[0];
  const [items] = await pool.query(
    `SELECT mpi.item_id, mpi.meal_type, mpi.is_completed,
            fr.food_id, fr.name AS food_name, fr.calories, fr.protein_g, fr.carbs_g, fr.fat_g
     FROM meal_plan_items mpi
     JOIN food_reference fr ON fr.food_id = mpi.food_id
     WHERE mpi.plan_id = ?`,
    [plan.plan_id]
  );

  res.json({ ...plan, items });
});

// PATCH /api/meal-plan-items/:itemId
const updateMealItem = asyncHandler(async (req, res) => {
  const { itemId } = req.params;
  const { is_completed } = req.body;

  if (typeof is_completed !== 'boolean') {
    return res.status(400).json({ message: 'is_completed harus true/false.' });
  }

  const clientId = await getClientIdByUserId(req.user.user_id);
  if (!clientId) return res.status(404).json({ message: 'Profil klien belum ada.' });

  const [result] = await pool.query(
    `UPDATE meal_plan_items mpi
     JOIN meal_plans mp ON mp.plan_id = mpi.plan_id
     SET mpi.is_completed = ?
     WHERE mpi.item_id = ? AND mp.client_id = ?`,
    [is_completed, itemId, clientId]
  );

  if (result.affectedRows === 0) {
    return res.status(404).json({ message: 'Item makanan tidak ditemukan.' });
  }

  res.json({ message: 'Checklist makanan berhasil diupdate.' });
});

module.exports = { getCurrentMealPlan, updateMealItem };
