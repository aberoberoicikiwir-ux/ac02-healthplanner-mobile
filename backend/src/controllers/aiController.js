'use strict';

const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const AiError = require('../services/ai/AiError');
const { generateWeeklyPlan } = require('../services/ai/planner');
const { getLlm } = require('../services/ai/llm');
const { DAY_MS, toISO, todayUTC, parseISODate, isMonday, mondayOfWeek, nextMonday } = require('../utils/dates');

const MAX_WEEKS_AHEAD = 8;

// POST /api/internal/ai/generate-weekly-plan
// body: { client_id: number, week_start_date?: "YYYY-MM-DD" (harus hari Senin) }
// Default minggu: Senin berikutnya.
const generate = asyncHandler(async (req, res) => {
  const { client_id, week_start_date } = req.body || {};

  if (!Number.isInteger(client_id) || client_id < 1) {
    return res.status(400).json({ message: 'client_id wajib berupa bilangan bulat positif.' });
  }

  let weekStart;
  if (week_start_date === undefined) {
    weekStart = nextMonday();
  } else {
    const ms = parseISODate(week_start_date);
    if (ms === null) return res.status(400).json({ message: 'week_start_date harus berformat YYYY-MM-DD yang valid.' });
    if (!isMonday(ms)) return res.status(400).json({ message: 'week_start_date harus hari Senin.' });
    const thisMonday = mondayOfWeek(todayUTC());
    if (ms < thisMonday || ms > thisMonday + MAX_WEEKS_AHEAD * 7 * DAY_MS) {
      return res.status(400).json({
        message: `week_start_date harus antara minggu ini (${toISO(thisMonday)}) dan ${MAX_WEEKS_AHEAD} minggu ke depan.`,
      });
    }
    weekStart = week_start_date;
  }

  let llm;
  try {
    llm = getLlm();
  } catch (e) {
    return res.status(500).json({ message: e.message });
  }

  try {
    const r = await generateWeeklyPlan({ db: pool, clientId: client_id, weekStart, llm });
    return res.status(r.created ? 201 : 200).json({
      message: r.created ? 'Rencana AI dibuat dan menunggu review PT.' : 'Rencana AI pending diperbarui.',
      analysis_id: r.analysis_id,
      week_start_date: r.week_start_date,
      status: r.status,
      attempts: r.attempts,
      warnings: r.warnings,
      provider: r.plan.meta.provider,
    });
  } catch (e) {
    // Error AI membawa status & detail yang aman (pemanggil sudah terotentikasi lewat kunci internal).
    if (e instanceof AiError) return res.status(e.status).json({ message: e.message, details: e.details });
    throw e;
  }
});

module.exports = { generate };
