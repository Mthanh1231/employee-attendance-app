// backend/services/attendanceService.js
require('dotenv').config();
const { addAttendance, findAttendanceByUser } = require('../repositories/attendanceRepository');

// Haversine để tính khoảng cách (đơn vị: mét) :contentReference[oaicite:0]{index=0}
function deg2rad(deg) { return deg * (Math.PI / 180); }
function getDistanceInMeters(lat1, lon1, lat2, lon2) {
  const R = 6371e3; // bán kính Trái Đất (m)
  const φ1 = deg2rad(lat1), φ2 = deg2rad(lat2);
  const Δφ = deg2rad(lat2 - lat1), Δλ = deg2rad(lon2 - lon1);
  const a = Math.sin(Δφ/2)**2 + Math.cos(φ1)*Math.cos(φ2)*Math.sin(Δλ/2)**2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

const markAttendance = async (userId, status, lat, lng) => {
  if (!['checkin', 'checkout'].includes(status)) {
    throw new Error('Trạng thái không hợp lệ');
  }
  if (typeof lat !== 'number' || typeof lng !== 'number') {
    throw new Error('Thiếu hoặc sai định dạng vị trí');
  }

  // Lấy cấu hình máy
  const machineLat = parseFloat(process.env.MACHINE_LAT);
  const machineLng = parseFloat(process.env.MACHINE_LNG);
  const threshold  = parseFloat(process.env.MACHINE_RADIUS) || 100;

  // Tính khoảng cách
  const dist = getDistanceInMeters(machineLat, machineLng, lat, lng);
  if (dist > threshold) {
    throw new Error(`Vị trí không hợp lệ (cách máy ${dist.toFixed(1)} m, quá ngưỡng ${threshold} m)`);
  }

  const timestamp = new Date().toISOString();
  await addAttendance({ userId, timestamp, status, lat, lng });
  return { timestamp };
};

const getUserAttendance = async (userId) => {
  return await findAttendanceByUser(userId);
};

module.exports = {
  markAttendance,
  getUserAttendance
};
