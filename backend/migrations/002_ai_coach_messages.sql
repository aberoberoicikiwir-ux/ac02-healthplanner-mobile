-- Migrasi 002: tabel riwayat chat "Tanya Coach" (AI).
--
-- KENAPA: fitur Insight AI punya dua bagian: feedback mingguan (notifikasi)
-- dan tanya-jawab dengan coach. Riwayat chat disimpan per klien supaya bisa
-- dibuka lagi setelah aplikasi ditutup. PT TIDAK memiliki akses ke isi chat.
--
-- KAPAN DIJALANKAN: sekali pada database yang sudah ada.
-- Database baru dari healthmaxxing_schema.sql terbaru sudah punya tabel ini.
--
-- CARA: mysql -u root healthmaxxing < migrations/002_ai_coach_messages.sql
--
-- Aman dijalankan ulang karena memakai IF NOT EXISTS.

CREATE TABLE IF NOT EXISTS ai_coach_messages (
    message_id   INT AUTO_INCREMENT PRIMARY KEY,
    client_id    INT NOT NULL,
    `role`       ENUM('user', 'assistant') NOT NULL,
    content      TEXT NOT NULL,
    provider     VARCHAR(20) NULL,
    model        VARCHAR(100) NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,

    KEY idx_coach_client_time (client_id, created_at),

    CONSTRAINT fk_coach_messages_client
        FOREIGN KEY (client_id) REFERENCES client_profiles(client_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;
