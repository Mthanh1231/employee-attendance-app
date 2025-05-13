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
      const [year, mon] = month.split('-').map(Number);
      const start = new Date(year, mon - 1, 1);
      const end = endOfMonth(start);
      const allAtt = await attendanceService.getUserAttendance(req.user.id);
      const calendar = [];

      for (let dt = start; dt <= end; dt = addDays(dt, 1)) {
        const dayStr = dt.toISOString().slice(0,10);
        const recs = allAtt.filter(a => a.timestamp.startsWith(dayStr));
        let status = 'none';
        if (attendanceService.isWorkday(dt)) {
          status = recs.some(r=>r.status==='checkin'&&r.status==='checkout') ? 'present' : 'absent';
        } else {
          status = recs.length ? 'ot' : 'none';
        }
        calendar.push({ date: dayStr, status });
      }

      res.json({ calendar });
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  };

  module.exports = { checkAttendance, getAttendanceCalendar, getUserAttendance };