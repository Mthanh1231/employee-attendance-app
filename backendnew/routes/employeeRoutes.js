// routes/employeeRoutes.js
const express = require('express');
const router = express.Router();
const { registerEmployee, loginEmployee, getEmployeeProfile, updateEmployeeAll } = require('../controllers/employeeController');
const authenticate = require('../middleware/authenticate');

// Đăng ký employee
router.post('/register', registerEmployee);
// Đăng nhập employee
router.post('/login', loginEmployee);

// Xem thông tin cá nhân
router.get('/profile', authenticate, getEmployeeProfile);

module.exports = router;
