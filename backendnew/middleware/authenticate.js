// backend/middleware/authenticate.js
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || '1312';

module.exports = (req, res, next) => {
  // Lấy header
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return res.status(401).json({ message: 'Không có token' });
  }

  // Hỗ trợ cả 2 dạng: "Bearer <token>" hoặc chỉ "<token>"
  const token = authHeader.startsWith('Bearer ')
    ? authHeader.slice(7).trim()
    : authHeader.trim();

  // Verify JWT
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(401).json({ message: 'Token không hợp lệ' });
    }
    req.user = decoded; // gán thông tin user từ payload
    next();
  });
};
