-- ============================================
-- ZiePoint Database Migration
-- Run this against your MySQL database:
--   mysql -u root -p zie_point < migrations.sql
-- ============================================

-- 1. Table: jenis_catatan
-- Stores types of violations (pelanggaran) and achievements (prestasi)
CREATE TABLE IF NOT EXISTS jenis_catatan (
    id_jenis INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    poin INT NOT NULL DEFAULT 0,
    tipe ENUM('pelanggaran', 'prestasi') NOT NULL DEFAULT 'pelanggaran',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Table: guru
-- Stores teacher accounts
CREATE TABLE IF NOT EXISTS guru (
    id_guru INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Table: siswa
-- If this table already exists, the ALTER statements below will add new columns.
-- If it doesn't exist, create it first.
CREATE TABLE IF NOT EXISTS siswa (
    id_siswa INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    kelas VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. ALTER siswa table: add NIS and password columns for student login
-- These are safe to run even if columns already exist (wrapped in procedure)
DELIMITER //
CREATE PROCEDURE add_siswa_columns()
BEGIN
    -- Add 'nis' column if it doesn't exist
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'siswa'
        AND COLUMN_NAME = 'nis'
    ) THEN
        ALTER TABLE siswa ADD COLUMN nis VARCHAR(15) UNIQUE AFTER nama;
    END IF;

    -- Add 'password' column if it doesn't exist
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'siswa'
        AND COLUMN_NAME = 'password'
    ) THEN
        ALTER TABLE siswa ADD COLUMN password VARCHAR(255) AFTER nis;
    END IF;
END //
DELIMITER ;

CALL add_siswa_columns();
DROP PROCEDURE IF EXISTS add_siswa_columns;

-- 5. Table: catatan_siswa
-- Stores disciplinary records linking student, teacher, and violation type
CREATE TABLE IF NOT EXISTS catatan_siswa (
    id_catatan INT AUTO_INCREMENT PRIMARY KEY,
    id_siswa INT NOT NULL,
    id_guru INT NOT NULL,
    id_jenis INT NOT NULL,
    tanggal DATE NOT NULL,
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_siswa) REFERENCES siswa(id_siswa) ON DELETE CASCADE,
    FOREIGN KEY (id_guru) REFERENCES guru(id_guru) ON DELETE CASCADE,
    FOREIGN KEY (id_jenis) REFERENCES jenis_catatan(id_jenis) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- Sample Seed Data (Optional - for testing)
-- ============================================

-- Insert sample jenis_catatan
INSERT IGNORE INTO jenis_catatan (id_jenis, nama, poin, tipe) VALUES
(1, 'Terlambat masuk sekolah', 5, 'pelanggaran'),
(2, 'Tidak memakai seragam lengkap', 10, 'pelanggaran'),
(3, 'Berkelahi di sekolah', 25, 'pelanggaran'),
(4, 'Membolos pelajaran', 15, 'pelanggaran'),
(5, 'Merokok di lingkungan sekolah', 30, 'pelanggaran'),
(6, 'Juara 1 lomba akademik', 10, 'prestasi'),
(7, 'Juara 1 lomba olahraga', 10, 'prestasi'),
(8, 'Aktif dalam kegiatan OSIS', 5, 'prestasi'),
(9, 'Mewakili sekolah di tingkat provinsi', 15, 'prestasi'),
(10, 'Nilai ujian tertinggi', 5, 'prestasi');

-- Insert sample guru (Password is plain-text "guru123" for testing, auth route supports this)
INSERT IGNORE INTO guru (id_guru, nama, email, password) VALUES
(1, 'Budi Santoso', 'budi@sekolah.id', 'guru123'),
(2, 'Siti Aminah', 'siti@sekolah.id', 'guru123');

-- Insert sample siswa (Password is plain-text "siswa123" for testing, auth route supports this)
INSERT IGNORE INTO siswa (id_siswa, nama, nis, kelas, password) VALUES
(1, 'Cha Eun Woo', '1001', 'PPLG_RPL 3', 'eunwoo123'),
(2, 'Nesya Kirani Nurrofi', '1002', 'PPLG_RPL 2', 'nesya123');
