// backend/routes/userRoutes.js
const express = require('express');
const router = express.Router();
const { register, login, getUserProfile, updateUserAll, getAllUsers } = require('../controllers/userController');
const authenticate = require('../middleware/authenticate');

// Đăng ký
router.post('/register', register);

// Đăng nhập
router.post('/login', login);

// Xem thông tin cá nhân
router.get('/profile', authenticate, getUserProfile);

// Cập nhật thông tin người dùng
router.put('/profile', authenticate, updateUserAll);

// Lấy danh sách tất cả người dùng
router.get('/all', getAllUsers);

module.exports = router;
