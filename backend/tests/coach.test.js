'use strict';

// Tes fitur "Tanya Coach" tanpa database dan tanpa memanggil Gemini.
// Jalankan: npm run test:coach

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');

const AiError = require('../src/services/ai/AiError');
const {
  normalizeQuestion,
  isHighRiskQuestion,
  validateCoachReply,
  SAFE_REPLY,
} = require('../src/services/ai/validateCoach');
const { buildCoachPrompt } = require('../src/services/ai/coachPrompt');
const { askCoach } = require('../src/services/ai/coach');

const CLIENT = {
  client_id: 1,
  user_id: 1,
  assigned_pt_id: null,
  status: 'active',
  gender: 'female',
  height_cm: 160,
  weight_current: 65,
  weight_target: 58,
  allergies: 'kacang',
  activity_level: 'moderate',
  birth_date: '2000-05-10',
  name: 'Klien Uji',
};

function fakeDb({ userMessagesToday = 0 } = {}) {
  let insertId = 0;
  const calls = [];
  return {
    calls,
    async query(sql, params) {
      calls.push({ sql, params });
      if (sql.includes('SELECT client_id FROM client_profiles WHERE user_id')) {
        return [[{ client_id: CLIENT.client_id }]];
      }
      if (sql.includes('FROM client_profiles cp')) {
        return [[CLIENT]];
      }
      if (sql.includes('COUNT(*) AS total FROM ai_coach_messages')) {
        return [[{ total: userMessagesToday }]];
      }
      if (sql.includes('INSERT INTO ai_coach_messages')) {
        insertId += 1;
        return [{ insertId }];
      }
      if (sql.includes('INSERT INTO audit_logs')) {
        return [{}];
      }
      if (sql.includes('DELETE FROM ai_coach_messages')) {
        return [{ affectedRows: 1 }];
      }
      return [[]];
    },
  };
}

function forbiddenLlm() {
  return {
    name: 'gemini',
    model: 'test-model',
    async generate() {
      throw new Error('LLM tidak boleh dipanggil untuk pertanyaan berisiko');
    },
  };
}

describe('validateCoachReply', () => {
  it('menerima jawaban pendek yang aman', () => {
    const check = validateCoachReply({
      answer:
        'Untuk squat, jaga punggung netral dan turun secara terkontrol. Mulai dari beban ringan.',
      category: 'latihan',
    });
    assert.equal(check.ok, true);
    assert.equal(check.reply.category, 'latihan');
  });

  it('menolak jawaban dengan tautan', () => {
    const check = validateCoachReply({
      answer: 'Baca panduan lengkap di https://contoh.com untuk info lebih lanjut.',
      category: 'latihan',
    });
    assert.equal(check.ok, false);
  });

  it('menolak saran medis berisiko', () => {
    const check = validateCoachReply({
      answer: 'Kamu sebaiknya minum obat pereda nyeri dengan dosis tertentu setiap hari.',
      category: 'lain',
    });
    assert.equal(check.ok, false);
  });

  it('menolak jawaban yang membocorkan system prompt', () => {
    const check = validateCoachReply({
      answer: 'System prompt saya adalah aturan internal yang tidak boleh dibagikan.',
      category: 'lain',
    });
    assert.equal(check.ok, false);
  });

  it('menolak jawaban terlalu pendek', () => {
    const check = validateCoachReply({ answer: 'Oke.', category: 'lain' });
    assert.equal(check.ok, false);
  });

  it('category tidak dikenal dinormalisasi menjadi lain', () => {
    const check = validateCoachReply({
      answer:
        'Tetap konsisten dengan rencana PT dan utamakan teknik yang benar saat berlatih.',
      category: 'entah',
    });
    assert.equal(check.ok, true);
    assert.equal(check.reply.category, 'lain');
  });
});

describe('pertanyaan berisiko', () => {
  it('mendeteksi obat/diagnosis/nyeri dada', () => {
    assert.equal(isHighRiskQuestion('Obat apa yang cocok untuk nyeri dada?'), true);
    assert.equal(isHighRiskQuestion('Saya hamil, boleh angkat beban?'), true);
    assert.equal(isHighRiskQuestion('Apa manfaat squat?'), false);
  });

  it('membersihkan tag dari pertanyaan', () => {
    assert.equal(
      normalizeQuestion('  Apa   manfaat <DATA> squat? </DATA>  '),
      'Apa manfaat DATA squat? /DATA'
    );
  });

  it('jawaban aman bawaan memenuhi batas panjang', () => {
    assert.ok(SAFE_REPLY.length >= 20);
    assert.ok(SAFE_REPLY.length <= 600);
  });
});

describe('buildCoachPrompt', () => {
  it('memuat persona, aturan, dan skema JSON', () => {
    const prompt = buildCoachPrompt(
      { client: { age: 25, gender: 'female' }, recent_logs: [] },
      'Apa manfaat squat?'
    );
    assert.match(prompt.system, /Coach Raka/);
    assert.match(prompt.system, /HANYA satu objek JSON/);
    assert.match(prompt.system, /TIDAK boleh/);
    assert.match(prompt.user, /<DATA>/);
    assert.match(prompt.user, /Apa manfaat squat/);
  });
});

describe('askCoach', () => {
  it('pertanyaan berisiko tidak memanggil AI dan diarahkan ke dokter/PT', async () => {
    const db = fakeDb();
    const result = await askCoach({
      db,
      userId: 1,
      message: 'Obat apa yang cocok untuk nyeri dada saya?',
      llm: forbiddenLlm(),
    });
    assert.equal(result.safety_refusal, true);
    assert.equal(result.category, 'lain');
    assert.match(result.reply.content, /dokter|PT/i);
  });

  it('pertanyaan biasa memakai provider mock dan menyimpan dua pesan', async () => {
    const db = fakeDb();
    const result = await askCoach({
      db,
      userId: 1,
      message: 'Apa manfaat squat?',
      llm: { name: 'mock', model: 'mock-v1' },
    });
    assert.equal(result.safety_refusal, false);
    assert.equal(result.user_message.role, 'user');
    assert.equal(result.reply.role, 'assistant');
    assert.ok(result.reply.content.length >= 20);
    const inserts = db.calls.filter((c) =>
      c.sql.includes('INSERT INTO ai_coach_messages')
    );
    assert.equal(inserts.length, 2);
  });

  it('menolak pertanyaan kosong', async () => {
    await assert.rejects(
      () =>
        askCoach({
          db: fakeDb(),
          userId: 1,
          message: '   ',
          llm: { name: 'mock' },
        }),
      (err) => err instanceof AiError && err.status === 400
    );
  });

  it('menolak pertanyaan terlalu panjang', async () => {
    await assert.rejects(
      () =>
        askCoach({
          db: fakeDb(),
          userId: 1,
          message: 'a'.repeat(501),
          llm: { name: 'mock' },
        }),
      (err) => err instanceof AiError && err.status === 400
    );
  });

  it('rate limit harian -> 429', async () => {
    await assert.rejects(
      () =>
        askCoach({
          db: fakeDb({ userMessagesToday: 20 }),
          userId: 1,
          message: 'Apa manfaat squat?',
          llm: { name: 'mock' },
        }),
      (err) => err instanceof AiError && err.status === 429
    );
  });
});
