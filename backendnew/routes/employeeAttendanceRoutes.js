// backendnew/routes/employeeAttendanceRoutes.js
const express = require('express');
const router = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole = require('../middleware/checkRole');
const { checkAttendance, getUserAttendance } = require('../controllers/attendanceController');

// Endpoint chấm công/chấm out cho employee
router.post('/attendance', authenticate, checkRole('employee'), checkAttendance);

// Endpoint lấy lịch sử chấm công của employee
router.get('/attendance', authenticate, checkRole('employee'), getUserAttendance);

module.exports = router;
