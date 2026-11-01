const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

// GET /api/users/me/notifications
const getMyNotifications = asyncHandler(async (req, res) => {
  const [rows] = await pool.query(
    `SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC`,
    [req.user.user_id]
  );
  res.json(rows);
});

// PATCH /api/notifications/:id/read
const markNotificationRead = asyncHandler(async (req, res) => {
  const { id } = req.params;
  await pool.query(
    `UPDATE notifications SET is_read = TRUE WHERE notification_id = ? AND user_id = ?`,
    [id, req.user.user_id]
  );
  res.json({ message: 'Notifikasi ditandai sudah dibaca.' });
});

module.exports = { getMyNotifications, markNotificationRead };
