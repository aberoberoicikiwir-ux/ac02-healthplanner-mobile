'use strict';

// Semua perhitungan tanggal memakai UTC untuk tanggal "kalender" (YYYY-MM-DD),
// supaya tidak bergeser oleh zona waktu / DST.

const DAY_MS = 86400000;

function toISO(ms) {
  return new Date(ms).toISOString().slice(0, 10);
}

// Tanggal hari ini menurut jam server, sebagai ms UTC tengah malam.
function todayUTC(now = new Date()) {
  return Date.UTC(now.getFullYear(), now.getMonth(), now.getDate());
}

function parseISODate(str) {
  if (typeof str !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(str)) return null;
  const ms = Date.parse(`${str}T00:00:00Z`);
  if (Number.isNaN(ms) || toISO(ms) !== str) return null;
  return ms;
}

function isMonday(ms) {
  return new Date(ms).getUTCDay() === 1;
}

// Senin pada minggu yang berisi tanggal ms.
function mondayOfWeek(ms) {
  const day = new Date(ms).getUTCDay(); // 0 = Minggu
  return ms - ((day + 6) % 7) * DAY_MS;
}

// Senin berikutnya, SELALU setelah hari ini (kalau hari ini Senin, hasilnya 7 hari lagi).
function nextMonday(now = new Date()) {
  const t = todayUTC(now);
  const day = new Date(t).getUTCDay();
  const add = (8 - day) % 7 || 7;
  return toISO(t + add * DAY_MS);
}

module.exports = { DAY_MS, toISO, todayUTC, parseISODate, isMonday, mondayOfWeek, nextMonday };
