// ============================================
// JWT Authentication Middleware
// ============================================

const jwt = require('jsonwebtoken');

/**
 * Middleware to verify JWT token from Authorization header.
 * Attaches decoded payload to req.user.
 * 
 * Expected header: Authorization: Bearer <token>
 */
function verifyToken(req, res, next) {
    const authHeader = req.headers['authorization'];

    if (!authHeader) {
        return res.status(401).json({
            error: 'Akses ditolak',
            message: 'Token tidak ditemukan. Silakan login terlebih dahulu.'
        });
    }

    // Support both "Bearer <token>" and raw token
    const token = authHeader.startsWith('Bearer ')
        ? authHeader.slice(7)
        : authHeader;

    if (!token) {
        return res.status(401).json({
            error: 'Akses ditolak',
            message: 'Format token tidak valid.'
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        if (err.name === 'TokenExpiredError') {
            return res.status(401).json({
                error: 'Token kadaluarsa',
                message: 'Sesi Anda telah berakhir. Silakan login kembali.'
            });
        }
        return res.status(403).json({
            error: 'Token tidak valid',
            message: 'Autentikasi gagal.'
        });
    }
}

module.exports = verifyToken;
