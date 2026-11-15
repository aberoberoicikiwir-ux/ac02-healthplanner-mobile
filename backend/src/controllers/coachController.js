const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { getLlm } = require('../services/ai/llm');
const {
  getCoachHistory,
  askCoach,
  clearCoachHistory,
} = require('../services/ai/coach');

// GET /api/clients/me/ai-coach/messages?limit=20
const getMyCoachMessages = asyncHandler(async (req, res) => {
  const rows = await getCoachHistory({
    db: pool,
    userId: req.user.user_id,
    limit: req.query.limit,
  });
  res.json(rows);
});

// POST /api/clients/me/ai-coach/messages
const postMyCoachMessage = asyncHandler(async (req, res) => {
  const result = await askCoach({
    db: pool,
    userId: req.user.user_id,
    message: req.body?.message,
    llm: getLlm(),
  });
  res.status(201).json(result);
});

// DELETE /api/clients/me/ai-coach/messages
const deleteMyCoachMessages = asyncHandler(async (req, res) => {
  const { deleted } = await clearCoachHistory({
    db: pool,
    userId: req.user.user_id,
  });
  res.json({ message: 'Riwayat chat dihapus.', deleted });
});

module.exports = {
  getMyCoachMessages,
  postMyCoachMessage,
  deleteMyCoachMessages,
};
