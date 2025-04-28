// routes/managerAttendanceRoutes.js
const express = require('express');
const router = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole    = require('../middleware/checkRole');
const {
  getCalendarByUser,
  getAllCalendars
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

module.exports = router;
