'use strict';

// Penyedia Gemini lewat REST API (generateContent).
// STATUS: kode ini mengikuti dokumentasi API, tetapi BELUM diuji terhadap server
// Gemini sungguhan (butuh API key). Uji pertama dilakukan di laptop dengan key sendiri.
//
// Konfigurasi di .env:
//   GEMINI_API_KEY  kunci dari Google AI Studio (rahasia, jangan di-commit)
//   GEMINI_MODEL    nama model yang tersedia untuk akunmu (cek di AI Studio)
//   GEMINI_TIMEOUT_MS  opsional, default 60000

const name = 'gemini';
const BASE = 'https://generativelanguage.googleapis.com/v1beta/models';

function llmError(message) {
  const e = new Error(message);
  e.code = 'LLM_ERROR';
  return e;
}

async function generate({ system, user }) {
  const key = process.env.GEMINI_API_KEY;
  const model = process.env.GEMINI_MODEL;
  if (!key || key.startsWith('isi_')) throw llmError('GEMINI_API_KEY belum diisi di .env');
  if (!model) throw llmError('GEMINI_MODEL belum diisi di .env');

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), Number(process.env.GEMINI_TIMEOUT_MS) || 60000);

  try {
    const res = await fetch(`${BASE}/${encodeURIComponent(model)}:generateContent`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-goog-api-key': key },
      signal: controller.signal,
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: system }] },
        contents: [{ role: 'user', parts: [{ text: user }] }],
        generationConfig: {
          temperature: 0.4,
          responseMimeType: 'application/json',
          maxOutputTokens: 8192,
        },
      }),
    });

    const body = await res.json().catch(() => null);
    if (!res.ok) {
      throw llmError(`Gemini membalas HTTP ${res.status}: ${body?.error?.message || 'tanpa detail'}`);
    }

    const cand = body?.candidates?.[0];
    if (!cand) {
      const why = body?.promptFeedback?.blockReason;
      throw llmError(`Gemini tidak mengembalikan kandidat${why ? ` (diblokir: ${why})` : ''}`);
    }
    const text = (cand.content?.parts || []).map((p) => p.text || '').join('');
    if (cand.finishReason === 'MAX_TOKENS') throw llmError('Output Gemini terpotong (MAX_TOKENS)');
    if (!text.trim()) throw llmError(`Output Gemini kosong (finishReason: ${cand.finishReason || '-'})`);
    return text;
  } catch (e) {
    if (e.name === 'AbortError') throw llmError('Gemini timeout');
    throw e;
  } finally {
    clearTimeout(timer);
  }
}

module.exports = {
  name,
  get model() {
    return process.env.GEMINI_MODEL || null;
  },
  generate,
};
