  // backend/controllers/attendanceController.js
  const attendanceService = require('../services/attendanceService');
  const { endOfMonth, addDays } = require('date-fns');

  // POST /api/employee/attendance
  const checkAttendance = async (req, res) => {
    try {
      const { status, lat, lng } = req.body;
      const result = await attendanceService.markAttendance(
        req.user.id, status, lat, lng
      );
      res.json({ message: `Chấm công ${status} thành công`, ...result });
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  };

  async function getUserAttendance(req, res) {
    try {
      const attendanceList = await attendanceService.getUserAttendance(req.user.appId);
      res.json({ attendance: attendanceList });
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  }

  // GET /api/employee/attendance/calendar?month=YYYY-MM
  const getAttendanceCalendar = async (req, res) => {
    try {
      const { month } = req.query;
      const { calendar } = await attendanceService.buildCalendar(req.user.id, month);
      res.json({ calendar });
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  };

  module.exports = { checkAttendance, getAttendanceCalendar, getUserAttendance };