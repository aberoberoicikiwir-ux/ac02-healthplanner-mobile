const asyncHandler = require('../utils/asyncHandler');
const pool = require('../config/db');
const AiError = require('../services/ai/AiError');
const { reviewAnalysis } = require('../services/planMaterializer');
const { generateForClient } = require('./aiController');
const ptModel = require('../models/ptModel');

const FORBIDDEN = { message: 'Klien/analisis ini bukan bimbinganmu.' };

// GET /api/pt/clients?status=active&page=1&limit=10&search=&sort=name&order=asc
const getMyClients = asyncHandler(async (req, res) => {
  const result = await ptModel.listClients(req.user.user_id, req.query);
  res.json(result);
});

// GET /api/pt/clients/:clientId
const getClientDetail = asyncHandler(async (req, res) => {
  const client = await ptModel.getClientDetail(
    req.user.user_id,
    req.params.clientId,
  );

  if (!client) {
    return res.status(404).json({
      message: 'Klien tidak ditemukan atau bukan bimbinganmu.',
    });
  }

  res.json(client);
});

// GET /api/pt/clients/:clientId/progress?from=&to=
const getClientProgress = asyncHandler(async (req, res) => {
  const { from, to } = req.query;
  const progress = await ptModel.getClientProgress(
    req.user.user_id,
    req.params.clientId,
    from,
    to,
  );

  if (progress === null) {
    return res.status(403).json(FORBIDDEN);
  }

  res.json(progress);
});

// GET /api/pt/clients/:clientId/ai-analysis/current
const getCurrentAiAnalysis = asyncHandler(async (req, res) => {
  const analysis = await ptModel.getCurrentAnalysis(
    req.user.user_id,
    req.params.clientId,
  );

  if (analysis === null) {
    if (!(await ptModel.isMyClient(req.user.user_id, req.params.clientId))) {
      return res.status(403).json(FORBIDDEN);
    }

    return res.status(404).json({ message: 'Belum ada hasil analisis AI.' });
  }

  res.json(analysis);
});

function replyAiError(res, error) {
  if (error instanceof AiError) {
    return res
      .status(error.status)
      .json({ message: error.message, details: error.details });
  }
  throw error;
}

// PATCH /api/pt/ai-analysis/:analysisId/approve
const approveAiAnalysis = asyncHandler(async (req, res) => {
  const { analysisId } = req.params;

  if (!(await ptModel.isMyAnalysis(req.user.user_id, analysisId))) {
    return res.status(403).json(FORBIDDEN);
  }

  try {
    const result = await reviewAnalysis({
      db: pool,
      analysisId: Number(analysisId),
      ptUserId: req.user.user_id,
      decision: 'approve',
    });
    res.json({ message: 'Rencana AI disetujui.', ...result });
  } catch (error) {
    return replyAiError(res, error);
  }
});

// PATCH /api/pt/ai-analysis/:analysisId/override
const overrideAiAnalysis = asyncHandler(async (req, res) => {
  const { analysisId } = req.params;
  const { final_output: finalOutput } = req.body || {};

  if (!finalOutput || typeof finalOutput !== 'object') {
    return res.status(400).json({
      message: 'final_output wajib diisi (berupa objek JSON) untuk override.',
    });
  }

  if (!(await ptModel.isMyAnalysis(req.user.user_id, analysisId))) {
    return res.status(403).json(FORBIDDEN);
  }

  try {
    const result = await reviewAnalysis({
      db: pool,
      analysisId: Number(analysisId),
      ptUserId: req.user.user_id,
      decision: 'override',
      finalOutput,
    });
    res.json({ message: 'Rencana AI berhasil di-override.', ...result });
  } catch (error) {
    return replyAiError(res, error);
  }
});

// POST /api/pt/clients/:clientId/generate-plan
const generatePlan = asyncHandler(async (req, res) => {
  const clientId = Number(req.params.clientId);

  if (!Number.isInteger(clientId) || clientId < 1) {
    return res.status(400).json({
      message: 'clientId harus berupa bilangan bulat positif.',
    });
  }

  if (!(await ptModel.isMyClient(req.user.user_id, clientId))) {
    return res.status(403).json(FORBIDDEN);
  }

  const result = await generateForClient(
    clientId,
    (req.body || {}).week_start_date,
  );

  if (result.status === 502) {
    delete result.body.details;
  }

  res.status(result.status).json(result.body);
});

module.exports = {
  getMyClients,
  getClientDetail,
  getClientProgress,
  getCurrentAiAnalysis,
  approveAiAnalysis,
  overrideAiAnalysis,
  generatePlan,
};
