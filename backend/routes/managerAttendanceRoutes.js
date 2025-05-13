// routes/managerAttendanceRoutes.js
const express = require('express');
const router = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole    = require('../middleware/checkRole');
const {
  getCalendarByUser,
  getAllCalendars,
  clearAllAttendance   
} = require('../controllers/managerAttendanceController');

router.get(
  '/attendance/calendar',
  authenticate,
  checkRole('manager'),
  getCalendarByUser
);

router.get(
  '/attendance/calendars',
  authenticate,
  checkRole('manager'),
  getAllCalendars
);

router.delete(
  '/attendance',
  authenticate,
  checkRole('manager'),
  clearAllAttendance
);

module.exports = router;
