-- ============================================================
-- HealthMaxxing - data master awal (latihan & makanan)
--
-- Tabel exercise_reference dan food_reference kosong setelah schema dimuat,
-- padahal AI hanya boleh memilih dari data ini (tidak boleh mengarang).
--
-- CARA PAKAI: jalankan SEKALI pada database yang sudah berisi schema:
--   mysql -u root < healthmaxxing_seed.sql
-- JANGAN dijalankan sebelum test_all.sh (skrip tes memasukkan data master-nya
-- sendiri dan butuh database kosong). Menjalankannya dua kali akan menggandakan data.
--
-- KONVENSI:
--  * Latihan kategori 'strength'    : sets x reps (jumlah pengulangan)
--  * Latihan kategori 'cardio'/'flexibility': sets = 1, reps = DURASI DALAM MENIT
--  * Nilai gizi adalah PERKIRAAN per porsi yang tertulis di nama. Verifikasi dengan
--    Tabel Komposisi Pangan Indonesia (TKPI) sebelum dipakai sebagai klaim ilmiah.
--  * Alergen utama sengaja ditulis di nama makanan (mis. "saus kacang", "kedelai",
--    "gluten") karena pengecekan alergi mencocokkan kata di nama makanan.
-- ============================================================

USE healthmaxxing;

INSERT INTO exercise_reference (name, category, calories_per_unit) VALUES
  ('Push up', 'strength', NULL),
  ('Squat', 'strength', NULL),
  ('Lunge', 'strength', NULL),
  ('Glute bridge', 'strength', NULL),
  ('Sit up', 'strength', NULL),
  ('Dumbbell row', 'strength', NULL),
  ('Dumbbell shoulder press', 'strength', NULL),
  ('Bicep curl', 'strength', NULL),
  ('Tricep dip (kursi)', 'strength', NULL),
  ('Romanian deadlift (dumbbell ringan)', 'strength', NULL),
  ('Jalan cepat', 'cardio', NULL),
  ('Jogging santai', 'cardio', NULL),
  ('Bersepeda', 'cardio', NULL),
  ('Lompat tali', 'cardio', NULL),
  ('Jumping jack', 'cardio', NULL),
  ('Naik turun tangga', 'cardio', NULL),
  ('Renang', 'cardio', NULL),
  ('Stretching seluruh tubuh', 'flexibility', NULL),
  ('Yoga dasar', 'flexibility', NULL),
  ('Peregangan kaki dan pinggul', 'flexibility', NULL);

INSERT INTO food_reference (name, calories, protein_g, carbs_g, fat_g) VALUES
  ('Nasi putih (1 piring, 150 g)', 195, 4.0, 42.0, 0.4),
  ('Nasi merah (1 piring, 150 g)', 168, 3.5, 35.0, 1.3),
  ('Dada ayam rebus (100 g)', 165, 31.0, 0.0, 3.6),
  ('Telur rebus (1 butir)', 78, 6.3, 0.6, 5.3),
  ('Telur dadar (1 butir)', 100, 6.5, 0.6, 7.7),
  ('Tempe kedelai goreng (2 potong, 50 g)', 140, 9.5, 5.0, 9.0),
  ('Tahu kedelai rebus (100 g)', 76, 8.1, 1.9, 4.8),
  ('Ikan kembung panggang (100 g)', 140, 20.0, 0.0, 6.0),
  ('Ikan salmon panggang (100 g)', 206, 22.0, 0.0, 12.0),
  ('Udang rebus (100 g)', 99, 24.0, 0.2, 0.3),
  ('Daging sapi tanpa lemak panggang (100 g)', 215, 26.0, 0.0, 12.0),
  ('Oatmeal dimasak dengan air (1 mangkuk, 40 g kering)', 150, 5.0, 27.0, 2.5),
  ('Roti gandum mengandung gluten (2 lembar)', 160, 8.0, 28.0, 2.0),
  ('Ubi rebus (1 buah sedang, 150 g)', 115, 2.3, 27.0, 0.2),
  ('Kentang rebus (150 g)', 130, 3.0, 30.0, 0.2),
  ('Jagung rebus (1 tongkol sedang)', 125, 4.0, 27.0, 1.8),
  ('Bayam rebus (1 mangkuk, 100 g)', 23, 3.0, 3.6, 0.3),
  ('Brokoli rebus (100 g)', 35, 2.4, 7.2, 0.4),
  ('Tumis kangkung (1 porsi, 100 g)', 75, 2.5, 5.0, 5.0),
  ('Gado-gado dengan saus kacang (1 porsi, 250 g)', 330, 12.0, 30.0, 18.0),
  ('Soto ayam bening (1 mangkuk, 300 ml)', 190, 17.0, 12.0, 8.0),
  ('Pisang (1 buah sedang)', 105, 1.3, 27.0, 0.4),
  ('Apel (1 buah sedang)', 95, 0.5, 25.0, 0.3),
  ('Jeruk (1 buah sedang)', 62, 1.2, 15.0, 0.2),
  ('Pepaya (1 potong, 100 g)', 43, 0.5, 11.0, 0.3),
  ('Semangka (1 potong, 200 g)', 60, 1.2, 15.0, 0.3),
  ('Alpukat (1/2 buah, 100 g)', 160, 2.0, 8.5, 14.7),
  ('Kacang almond (1 genggam, 28 g)', 164, 6.0, 6.0, 14.0),
  ('Kacang tanah rebus (30 g)', 100, 4.5, 4.0, 8.0),
  ('Yogurt plain dari susu (1 cup, 150 g)', 92, 5.3, 7.0, 5.0),
  ('Susu rendah lemak (1 gelas, 250 ml)', 105, 8.5, 12.0, 2.4);
