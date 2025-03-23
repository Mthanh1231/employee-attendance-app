// backend/middleware/authenticate.js
const jwt = require('jsonwebtoken');
const JWT_SECRET = 'your_jwt_secret'; // Nên sử dụng biến môi trường để lưu secret

module.exports = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) return res.status(401).json({ message: 'Không có token' });
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(401).json({ message: 'Token không hợp lệ' });
    req.user = decoded;
    next();
  });
};
