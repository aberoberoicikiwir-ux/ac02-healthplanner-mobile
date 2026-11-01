const pool = require('../config/db');

// Banyak tabel (daily_logs, workout_plans, dst) pakai client_id, bukan
// user_id langsung. Helper ini nyari client_id dari user yang lagi login.
async function getClientIdByUserId(userId) {
  const [rows] = await pool.query(
    `SELECT client_id FROM client_profiles WHERE user_id = ?`,
    [userId]
  );
  return rows.length ? rows[0].client_id : null;
}

module.exports = { getClientIdByUserId };
