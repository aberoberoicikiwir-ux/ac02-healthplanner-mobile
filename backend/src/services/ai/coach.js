'use strict';

const AiError = require('./AiError');
const { COACH } = require('./constants');
const { extractJson } = require('./parse');
const { loadClientByUserId, buildCoachContext } = require('./context');
const { buildCoachPrompt } = require('./coachPrompt');
const {
  normalizeQuestion,
  isHighRiskQuestion,
  validateCoachReply,
  SAFE_REPLY,
} = require('./validateCoach');

function dailyLimit() {
  const value = Number(process.env.AI_COACH_DAILY_LIMIT);
  if (Number.isFinite(value) && value > 0) return Math.floor(value);
  return COACH.dailyLimit;
}

function maxAttempts() {
  return Math.max(1, Math.min(2, Number(process.env.AI_MAX_ATTEMPTS) || 2));
}

function mockReply(question) {
  const q = question.toLowerCase();
  let category = 'lain';
  let answer =
    '[Mode MOCK] Coach mencatat pertanyaanmu. Tetap konsisten dengan rencana PT, ' +
    'utamakan teknik yang benar, istirahat cukup, dan minum air yang cukup.';

  if (/(latihan|squat|push|pull|cardio|otot|gym|beban|set|reps)/.test(q)) {
    category = 'latihan';
    answer =
      '[Mode MOCK] Untuk latihan, mulai dengan pemanasan, gunakan teknik yang benar, ' +
      'dan naikkan beban secara bertahap. Sesuaikan dengan rencana yang sudah disetujui PT.';
  } else if (/(makan|menu|protein|kalori|nutrisi|diet|air|sayur)/.test(q)) {
    category = 'nutrisi';
    answer =
      '[Mode MOCK] Untuk menu, prioritaskan protein, sayur, dan air yang cukup. ' +
      'Hindari makanan yang mengandung alergenmu dan ikuti rencana menu dari PT.';
  } else if (/(motivasi|semangat|malas|capek|bosan)/.test(q)) {
    category = 'motivasi';
    answer =
      '[Mode MOCK] Mulai dari target kecil yang bisa kamu jaga setiap hari. ' +
      'Konsistensi lebih penting daripada intensitas sesekali.';
  }

  return JSON.stringify({ answer, category });
}

async function audit(db, { action, severity = 'info', entityType, entityId, details }) {
  try {
    await db.query(
      `INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details, severity)
       VALUES (NULL, ?, ?, ?, ?, ?)`,
      [action, entityType, entityId, details ? JSON.stringify(details) : null, severity]
    );
  } catch (e) {
    console.error('Gagal menulis audit log coach:', e.message);
  }
}

async function getClientOrThrow(db, userId) {
  const client = await loadClientByUserId(db, userId);
  if (!client) throw new AiError(404, 'Profil belum diisi. Lengkapi profil terlebih dahulu.');
  if (client.status !== 'active') throw new AiError(409, 'Akun klien tidak aktif.');
  return client;
}

async function getCoachHistory({ db, userId, limit }) {
  const client = await getClientOrThrow(db, userId);
  const requested = Number.parseInt(limit, 10);
  const take = Number.isFinite(requested)
    ? Math.min(Math.max(requested, 1), 50)
    : COACH.historyLimit;

  const [rows] = await db.query(
    `SELECT * FROM (
       SELECT message_id, \`role\`, content, provider, model, created_at
       FROM ai_coach_messages
       WHERE client_id = ?
       ORDER BY message_id DESC
       LIMIT ?
     ) AS recent
     ORDER BY message_id ASC`,
    [client.client_id, take]
  );
  return rows;
}

async function askCoach({ db, userId, message, llm }) {
  const question = normalizeQuestion(message);
  if (!question) throw new AiError(400, 'Pertanyaan wajib diisi.');
  if (question.length > COACH.questionMaxLen) {
    throw new AiError(
      400,
      `Pertanyaan maksimal ${COACH.questionMaxLen} karakter.`
    );
  }

  const client = await getClientOrThrow(db, userId);
  const limit = dailyLimit();

  const [countRows] = await db.query(
    `SELECT COUNT(*) AS total FROM ai_coach_messages
     WHERE client_id = ? AND \`role\` = 'user'
       AND created_at >= DATE_SUB(NOW(), INTERVAL 1 DAY)`,
    [client.client_id]
  );
  if (Number(countRows[0]?.total || 0) >= limit) {
    throw new AiError(
      429,
      `Batas ${limit} pertanyaan per hari sudah tercapai. Coba lagi besok ya.`
    );
  }

  const [userInsert] = await db.query(
    'INSERT INTO ai_coach_messages (client_id, `role`, content) VALUES (?, ?, ?)',
    [client.client_id, 'user', question]
  );
  const userMessageId = userInsert.insertId;

  // Pertanyaan berisiko medis tidak dikirim ke AI.
  if (isHighRiskQuestion(question)) {
    const [assistantInsert] = await db.query(
      `INSERT INTO ai_coach_messages (client_id, \`role\`, content, provider, model)
       VALUES (?, 'assistant', ?, 'safety', NULL)`,
      [client.client_id, SAFE_REPLY]
    );
    await audit(db, {
      action: 'ai.coach_question',
      entityType: 'client_profiles',
      entityId: client.client_id,
      details: {
        client_id: client.client_id,
        question_length: question.length,
        provider: 'safety',
        safety_refusal: true,
      },
    });
    return {
      user_message: { message_id: userMessageId, role: 'user', content: question },
      reply: {
        message_id: assistantInsert.insertId,
        role: 'assistant',
        content: SAFE_REPLY,
      },
      category: 'lain',
      safety_refusal: true,
    };
  }

  const data = await buildCoachContext(db, client);
  const prompt = buildCoachPrompt(data, question);

  let result = null;
  let lastErrors = null;
  let attempts = 0;
  const attemptsLimit = maxAttempts();

  for (let attempt = 1; attempt <= attemptsLimit; attempt++) {
    attempts = attempt;

    let raw;
    try {
      raw = llm.name === 'mock' ? mockReply(question) : await llm.generate(prompt);
    } catch (e) {
      await db.query('DELETE FROM ai_coach_messages WHERE message_id = ?', [userMessageId]);
      await audit(db, {
        action: 'ai.coach_question_failed',
        severity: 'error',
        entityType: 'client_profiles',
        entityId: client.client_id,
        details: {
          client_id: client.client_id,
          question_length: question.length,
          provider: llm.name,
          attempt,
          error: e.message,
        },
      });
      throw new AiError(
        502,
        'Layanan AI gagal merespons.',
        [e.message],
        'Coach sedang tidak bisa menjawab. Coba lagi nanti.'
      );
    }

    try {
      const parsed = extractJson(raw);
      const check = validateCoachReply(parsed);
      if (check.ok) {
        result = check.reply;
        break;
      }
      lastErrors = check.errors;
    } catch (e) {
      lastErrors = [`output bukan objek JSON yang valid (${e.message})`];
    }

    if (llm.name === 'mock') break;
  }

  if (!result) {
    await db.query('DELETE FROM ai_coach_messages WHERE message_id = ?', [userMessageId]);
    await audit(db, {
      action: 'ai.coach_question_rejected',
      severity: 'warning',
      entityType: 'client_profiles',
      entityId: client.client_id,
      details: {
        client_id: client.client_id,
        question_length: question.length,
        provider: llm.name,
        attempts,
        errors: lastErrors,
      },
    });
    throw new AiError(
      502,
      'Coach belum bisa menjawab dengan aman.',
      lastErrors,
      'Coach belum bisa menjawab dengan aman. Coba lagi.'
    );
  }

  const [assistantInsert] = await db.query(
    `INSERT INTO ai_coach_messages (client_id, \`role\`, content, provider, model)
     VALUES (?, 'assistant', ?, ?, ?)`,
    [client.client_id, result.answer, llm.name, llm.model || null]
  );

  await audit(db, {
    action: 'ai.coach_question',
    entityType: 'client_profiles',
    entityId: client.client_id,
    details: {
      client_id: client.client_id,
      question_length: question.length,
      provider: llm.name,
      model: llm.model || null,
      attempts,
      category: result.category,
      safety_refusal: false,
    },
  });

  return {
    user_message: { message_id: userMessageId, role: 'user', content: question },
    reply: {
      message_id: assistantInsert.insertId,
      role: 'assistant',
      content: result.answer,
    },
    category: result.category,
    safety_refusal: false,
  };
}

async function clearCoachHistory({ db, userId }) {
  const client = await getClientOrThrow(db, userId);
  const [result] = await db.query(
    'DELETE FROM ai_coach_messages WHERE client_id = ?',
    [client.client_id]
  );
  return { deleted: Number(result.affectedRows || 0) };
}

module.exports = { getCoachHistory, askCoach, clearCoachHistory };
