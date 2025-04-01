// backend/controllers/attendanceController.js
const attendanceService = require('../services/attendanceService');

const checkAttendance = async (req, res) => {
  try {
    const { status } = req.body; // 'checkin' hoặc 'checkout'
    const result = await attendanceService.markAttendance(req.user.id, status);
    res.json({
      message: `Chấm công ${status} thành công`,
      timestamp: result.timestamp
    });
  } catch (error) {
    console.error("Lỗi chấm công:", error);
    res.status(400).json({ message: error.message });
  }
};
const getUserAttendance = async (req, res) => {
  try {
    const attendanceList = await attendanceService.getUserAttendance(req.user.id);
    res.json({ attendance: attendanceList });
  } catch (error) {
    console.error("Lỗi lấy attendance:", error);
    res.status(400).json({ message: error.message });
  }
};

module.exports = {
  checkAttendance,
  getUserAttendance
};
