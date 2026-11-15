'use strict';

const { COACH } = require('./constants');

const URL_RE = /(https?:\/\/|www\.)/i;
// Saran medis berisiko yang tidak boleh muncul di jawaban coach.
const RISKY_RE =
  /\b(dosis|obat|resep|suplemen|diagnosis|diagnosa|suntik|steroid|detoks|terapi|puasa\s+(ekstrem|total))\b/i;
const PROMPT_LEAK_RE =
  /(system prompt|prompt sistem|instruksi sistem|aturan internal|kamu adalah coach raka|ignore (all|previous) instructions)/i;

// Pertanyaan seperti ini TIDAK dikirim ke AI; langsung diarahkan ke profesional.
const HIGH_RISK_RE =
  /(obat|dosis|resep|suplemen|steroid|diagnos|penyakit|diabetes|hipertensi|kolesterol|jantung|hamil|kehamilan|operasi|cedera|cidera|patah|fisioterapi|anoreksia|bulimia|depresi|bunuh diri|sesak napas|nyeri dada)/i;

const CATEGORIES = ['latihan', 'nutrisi', 'motivasi', 'lain'];

const SAFE_REPLY =
  'Pertanyaan ini menyangkut kondisi medis. Aku tidak bisa memberi diagnosis atau saran pengobatan. ' +
  'Silakan konsultasikan ke dokter atau PT yang mendampingimu.';

function normalizeQuestion(value) {
  // Tag < dan > dibuang supaya pertanyaan tidak bisa "keluar" dari blok data.
  return String(value ?? '')
    .replace(/[<>]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function isHighRiskQuestion(question) {
  return HIGH_RISK_RE.test(String(question ?? ''));
}

function validateCoachReply(raw) {
  const errors = [];
  if (raw === null || typeof raw !== 'object' || Array.isArray(raw)) {
    return { ok: false, errors: ['output harus berupa satu objek JSON'], reply: null };
  }

  const answer = typeof raw.answer === 'string' ? raw.answer.trim() : '';
  if (answer.length < COACH.answerLen[0] || answer.length > COACH.answerLen[1]) {
    errors.push(
      `answer wajib berupa teks ${COACH.answerLen[0]}-${COACH.answerLen[1]} karakter`
    );
  } else {
    if (URL_RE.test(answer)) errors.push('answer tidak boleh berisi tautan');
    if (RISKY_RE.test(answer)) errors.push('answer mengandung saran medis berisiko');
    if (PROMPT_LEAK_RE.test(answer)) errors.push('answer membocorkan instruksi sistem');
  }

  if (errors.length) return { ok: false, errors, reply: null };

  let category = typeof raw.category === 'string' ? raw.category.trim().toLowerCase() : '';
  if (!CATEGORIES.includes(category)) category = 'lain';

  return { ok: true, errors: [], reply: { answer, category } };
}

module.exports = {
  CATEGORIES,
  SAFE_REPLY,
  normalizeQuestion,
  isHighRiskQuestion,
  validateCoachReply,
};
