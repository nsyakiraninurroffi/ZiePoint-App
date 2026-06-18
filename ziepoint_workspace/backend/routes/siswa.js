// ============================================
// Siswa CRUD Routes — Full Student Management
// ============================================

const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/auth');

// ── GET /api/siswa ─────────────────────────
// Public: List all students
router.get('/siswa', (req, res) => {
    const db = req.app.locals.db;
    const { search, kelas } = req.query;

    let conditions = [];
    let params = [];

    if (search) {
        conditions.push('(nama LIKE ? OR nis LIKE ?)');
        params.push(`%${search}%`, `%${search}%`);
    }
    if (kelas) {
        conditions.push('kelas = ?');
        params.push(kelas);
    }

    const whereClause = conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : '';
    const query = `SELECT id_siswa AS id, id_siswa, nama, kelas, nis FROM siswa ${whereClause} ORDER BY nama ASC`;

    db.query(query, params, (err, results) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        res.json(results);
    });
});

// ── GET /api/siswa/kelas ───────────────────
// Get unique kelas list for filter
router.get('/siswa/kelas', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    db.query('SELECT DISTINCT kelas FROM siswa WHERE kelas IS NOT NULL ORDER BY kelas ASC', (err, results) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        res.json(results.map(r => r.kelas));
    });
});

// ── GET /api/siswa/profil ──────────────────
// Protected: Return student profile from JWT
router.get('/siswa/profil', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    const idSiswa = req.user.id_siswa;

    if (!idSiswa) {
        return res.status(403).json({ error: 'Akses ditolak', message: 'Endpoint ini hanya untuk siswa.' });
    }

    db.query('SELECT id_siswa, nama, nis, kelas FROM siswa WHERE id_siswa = ?', [idSiswa], (err, results) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        if (results.length === 0) return res.status(404).json({ error: 'Tidak ditemukan', message: 'Data siswa tidak ditemukan.' });
        res.json(results[0]);
    });
});

// ── GET /api/siswa/leaderboard ─────────────
// Get top students by prestasi poin
router.get('/siswa/leaderboard', (req, res) => {
    const db = req.app.locals.db;
    const limit = parseInt(req.query.limit) || 5;

    const query = `
        SELECT
            s.id_siswa, s.nama, s.kelas, s.nis,
            COALESCE(SUM(CASE WHEN jc.tipe = 'prestasi' THEN jc.poin ELSE 0 END), 0) AS total_prestasi,
            COALESCE(SUM(CASE WHEN jc.tipe = 'pelanggaran' THEN jc.poin ELSE 0 END), 0) AS total_pelanggaran,
            COUNT(cs.id_catatan) AS total_catatan
        FROM siswa s
        LEFT JOIN catatan_siswa cs ON s.id_siswa = cs.id_siswa
        LEFT JOIN jenis_catatan jc ON cs.id_jenis = jc.id_jenis
        GROUP BY s.id_siswa, s.nama, s.kelas, s.nis
        ORDER BY total_prestasi DESC, total_pelanggaran ASC
        LIMIT ?
    `;

    db.query(query, [limit], (err, results) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        res.json(results);
    });
});

// ── GET /api/siswa/riwayat ─────────────────
// Protected: Return history for logged-in student
router.get('/siswa/riwayat', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    const idSiswa = req.user.id_siswa;

    if (!idSiswa) {
        return res.status(403).json({ error: 'Akses ditolak', message: 'Endpoint ini hanya untuk siswa.' });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const summaryQuery = `
        SELECT
            SUM(CASE WHEN jc.tipe = 'pelanggaran' THEN jc.poin ELSE 0 END) AS total_pelanggaran,
            SUM(CASE WHEN jc.tipe = 'prestasi' THEN jc.poin ELSE 0 END) AS total_prestasi
        FROM catatan_siswa cs
        JOIN jenis_catatan jc ON cs.id_jenis = jc.id_jenis
        WHERE cs.id_siswa = ?
    `;

    db.query(summaryQuery, [idSiswa], (err, summaryResults) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });

        const totalPelanggaran = summaryResults[0].total_pelanggaran || 0;
        const totalPrestasi = summaryResults[0].total_prestasi || 0;

        db.query('SELECT COUNT(*) AS total FROM catatan_siswa WHERE id_siswa = ?', [idSiswa], (err, countResults) => {
            if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });

            const totalItems = countResults[0].total;
            const totalPages = Math.ceil(totalItems / limit);

            const query = `
                SELECT cs.id_catatan, cs.tanggal, cs.keterangan, jc.nama AS nama_jenis,
                       jc.poin, jc.tipe, g.nama AS nama_guru
                FROM catatan_siswa cs
                JOIN jenis_catatan jc ON cs.id_jenis = jc.id_jenis
                JOIN guru g ON cs.id_guru = g.id_guru
                WHERE cs.id_siswa = ?
                ORDER BY cs.tanggal DESC, cs.id_catatan DESC
                LIMIT ? OFFSET ?
            `;

            db.query(query, [idSiswa, limit, offset], (err, results) => {
                if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
                res.json({
                    riwayat: results,
                    summary: {
                        total_pelanggaran: Number(totalPelanggaran),
                        total_prestasi: Number(totalPrestasi),
                        total_poin: Number(totalPelanggaran) - Number(totalPrestasi)
                    },
                    pagination: {
                        currentPage: page, limit, totalItems,
                        totalPages, hasMore: page < totalPages
                    }
                });
            });
        });
    });
});

// ── GET /api/siswa/:id ─────────────────────
router.get('/siswa/:id', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    db.query('SELECT id_siswa, nama, nis, kelas FROM siswa WHERE id_siswa = ?', [req.params.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        if (results.length === 0) return res.status(404).json({ error: 'Tidak ditemukan' });
        res.json(results[0]);
    });
});

// ── POST /api/siswa ────────────────────────
router.post('/siswa', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    const { nama, nis, kelas, password } = req.body;

    if (!nama || !nis || !kelas) {
        return res.status(400).json({ error: 'Validasi gagal', message: 'Field nama, nis, dan kelas wajib diisi.' });
    }

    db.query('SELECT id_siswa FROM siswa WHERE nis = ?', [nis], (err, existing) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        if (existing.length > 0) return res.status(409).json({ error: 'Konflik', message: 'NIS sudah digunakan.' });

        const defaultPassword = password || nis; // Default password = NIS
        db.query('INSERT INTO siswa (nama, nis, kelas, password) VALUES (?, ?, ?, ?)',
            [nama, nis, kelas, defaultPassword], (err, result) => {
                if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
                res.status(201).json({ message: 'Siswa berhasil ditambahkan', id_siswa: result.insertId });
            });
    });
});

// ── PUT /api/siswa/:id ─────────────────────
router.put('/siswa/:id', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    const { nama, nis, kelas } = req.body;

    if (!nama || !nis || !kelas) {
        return res.status(400).json({ error: 'Validasi gagal', message: 'Field nama, nis, dan kelas wajib diisi.' });
    }

    // Check NIS conflict (exclude current id)
    db.query('SELECT id_siswa FROM siswa WHERE nis = ? AND id_siswa != ?', [nis, req.params.id], (err, existing) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        if (existing.length > 0) return res.status(409).json({ error: 'Konflik', message: 'NIS sudah digunakan siswa lain.' });

        db.query('UPDATE siswa SET nama=?, nis=?, kelas=? WHERE id_siswa=?',
            [nama, nis, kelas, req.params.id], (err, result) => {
                if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
                if (result.affectedRows === 0) return res.status(404).json({ error: 'Data tidak ditemukan' });
                res.json({ message: 'Data siswa berhasil diperbarui' });
            });
    });
});

// ── DELETE /api/siswa/:id ──────────────────
router.delete('/siswa/:id', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    db.query('DELETE FROM siswa WHERE id_siswa = ?', [req.params.id], (err, result) => {
        if (err) {
            if (err.code === 'ER_ROW_IS_REFERENCED_2') {
                return res.status(409).json({ error: 'Konflik data', message: 'Siswa ini masih memiliki catatan. Hapus catatan terlebih dahulu.' });
            }
            return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        }
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Data tidak ditemukan' });
        res.json({ message: 'Siswa berhasil dihapus' });
    });
});

module.exports = router;
