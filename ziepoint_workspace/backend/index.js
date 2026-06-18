// ============================================
// ZiePoint Backend — Main Server Entry Point
// ============================================

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');

const app = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ──────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── MySQL Connection Pool ──────────────────
const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test the database connection
db.getConnection((err, connection) => {
    if (err) {
        console.error('❌ Database connection failed:', err.message);
        console.error('   Check your .env file and MySQL service.');
    } else {
        console.log('✅ Connected to MySQL database:', process.env.DB_NAME);
        connection.release();
    }
});

// Make db accessible to routes
app.locals.db = db;

// ── Routes ─────────────────────────────────
const authRoutes = require('./routes/auth');
const siswaRoutes = require('./routes/siswa');
const catatanRoutes = require('./routes/catatan');

app.use('/api', authRoutes);
app.use('/api', siswaRoutes);
app.use('/api', catatanRoutes);

// ── Stats Route ────────────────────────────
app.get('/api/stats/guru', (req, res) => {
    const query = `
        SELECT
            (SELECT COUNT(*) FROM catatan_siswa) AS total_catatan,
            (SELECT COUNT(*) FROM siswa) AS total_siswa,
            (SELECT COUNT(*) FROM catatan_siswa WHERE tipe_jenis = 'pelanggaran') AS total_pelanggaran,
            (SELECT COUNT(*) FROM catatan_siswa WHERE tipe_jenis = 'prestasi') AS total_prestasi
    `;
    // Use a join query instead
    const statsQuery = `
        SELECT
            (SELECT COUNT(*) FROM catatan_siswa) AS total_catatan,
            (SELECT COUNT(*) FROM siswa) AS total_siswa,
            (SELECT COUNT(*) FROM catatan_siswa cs JOIN jenis_catatan jc ON cs.id_jenis = jc.id_jenis WHERE jc.tipe = 'pelanggaran') AS total_pelanggaran,
            (SELECT COUNT(*) FROM catatan_siswa cs JOIN jenis_catatan jc ON cs.id_jenis = jc.id_jenis WHERE jc.tipe = 'prestasi') AS total_prestasi,
            (SELECT COUNT(*) FROM catatan_siswa WHERE DATE(tanggal) = CURDATE()) AS catatan_hari_ini
    `;

    db.query(statsQuery, (err, results) => {
        if (err) return res.status(500).json({ error: 'Kesalahan server', message: err.message });
        res.json(results[0]);
    });
});

// ── Health Check ───────────────────────────
app.get('/', (req, res) => {
    res.json({
        status: 'ok',
        app: 'ZiePoint API',
        version: '2.0.0',
        endpoints: {
            auth: ['/api/login/guru', '/api/login/siswa', '/api/refresh'],
            siswa: [
                'GET /api/siswa',
                'POST /api/siswa',
                'PUT /api/siswa/:id',
                'DELETE /api/siswa/:id',
                'GET /api/siswa/profil',
                'GET /api/siswa/riwayat',
                'GET /api/siswa/leaderboard',
                'GET /api/siswa/kelas',
            ],
            catatan: [
                'GET /api/catatan_siswa',
                'POST /api/catatan_siswa',
                'PUT /api/catatan_siswa/:id',
                'DELETE /api/catatan_siswa/:id',
            ],
            jenisCatatan: [
                'GET /api/jenis_catatan',
                'GET /api/jenis_catatan/:tipe',
                'POST /api/jenis_catatan',
                'PUT /api/jenis_catatan/:id',
                'DELETE /api/jenis_catatan/:id',
            ],
            stats: ['GET /api/stats/guru'],
        }
    });
});

// ── Start Server ───────────────────────────
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 ZiePoint API Server running on port ${PORT}`);
    console.log(`   http://localhost:${PORT}`);
});
