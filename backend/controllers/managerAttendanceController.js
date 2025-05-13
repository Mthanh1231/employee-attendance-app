// controllers/managerAttendanceController.js
const attendanceService = require('../services/attendanceService');
const { getAllEmployees } = require('../repositories/employeeRepository');
const { endOfMonth, addDays } = require('date-fns');
const { deleteAllAttendance } = require('../repositories/attendanceRepository');

async function getCalendarByUser(req, res) {
  try {
    // lấy employeeAppId từ query
    const employeeAppId = req.query.employeeId;
    if (!employeeAppId) {
      return res.status(400).json({ message: 'Thiếu employeeId' });
    }

    // tái sử dụng service: trả về calendar của employeeAppId
    const { calendar } = await attendanceService.buildCalendar(employeeAppId, req.query.month);
    res.json({ employeeId: employeeAppId, calendar });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
}

async function getAllCalendars(req, res) {
  try {
    const month = req.query.month;
    const employees = await getAllEmployees();
    const result = [];

    for (const emp of employees) {
      const { calendar } = await attendanceService.buildCalendar(emp.id, month);
      result.push({ employeeId: emp.id, calendar });
    }

    res.json({ data: result });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
}

async function clearAllAttendance(req, res) {
  try {
    await deleteAllAttendance();
    return res.json({ message: 'Đã xóa toàn bộ lịch sử chấm công' });
  } catch (err) {
    console.error('Xóa attendance lỗi:', err);
    return res.status(500).json({ message: 'Xóa không thành công' });
  }
}

module.exports = { getCalendarByUser, getAllCalendars, clearAllAttendance     };
