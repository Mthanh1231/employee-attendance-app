// backendnew /routes/employeeAttendanceRoutes.js
const express = require('express');
const router = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole = require('../middleware/checkRole');
const {
  checkAttendance,
  getAttendanceCalendar,
  getUserAttendance
} = require('../controllers/attendanceController');

router.post(
  '/attendance',
  authenticate,
  checkRole('employee'),
  checkAttendance
);

router.get(
  '/attendance/calendar',
  authenticate,
  checkRole('employee'),
  getAttendanceCalendar
);

module.exports = router;