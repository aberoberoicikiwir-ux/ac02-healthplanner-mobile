# HealthMaxxing Backend

Backend Express.js untuk AC-02 Personalized Health & Workout Planner.

## Cara Jalanin (Local)

1. **Install dependencies**
   ```
   npm install
   ```

2. **Setup database**
   Pastikan MySQL/MariaDB nyala, lalu jalankan schema dari checkpoint sebelumnya:
   ```
   mysql -u root -p < healthmaxxing_schema.sql
   ```

3. **Setup environment variable**
   Copy `.env.example` jadi `.env`, lalu sesuaikan `DB_PASSWORD` dan `JWT_SECRET`:
   ```
   cp .env.example .env
   ```

4. **Jalankan server**
   ```
   npm run dev
   ```
   Server jalan di `http://localhost:3000`. Tes dengan buka `http://localhost:3000/api/health`.

## Struktur Folder

```
backend/
├── src/
│   ├── server.js              ← entry point
│   ├── config/db.js           ← koneksi MySQL
│   ├── middlewares/
│   │   ├── auth.js            ← verifikasi JWT + cek role
│   │   └── errorHandler.js
│   ├── routes/                ← definisi URL & method
│   ├── controllers/           ← logic tiap endpoint (query ke DB)
│   └── utils/
├── package.json
└── .env.example
```

## Status Implementasi

Sudah jalan & tervalidasi (auth, health profile, daily logs, workout/meal checklist,
notifikasi, dashboard PT, master data). Yang **belum** diimplementasi (masih tahap
task list selanjutnya):

- Integrasi AI (Gemini API) — endpoint `/api/internal/ai/generate-weekly-plan`
- Validasi input yang lebih ketat & sanitasi (bagian dari task list section 7)
- Rate limiting

## Testing Cepat (curl)

```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","username":"testuser","password":"password123","role":"klien"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}'

# Pakai token yang didapat dari login untuk endpoint yang butuh auth
curl http://localhost:3000/api/clients/me/profile \
  -H "Authorization: Bearer <TOKEN_DARI_LOGIN>"
```
