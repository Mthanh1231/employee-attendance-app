// backend/controllers/attendanceController.js
const attendanceService = require('../services/attendanceService');

/**
 * POST /api/employee/attendance
 * Body: { status, lat, lng }
 */
const checkAttendance = async (req, res) => {
  try {
    const { status, lat, lng } = req.body;
    const result = await attendanceService.markAttendance(
      req.user.id,
      status,
      lat,
      lng
    );

    return res.json({
      message: `Chấm công ${status} thành công`,
      timestamp: result.timestamp,
      note: result.note
    });
  } catch (error) {
    console.error('Lỗi chấm công:', error);
    return res.status(400).json({ message: error.message });
  }
};

/**
 * GET /api/employee/attendance
 */
const getUserAttendance = async (req, res) => {
  try {
    const attendanceList = await attendanceService.getUserAttendance(req.user.id);
    return res.json({ attendance: attendanceList });
  } catch (error) {
    console.error('Lỗi lấy attendance:', error);
    return res.status(400).json({ message: error.message });
  }
};

module.exports = {
  checkAttendance,
  getUserAttendance
};
