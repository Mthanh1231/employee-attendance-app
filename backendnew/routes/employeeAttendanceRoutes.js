// backend/routes/employeeAttendanceRoutes.js
const express = require('express');
const router  = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole    = require('../middleware/checkRole');
const { checkAttendance, getUserAttendance } = require('../controllers/attendanceController');

// POST /api/employee/attendance
router.post(
  '/attendance',
  authenticate,
  checkRole('employee'),
  checkAttendance
);

// GET /api/employee/attendance
router.get(
  '/attendance',
  authenticate,
  checkRole('employee'),
  getUserAttendance
);

module.exports = router;
