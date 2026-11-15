-- Migrasi 001: menambah kolom hari pada menu (meal_plan_items.day_of_week).
--
-- KENAPA: rencana AI menyusun menu PER HARI, tetapi tabel meal_plan_items belum punya kolom hari,
-- sehingga rencana tidak bisa diterapkan ke klien.
--
-- KAPAN DIJALANKAN: SEKALI, pada database yang sudah ada (dibuat dari schema versi lama).
-- Database BARU yang dibuat dari healthmaxxing_schema.sql terbaru sudah punya kolom ini; jangan jalankan.
-- Menjalankan dua kali menghasilkan error "Duplicate column name 'day_of_week'" (tidak merusak data).
--
-- CARA:  mysql -u root healthmaxxing < migrations/001_meal_items_day_of_week.sql
--
-- Baris menu lama tetap valid: day_of_week = NULL (hari tidak diketahui).

ALTER TABLE meal_plan_items
    ADD COLUMN day_of_week ENUM('mon','tue','wed','thu','fri','sat','sun') NULL AFTER meal_type;
