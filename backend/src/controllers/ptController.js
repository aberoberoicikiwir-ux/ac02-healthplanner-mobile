const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

// PT hanya boleh mengakses klien yang di-assign ke dia (assigned_pt_id).
// Tanpa pengecekan ini, PT mana pun bisa melihat/mengubah data klien PT lain.
async function isMyClient(ptUserId, clientId) {
  const [rows] = await pool.query(
    `SELECT 1 FROM client_profiles WHERE client_id = ? AND assigned_pt_id = ?`,
    [clientId, ptUserId]
  );
  return rows.length > 0;
}

// Cek analisis AI ini milik klien bimbingan PT yang login.
async function isMyAnalysis(ptUserId, analysisId) {
  const [rows] = await pool.query(
    `SELECT 1 FROM ai_analysis_results a
     JOIN client_profiles cp ON cp.client_id = a.client_id
     WHERE a.analysis_id = ? AND cp.assigned_pt_id = ?`,
    [analysisId, ptUserId]
  );
  return rows.length > 0;
}

const FORBIDDEN = { message: 'Klien/analisis ini bukan bimbinganmu.' };

// GET /api/pt/clients?status=active
const getMyClients = asyncHandler(async (req, res) => {
  const status = req.query.status || 'active';

  const [rows] = await pool.query(
    `SELECT cp.client_id, cp.status, cp.weight_current, cp.weight_target, u.name, u.email
     FROM client_profiles cp
     JOIN users u ON u.user_id = cp.user_id
     WHERE cp.assigned_pt_id = ? AND cp.status = ?`,
    [req.user.user_id, status]
  );

  res.json(rows);
});

// GET /api/pt/clients/:clientId
const getClientDetail = asyncHandler(async (req, res) => {
  const { clientId } = req.params;

  const [rows] = await pool.query(
    `SELECT cp.*, u.name, u.email
     FROM client_profiles cp
     JOIN users u ON u.user_id = cp.user_id
     WHERE cp.client_id = ? AND cp.assigned_pt_id = ?`,
    [clientId, req.user.user_id]
  );

  if (rows.length === 0) {
    return res.status(404).json({ message: 'Klien tidak ditemukan atau bukan bimbinganmu.' });
  }
  res.json(rows[0]);
});

// GET /api/pt/clients/:clientId/progress?from=&to=
const getClientProgress = asyncHandler(async (req, res) => {
  const { clientId } = req.params;
  const { from, to } = req.query;

  if (!(await isMyClient(req.user.user_id, clientId))) {
    return res.status(403).json(FORBIDDEN);
  }

  const [rows] = await pool.query(
    `SELECT log_date, weight_kg, steps FROM daily_logs
     WHERE client_id = ? AND log_date BETWEEN ? AND ?
     ORDER BY log_date ASC`,
    [clientId, from || '1970-01-01', to || '2999-12-31']
  );

  res.json(rows);
});

// GET /api/pt/clients/:clientId/ai-analysis/current
const getCurrentAiAnalysis = asyncHandler(async (req, res) => {
  const { clientId } = req.params;

  if (!(await isMyClient(req.user.user_id, clientId))) {
    return res.status(403).json(FORBIDDEN);
  }

  const [rows] = await pool.query(
    `SELECT * FROM ai_analysis_results
     WHERE client_id = ?
     ORDER BY week_start_date DESC LIMIT 1`,
    [clientId]
  );

  if (rows.length === 0) {
    return res.status(404).json({ message: 'Belum ada hasil analisis AI.' });
  }
  res.json(rows[0]);
});

// PATCH /api/pt/ai-analysis/:analysisId/approve
const approveAiAnalysis = asyncHandler(async (req, res) => {
  const { analysisId } = req.params;

  if (!(await isMyAnalysis(req.user.user_id, analysisId))) {
    return res.status(403).json(FORBIDDEN);
  }

  await pool.query(
    `UPDATE ai_analysis_results
     SET status = 'approved', final_output = ai_output,
         reviewed_by_pt_id = ?, reviewed_at = NOW()
     WHERE analysis_id = ?`,
    [req.user.user_id, analysisId]
  );

  res.json({ message: 'Rencana AI disetujui.' });
});

// PATCH /api/pt/ai-analysis/:analysisId/override
const overrideAiAnalysis = asyncHandler(async (req, res) => {
  const { analysisId } = req.params;
  const { final_output } = req.body;

  if (!final_output || typeof final_output !== 'object') {
    return res.status(400).json({ message: 'final_output wajib diisi (berupa objek JSON) untuk override.' });
  }

  if (!(await isMyAnalysis(req.user.user_id, analysisId))) {
    return res.status(403).json(FORBIDDEN);
  }

  await pool.query(
    `UPDATE ai_analysis_results
     SET status = 'overridden', final_output = ?,
         reviewed_by_pt_id = ?, reviewed_at = NOW()
     WHERE analysis_id = ?`,
    [JSON.stringify(final_output), req.user.user_id, analysisId]
  );

  res.json({ message: 'Rencana AI berhasil di-override.' });
});

module.exports = {
  getMyClients,
  getClientDetail,
  getClientProgress,
  getCurrentAiAnalysis,
  approveAiAnalysis,
  overrideAiAnalysis,
};
