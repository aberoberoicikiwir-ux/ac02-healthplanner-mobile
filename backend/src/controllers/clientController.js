const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { getClientIdByUserId } = require('../utils/clientHelper');
const { profileErrors, dailyLogErrors } = require('../utils/validate');

// GET /api/clients/me/profile
const getMyProfile = asyncHandler(async (req, res) => {
  const [rows] = await pool.query(
    `SELECT * FROM client_profiles WHERE user_id = ?`,
    [req.user.user_id]
  );

  if (rows.length === 0) {
    return res.status(404).json({ message: 'Profil belum diisi.' });
  }
  res.json(rows[0]);
});

// POST /api/clients/me/profile  (isi pertama kali saat data kosong)
const createMyProfile = asyncHandler(async (req, res) => {
  const { birth_date, gender, height_cm, weight_current, weight_target, allergies, activity_level } = req.body;

  const invalid = profileErrors(req.body, { requireWeights: true });
  if (invalid) return res.status(400).json({ message: invalid });

  const [existing] = await pool.query(
    `SELECT client_id FROM client_profiles WHERE user_id = ?`,
    [req.user.user_id]
  );
  if (existing.length > 0) {
    return res.status(409).json({ message: 'Profil sudah pernah diisi. Gunakan PATCH untuk update.' });
  }

  const [result] = await pool.query(
    `INSERT INTO client_profiles
      (user_id, birth_date, gender, height_cm, weight_current, weight_target, allergies, activity_level)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [req.user.user_id, birth_date, gender, height_cm, weight_current, weight_target, allergies, activity_level]
  );

  res.status(201).json({ message: 'Profil berhasil dibuat.', client_id: result.insertId });
});

// PATCH /api/clients/me/profile
const updateMyProfile = asyncHandler(async (req, res) => {
  const allowedFields = [
    'birth_date', 'gender', 'height_cm', 'weight_current',
    'weight_target', 'allergies', 'activity_level',
  ];

  const updates = Object.keys(req.body).filter((key) => allowedFields.includes(key));
  if (updates.length === 0) {
    return res.status(400).json({ message: 'Tidak ada field valid untuk diupdate.' });
  }

  const invalid = profileErrors(req.body, { requireWeights: false });
  if (invalid) return res.status(400).json({ message: invalid });

  const setClause = updates.map((field) => `${field} = ?`).join(', ');
  const values = updates.map((field) => req.body[field]);

  await pool.query(
    `UPDATE client_profiles SET ${setClause} WHERE user_id = ?`,
    [...values, req.user.user_id]
  );

  res.json({ message: 'Profil berhasil diupdate.' });
});

// GET /api/clients/me/targets/current
const getCurrentTargets = asyncHandler(async (req, res) => {
  const clientId = await getClientIdByUserId(req.user.user_id);
  if (!clientId) return res.status(404).json({ message: 'Profil klien belum ada.' });

  const [rows] = await pool.query(
    `SELECT * FROM targets WHERE client_id = ? ORDER BY week_start_date DESC LIMIT 1`,
    [clientId]
  );
  res.json(rows[0] || null);
});

// GET /api/clients/me/daily-logs/today
const getTodayLog = asyncHandler(async (req, res) => {
  const clientId = await getClientIdByUserId(req.user.user_id);
  if (!clientId) return res.status(404).json({ message: 'Profil klien belum ada.' });

  const [rows] = await pool.query(
    `SELECT * FROM daily_logs WHERE client_id = ? AND log_date = CURDATE()`,
    [clientId]
  );
  res.json(rows[0] || null);
});

// PUT /api/clients/me/daily-logs/today  (sync steps/air/berat hari ini)
const upsertTodayLog = asyncHandler(async (req, res) => {
  const clientId = await getClientIdByUserId(req.user.user_id);
  if (!clientId) return res.status(404).json({ message: 'Profil klien belum ada.' });

  const { steps, water_liters, weight_kg, calories_burned } = req.body;

  const invalid = dailyLogErrors(req.body);
  if (invalid) return res.status(400).json({ message: invalid });

  // Field yang tidak dikirim jadi NULL, lalu COALESCE menjaga nilai lama.
  // Jadi sync parsial (mis. pedometer cuma kirim steps) TIDAK menimpa air/berat
  // yang sudah dicatat hari itu. INSERT ... ON DUPLICATE KEY UPDATE memanfaatkan
  // UNIQUE KEY (client_id, log_date) dari schema, jadi otomatis "upsert".
  const v = [steps, water_liters, weight_kg, calories_burned].map((x) => (x === undefined ? null : x));
  await pool.query(
    `INSERT INTO daily_logs (client_id, log_date, steps, water_liters, weight_kg, calories_burned)
     VALUES (?, CURDATE(), COALESCE(?, 0), COALESCE(?, 0), ?, COALESCE(?, 0))
     ON DUPLICATE KEY UPDATE
       steps = COALESCE(?, steps),
       water_liters = COALESCE(?, water_liters),
       weight_kg = COALESCE(?, weight_kg),
       calories_burned = COALESCE(?, calories_burned)`,
    [clientId, ...v, ...v]
  );

  res.json({ message: 'Log harian berhasil disinkronkan.' });
});

// GET /api/clients/me/daily-logs?from=&to=
const getLogsRange = asyncHandler(async (req, res) => {
  const clientId = await getClientIdByUserId(req.user.user_id);
  if (!clientId) return res.status(404).json({ message: 'Profil klien belum ada.' });

  const { from, to } = req.query;
  const [rows] = await pool.query(
    `SELECT * FROM daily_logs
     WHERE client_id = ? AND log_date BETWEEN ? AND ?
     ORDER BY log_date ASC`,
    [clientId, from || '1970-01-01', to || '2999-12-31']
  );
  res.json(rows);
});

// POST /api/clients/me/pt  { pt_username }
// Klien memilih PT-nya sendiri. Tanpa ini assigned_pt_id tidak pernah terisi,
// sehingga dashboard PT tidak punya klien untuk ditampilkan.
const assignMyPt = asyncHandler(async (req, res) => {
  const { pt_username } = req.body;
  if (!pt_username || typeof pt_username !== 'string') {
    return res.status(400).json({ message: 'pt_username wajib diisi.' });
  }

  const clientId = await getClientIdByUserId(req.user.user_id);
  if (!clientId) return res.status(404).json({ message: 'Isi profil kesehatan dulu.' });

  const [pts] = await pool.query(
    `SELECT user_id, name FROM users WHERE username = ? AND role = 'pt'`,
    [pt_username]
  );
  if (pts.length === 0) {
    return res.status(404).json({ message: 'PT dengan username itu tidak ditemukan.' });
  }

  await pool.query(
    `UPDATE client_profiles SET assigned_pt_id = ? WHERE client_id = ?`,
    [pts[0].user_id, clientId]
  );
  res.json({ message: 'PT berhasil dipilih.', pt: { user_id: pts[0].user_id, name: pts[0].name } });
});

module.exports = {
  assignMyPt,
  getMyProfile,
  createMyProfile,
  updateMyProfile,
  getCurrentTargets,
  getTodayLog,
  upsertTodayLog,
  getLogsRange,
};
