const mysql = require('mysql2/promise');
require('dotenv').config();

// Connection pool — dipakai bareng di semua controller, jadi nggak
// bikin koneksi baru tiap ada request (lebih efisien).
//
// Format data yang dikirim ke Mobile/Web (diatur di sini supaya konsisten di semua endpoint):
//  - kolom DATE      -> string "YYYY-MM-DD". Tanpa ini, mysql2 membuat objek Date yang saat
//                       di-JSON jadi "1999-03-01T17:00:00.000Z" (bergeser sehari di WIB).
//  - kolom DECIMAL   -> angka (number), bukan teks "160.50".
//  - kolom BOOLEAN   -> true/false, bukan 1/0 (sama dengan format yang diterima PATCH).
// Kolom DATETIME (created_at, dst.) tetap berupa timestamp ISO UTC, mis. "2026-11-05T18:45:42.000Z".
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  dateStrings: ['DATE'],
  decimalNumbers: true,
  typeCast(field, next) {
    if (field.type === 'TINY' && field.length === 1) {
      const v = field.string();
      return v === null ? null : v === '1';
    }
    return next();
  },
});

module.exports = pool;
