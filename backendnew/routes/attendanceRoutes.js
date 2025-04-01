// backend/routes/attendanceRoutes.js
const express = require('express');
const router = express.Router();
const { checkAttendance, getUserAttendance  } = require('../controllers/attendanceController');
const authenticate = require('../middleware/authenticate');

// Endpoint: Checkin / Checkout
router.post('/attendance', authenticate, checkAttendance);

// GET /api/attendance => xem lịch sử chấm công
router.get('/attendance', authenticate, getUserAttendance);

module.exports = router;
