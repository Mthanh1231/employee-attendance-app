// backend/services/attendanceService.js
const { addAttendance, findAttendanceByUser  } = require('../repositories/attendanceRepository');

const markAttendance = async (userId, status) => {
  if (!['checkin', 'checkout'].includes(status)) {
    throw new Error('Trạng thái không hợp lệ');
  }
  const timestamp = new Date().toISOString();
  await addAttendance({ userId, timestamp, status });
  return { timestamp };
};
const getUserAttendance = async (userId) => {
  return await findAttendanceByUser(userId);
};

module.exports = {
  markAttendance,
  getUserAttendance
};
