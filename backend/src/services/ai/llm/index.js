'use strict';

// Memilih penyedia AI dari .env (AI_PROVIDER = mock | gemini). Default: mock,
// supaya tanpa API key pun seluruh alur tetap bisa dijalankan dan diuji.
function getLlm() {
  const provider = (process.env.AI_PROVIDER || 'mock').toLowerCase();
  if (provider === 'mock') return require('./mock');
  if (provider === 'gemini') return require('./gemini');
  throw new Error(`AI_PROVIDER tidak dikenal: "${provider}" (pilih: mock atau gemini)`);
}

module.exports = { getLlm };
