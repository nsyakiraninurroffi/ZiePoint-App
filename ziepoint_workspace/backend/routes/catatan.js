// ============================================
// Catatan Routes — Full CRUD for Records
// ============================================

const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/auth');

// ── GET /api/catatan_siswa ─────────────────────
// Get all catatan (teacher only), optional filter by id_siswa
router.get('/catatan_siswa', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    const { id_siswa, tipe, search, limit = 50, page = 1 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let conditions = [];
    let params = [];

    if (id_siswa) { conditions.push('cs.id_siswa = ?'); params.push(id_siswa); }
    if (tipe && ['pelanggaran', 'prestasi'].includes(tipe)) {
        conditions.push('jc.tipe = ?'); params.push(tipe);
    }
    if (search) {
        conditions.push('(s.nama LIKE ? OR jc.nama LIKE ? OR cs.keterangan LIKE ?)');
        params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }

    const whereClause = conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : '';

    const query = `
        SELECT
            cs.id_catatan,
            cs.tanggal,
            cs.keterangan,
            cs.created_at,
            jc.id_jenis,
            jc.nama AS nama_jenis,
            jc.poin,
            jc.tipe,
            s.id_siswa,
            s.nama AS nama_siswa,
            s.nis,
            s.kelas,
            g.id_guru,
            g.nama AS nama_guru
        FROM catatan_siswa cs
        JOIN jenis_catatan jc ON cs.id_jenis = jc.id_jenis
        JOIN siswa s ON cs.id_siswa = s.id_siswa
        JOIN guru g ON cs.id_guru = g.id_guru
        ${whereClause}
        ORDER BY cs.tanggal DESC, cs.id_catatan DESC
        LIMIT ? OFFSET ?
    `;

    const countQuery = `
        SELECT COUNT(*) AS total FROM catatan_siswa cs
        JOIN jenis_catatan jc ON cs.id_jenis = jc.id_jenis
        JOIN siswa s ON cs.id_siswa = s.id_siswa
        ${whereClause}
    `;

    db.query(countQuery, params, (err, countResult) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });

        const total = countResult[0].total;
        db.query(query, [...params, parseInt(limit), offset], (err, results) => {
            if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
            res.json({
                data: results,
                pagination: {
                    total,
                    page: parseInt(page),
                    limit: parseInt(limit),
                    totalPages: Math.ceil(total / parseInt(limit)),
                    hasMore: parseInt(page) < Math.ceil(total / parseInt(limit))
                }
            });
        });
    });
});

// ── GET /api/catatan_siswa/:id ──────────────────
// Get single catatan detail
router.get('/catatan_siswa/:id', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    const query = `
        SELECT cs.*, jc.nama AS nama_jenis, jc.poin, jc.tipe,
               s.nama AS nama_siswa, s.nis, s.kelas, g.nama AS nama_guru
        FROM catatan_siswa cs
        JOIN jenis_catatan jc ON cs.id_jenis = jc.id_jenis
        JOIN siswa s ON cs.id_siswa = s.id_siswa
        JOIN guru g ON cs.id_guru = g.id_guru
        WHERE cs.id_catatan = ?
    `;
    db.query(query, [req.params.id], (err, results) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        if (results.length === 0) return res.status(404).json({ error: 'Data tidak ditemukan' });
        res.json(results[0]);
    });
});

// ── POST /api/catatan_siswa ────────────────────
// Create a new record (teacher only)
router.post('/catatan_siswa', (req, res) => {
    const db = req.app.locals.db;
    const { id_guru, id_siswa, id_jenis, tanggal, keterangan } = req.body;

    if (!id_guru || !id_siswa || !id_jenis || !tanggal) {
        return res.status(400).json({
            error: 'Validasi gagal',
            message: 'Field id_guru, id_siswa, id_jenis, dan tanggal wajib diisi.'
        });
    }

    const query = `INSERT INTO catatan_siswa (id_guru, id_siswa, id_jenis, tanggal, keterangan) VALUES (?, ?, ?, ?, ?)`;
    db.query(query, [id_guru, id_siswa, id_jenis, tanggal, keterangan || ''], (err, result) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        res.json({ message: 'Catatan berhasil disimpan', id_catatan: result.insertId });
    });
});

// ── PUT /api/catatan_siswa/:id ─────────────────
// Update a catatan
router.put('/catatan_siswa/:id', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    const { id_siswa, id_jenis, tanggal, keterangan } = req.body;

    if (!id_siswa || !id_jenis || !tanggal) {
        return res.status(400).json({
            error: 'Validasi gagal',
            message: 'Field id_siswa, id_jenis, dan tanggal wajib diisi.'
        });
    }

    const query = `UPDATE catatan_siswa SET id_siswa=?, id_jenis=?, tanggal=?, keterangan=? WHERE id_catatan=?`;
    db.query(query, [id_siswa, id_jenis, tanggal, keterangan || '', req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Data tidak ditemukan' });
        res.json({ message: 'Catatan berhasil diperbarui' });
    });
});

// ── DELETE /api/catatan_siswa/:id ──────────────
// Delete a catatan
router.delete('/catatan_siswa/:id', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    db.query('DELETE FROM catatan_siswa WHERE id_catatan = ?', [req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Data tidak ditemukan' });
        res.json({ message: 'Catatan berhasil dihapus' });
    });
});

// ── GET /api/jenis_catatan/:tipe ───────────────
router.get('/jenis_catatan/:tipe', (req, res) => {
    const db = req.app.locals.db;
    const { tipe } = req.params;

    if (!['pelanggaran', 'prestasi', 'all'].includes(tipe)) {
        return res.status(400).json({ error: 'Parameter tidak valid', message: 'Tipe harus berupa "pelanggaran", "prestasi", atau "all".' });
    }

    const query = tipe === 'all'
        ? 'SELECT * FROM jenis_catatan ORDER BY tipe ASC, nama ASC'
        : 'SELECT * FROM jenis_catatan WHERE tipe = ? ORDER BY nama ASC';
    const params = tipe === 'all' ? [] : [tipe];

    db.query(query, params, (err, results) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        res.json(results);
    });
});

// ── GET /api/jenis_catatan ─────────────────────
router.get('/jenis_catatan', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    db.query('SELECT * FROM jenis_catatan ORDER BY tipe ASC, nama ASC', (err, results) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        res.json(results);
    });
});

// ── POST /api/jenis_catatan ────────────────────
router.post('/jenis_catatan', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    const { nama, poin, tipe } = req.body;

    if (!nama || poin === undefined || !tipe) {
        return res.status(400).json({ error: 'Validasi gagal', message: 'Field nama, poin, dan tipe wajib diisi.' });
    }
    if (!['pelanggaran', 'prestasi'].includes(tipe)) {
        return res.status(400).json({ error: 'Validasi gagal', message: 'Tipe harus pelanggaran atau prestasi.' });
    }

    db.query('INSERT INTO jenis_catatan (nama, poin, tipe) VALUES (?, ?, ?)', [nama, poin, tipe], (err, result) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        res.status(201).json({ message: 'Jenis catatan berhasil ditambahkan', id_jenis: result.insertId });
    });
});

// ── PUT /api/jenis_catatan/:id ─────────────────
router.put('/jenis_catatan/:id', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    const { nama, poin, tipe } = req.body;

    if (!nama || poin === undefined || !tipe) {
        return res.status(400).json({ error: 'Validasi gagal', message: 'Field nama, poin, dan tipe wajib diisi.' });
    }

    db.query('UPDATE jenis_catatan SET nama=?, poin=?, tipe=? WHERE id_jenis=?', [nama, poin, tipe, req.params.id], (err, result) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Data tidak ditemukan' });
        res.json({ message: 'Jenis catatan berhasil diperbarui' });
    });
});

// ── DELETE /api/jenis_catatan/:id ──────────────
router.delete('/jenis_catatan/:id', verifyToken, (req, res) => {
    const db = req.app.locals.db;
    db.query('DELETE FROM jenis_catatan WHERE id_jenis = ?', [req.params.id], (err, result) => {
        if (err) {
            if (err.code === 'ER_ROW_IS_REFERENCED_2') {
                return res.status(409).json({ error: 'Konflik data', message: 'Jenis catatan ini masih digunakan oleh catatan siswa.' });
            }
            return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        }
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Data tidak ditemukan' });
        res.json({ message: 'Jenis catatan berhasil dihapus' });
    });
});

module.exports = router;
