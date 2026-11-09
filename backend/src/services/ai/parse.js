'use strict';

// Mengambil objek JSON dari teks keluaran model. Model kadang membungkus JSON
// dengan ```json ... ``` atau menambah kalimat pengantar; keduanya ditoleransi.
// Apa pun hasilnya tetap harus lolos validatePlan sebelum disimpan.
function extractJson(text) {
  if (typeof text !== 'string' || !text.trim()) {
    throw new Error('output kosong');
  }
  let t = text.trim();
  const fenced = t.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
  if (fenced) t = fenced[1];
  const start = t.indexOf('{');
  const end = t.lastIndexOf('}');
  if (start === -1 || end <= start) throw new Error('output bukan objek JSON');
  return JSON.parse(t.slice(start, end + 1));
}

module.exports = { extractJson };
