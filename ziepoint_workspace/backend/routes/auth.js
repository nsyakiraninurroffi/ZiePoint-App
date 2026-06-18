// ============================================
// Auth Routes — Guru & Siswa Login
// ============================================

const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

// ── POST /api/login/guru ───────────────────
// Validate guru credentials, return JWT
router.post('/login/guru', (req, res) => {
    const { email, password } = req.body;
    const db = req.app.locals.db;

    if (!email || !password) {
        return res.status(400).json({
            error: 'Validasi gagal',
            message: 'Email dan password harus diisi.'
        });
    }

    const query = 'SELECT * FROM guru WHERE email = ?';
    db.query(query, [email], async (err, results) => {
        if (err) {
            console.error('Login guru error:', err);
            return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        }

        if (results.length === 0) {
            return res.status(401).json({
                error: 'Login gagal',
                message: 'Email atau password salah.'
            });
        }

        const guru = results[0];

        // Support both hashed (bcrypt) and plain-text passwords for migration
        let passwordValid = false;
        if (guru.password && guru.password.startsWith('$2')) {
            passwordValid = await bcrypt.compare(password, guru.password);
        } else {
            passwordValid = (password === guru.password);
        }

        if (!passwordValid) {
            return res.status(401).json({
                error: 'Login gagal',
                message: 'Email atau password salah.'
            });
        }

        // Generate JWT Access Token (short-lived)
        const token = jwt.sign(
            {
                id_guru: guru.id_guru,
                nama: guru.nama,
                email: guru.email,
                role: 'guru'
            },
            process.env.JWT_SECRET,
            { expiresIn: '15m' } // 15 minutes
        );

        // Generate Refresh Token (long-lived)
        const refreshToken = jwt.sign(
            {
                id_guru: guru.id_guru,
                role: 'guru'
            },
            process.env.JWT_SECRET + '_REFRESH',
            { expiresIn: '7d' } // 7 days
        );

        res.json({
            message: 'Login berhasil',
            token,
            refreshToken,
            guru: {
                id_guru: guru.id_guru,
                nama: guru.nama,
                email: guru.email
            }
        });
    });
});

// ── POST /api/login/siswa ──────────────────
// Validate NIS and password using bcrypt, return JWT
router.post('/login/siswa', (req, res) => {
    const { nis, password } = req.body;
    const db = req.app.locals.db;

    if (!nis || !password) {
        return res.status(400).json({
            error: 'Validasi gagal',
            message: 'NIS dan password harus diisi.'
        });
    }

    const query = 'SELECT * FROM siswa WHERE nis = ?';
    db.query(query, [nis], async (err, results) => {
        if (err) {
            console.error('Login siswa error:', err);
            return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        }

        if (results.length === 0) {
            return res.status(401).json({
                error: 'Login gagal',
                message: 'NIS atau password salah.'
            });
        }

        const siswa = results[0];

        // Validate password with bcrypt
        let passwordValid = false;
        if (siswa.password && siswa.password.startsWith('$2')) {
            passwordValid = await bcrypt.compare(password, siswa.password);
        } else {
            // Fallback for plain-text passwords during migration
            passwordValid = (password === siswa.password);
        }

        if (!passwordValid) {
            return res.status(401).json({
                error: 'Login gagal',
                message: 'NIS atau password salah.'
            });
        }

        // Generate JWT Access Token
        const token = jwt.sign(
            {
                id_siswa: siswa.id_siswa,
                nama: siswa.nama,
                nis: siswa.nis,
                role: 'siswa'
            },
            process.env.JWT_SECRET,
            { expiresIn: '15m' }
        );

        // Generate Refresh Token
        const refreshToken = jwt.sign(
            {
                id_siswa: siswa.id_siswa,
                role: 'siswa'
            },
            process.env.JWT_SECRET + '_REFRESH',
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Login berhasil',
            token,
            refreshToken,
            siswa: {
                id_siswa: siswa.id_siswa,
                nama: siswa.nama,
                nis: siswa.nis,
                kelas: siswa.kelas
            }
        });
    });
});

// ── POST /api/refresh ───────────────────────
// Get new access token using a valid refresh token
router.post('/refresh', (req, res) => {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
        return res.status(401).json({ error: 'Akses ditolak', message: 'Refresh token tidak disediakan' });
    }

    try {
        const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET + '_REFRESH');
        const db = req.app.locals.db;

        if (decoded.role === 'guru') {
            db.query('SELECT * FROM guru WHERE id_guru = ?', [decoded.id_guru], (err, results) => {
                if (err || results.length === 0) return res.status(403).json({ error: 'Akses ditolak' });
                const guru = results[0];
                const newToken = jwt.sign(
                    { id_guru: guru.id_guru, nama: guru.nama, email: guru.email, role: 'guru' },
                    process.env.JWT_SECRET,
                    { expiresIn: '15m' }
                );
                return res.json({ token: newToken });
            });
        } else if (decoded.role === 'siswa') {
            db.query('SELECT * FROM siswa WHERE id_siswa = ?', [decoded.id_siswa], (err, results) => {
                if (err || results.length === 0) return res.status(403).json({ error: 'Akses ditolak' });
                const siswa = results[0];
                const newToken = jwt.sign(
                    { id_siswa: siswa.id_siswa, nama: siswa.nama, nis: siswa.nis, role: 'siswa' },
                    process.env.JWT_SECRET,
                    { expiresIn: '15m' }
                );
                return res.json({ token: newToken });
            });
        } else {
            return res.status(403).json({ error: 'Akses ditolak', message: 'Role tidak valid' });
        }
    } catch (e) {
        return res.status(403).json({ error: 'Token kadaluarsa atau tidak valid', message: e.message });
    }
});

module.exports = router;
