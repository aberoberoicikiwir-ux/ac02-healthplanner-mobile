'use strict';

// Teks alergi dari klien adalah input bebas, jadi bisa dipakai untuk menyelundupkan
// instruksi ke prompt (prompt injection). Fungsi ini TIDAK mengirim teks mentah ke AI.
// Teks dipecah menjadi kata kunci pendek (huruf/angka saja), sehingga tanda baca,
// kurung, tag, dan kalimat panjang tidak ikut terkirim sebagai kalimat utuh.
//
// Kata kunci yang sama dipakai validator untuk menolak makanan yang namanya
// memuat alergen. Pencocokan sengaja kasar (substring): lebih baik menolak
// berlebihan daripada kecolongan.

const STOPWORDS = new Set([
  'alergi', 'alergik', 'dan', 'atau', 'dengan', 'yang', 'saya', 'tidak', 'ada', 'bisa',
  'makan', 'makanan', 'terhadap', 'semua', 'juga', 'tanpa', 'nol', 'kena', 'gatal',
  'allergic', 'allergy', 'and', 'the', 'with', 'from', 'none', 'not', 'any',
]);

const MAX_TERMS = 12;

function allergyTerms(raw) {
  if (typeof raw !== 'string') return [];
  const tokens = raw
    .normalize('NFKC')
    .toLowerCase()
    .split(/[^\p{L}\p{N}]+/u)
    .filter((t) => t.length >= 3 && t.length <= 30 && !STOPWORDS.has(t));
  return [...new Set(tokens)].slice(0, MAX_TERMS);
}

function findAllergenHits(foodName, terms) {
  const name = String(foodName).toLowerCase();
  return terms.filter((t) => name.includes(t));
}

module.exports = { allergyTerms, findAllergenHits };
