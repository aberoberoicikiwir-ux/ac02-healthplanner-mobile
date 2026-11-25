const pool = require('../config/db');

const SORT_COLUMNS = {
  client_id: 'cp.client_id',
  name: 'u.name',
  weight_current: 'cp.weight_current',
  weight_target: 'cp.weight_target',
  status: 'cp.status',
};

function escapeLike(value) {
  return String(value).replace(/[\\%_]/g, '\\$&');
}

function orderClause(sort, order) {
  const column = SORT_COLUMNS[sort] || SORT_COLUMNS.name;
  const direction = order === 'desc' ? 'DESC' : 'ASC';
  return `${column} ${direction}, cp.client_id ASC`;
}

async function isMyClient(ptUserId, clientId) {
  const [rows] = await pool.query(
    `SELECT 1 FROM client_profiles WHERE client_id = ? AND assigned_pt_id = ?`,
    [clientId, ptUserId],
  );
  return rows.length > 0;
}

async function isMyAnalysis(ptUserId, analysisId) {
  const [rows] = await pool.query(
    `SELECT 1 FROM ai_analysis_results a
     JOIN client_profiles cp ON cp.client_id = a.client_id
     WHERE a.analysis_id = ? AND cp.assigned_pt_id = ?`,
    [analysisId, ptUserId],
  );
  return rows.length > 0;
}

async function listClients(ptUserId, { page, limit, search, status, sort, order }) {
  const where = ['cp.assigned_pt_id = ?', 'cp.status = ?'];
  const params = [ptUserId, status];

  if (search) {
    where.push('(u.name LIKE ? OR u.email LIKE ?)');
    const term = `%${escapeLike(search)}%`;
    params.push(term, term);
  }

  const whereSql = where.join(' AND ');
  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total
     FROM client_profiles cp
     JOIN users u ON u.user_id = cp.user_id
     WHERE ${whereSql}`,
    params,
  );
  const total = Number(countRows[0]?.total || 0);
  const offset = (page - 1) * limit;

  const [rows] = await pool.query(
    `SELECT cp.client_id, cp.status, cp.weight_current, cp.weight_target, u.name, u.email
     FROM client_profiles cp
     JOIN users u ON u.user_id = cp.user_id
     WHERE ${whereSql}
     ORDER BY ${orderClause(sort, order)}
     LIMIT ? OFFSET ?`,
    [...params, limit, offset],
  );

  return {
    data: rows,
    meta: {
      page,
      limit,
      total,
      total_pages: total === 0 ? 0 : Math.ceil(total / limit),
    },
  };
}

async function getClientDetail(ptUserId, clientId) {
  const [rows] = await pool.query(
    `SELECT cp.*, u.name, u.email
     FROM client_profiles cp
     JOIN users u ON u.user_id = cp.user_id
     WHERE cp.client_id = ? AND cp.assigned_pt_id = ?`,
    [clientId, ptUserId],
  );
  return rows[0] || null;
}

async function getClientProgress(ptUserId, clientId, from, to) {
  if (!(await isMyClient(ptUserId, clientId))) {
    return null;
  }

  const [rows] = await pool.query(
    `SELECT log_date, weight_kg, steps FROM daily_logs
     WHERE client_id = ? AND log_date BETWEEN ? AND ?
     ORDER BY log_date ASC`,
    [clientId, from || '1970-01-01', to || '2999-12-31'],
  );
  return rows;
}

async function getCurrentAnalysis(ptUserId, clientId) {
  if (!(await isMyClient(ptUserId, clientId))) {
    return null;
  }

  const [rows] = await pool.query(
    `SELECT * FROM ai_analysis_results
     WHERE client_id = ?
     ORDER BY week_start_date DESC LIMIT 1`,
    [clientId],
  );
  return rows[0] || null;
}

module.exports = {
  escapeLike,
  orderClause,
  isMyClient,
  isMyAnalysis,
  listClients,
  getClientDetail,
  getClientProgress,
  getCurrentAnalysis,
};
