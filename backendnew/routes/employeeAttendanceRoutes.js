// backendnew /routes/employeeAttendanceRoutes.js

const express = require('express');
const router = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole = require('../middleware/checkRole');
const {
  checkAttendance,
  getAttendanceCalendar,
  getUserAttendance  // Import the missing controller function
} = require('../controllers/attendanceController');

// POST endpoint for checking in/out
router.post(
  '/attendance',
  authenticate,
  checkRole('employee'),
  checkAttendance
);

// GET endpoint for calendar view
router.get(
  '/attendance/calendar',
  authenticate,
  checkRole('employee'),
  getAttendanceCalendar
);

// Add the missing GET endpoint for attendance history
router.get(
  '/attendance',
  authenticate,
  checkRole('employee'),
  getUserAttendance
);

module.exports = router;