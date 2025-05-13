// backend/middleware/checkRole.js

/**
 * Middleware kiểm tra role của người dùng.
 * Nếu req.user.role không bằng requiredRole, trả về 403 Forbidden.
 *
 * Cách sử dụng:
 *   router.get('/employees', authenticate, checkRole('manager'), getAllEmployees);
 */
module.exports = function(requiredRole) {
  return (req, res, next) => {
    if (!req.user || req.user.role !== requiredRole) {
      return res.status(403).json({ message: 'Forbidden: insufficient permissions' });
    }
    next();
  };
};
