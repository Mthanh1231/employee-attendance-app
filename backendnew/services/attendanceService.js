// backend/services/attendanceService.js
require('dotenv').config();
const { getMachineConfig } = require('../repositories/configRepository');
const { addAttendance, findAttendanceByUser, findLastAttendance } = require('../repositories/attendanceRepository');

/**
 * Convert degrees → radians.
 */
function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

/**
 * Haversine formula: compute distance (in meters) between two lat/lng points.
 */
function getDistanceInMeters(lat1, lon1, lat2, lon2) {
  const R = 6371e3; // Earth radius in meters
  const φ1 = deg2rad(lat1);
  const φ2 = deg2rad(lat2);
  const Δφ = deg2rad(lat2 - lat1);
  const Δλ = deg2rad(lon2 - lon1);

  const a =
    Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
    Math.cos(φ1) * Math.cos(φ2) *
    Math.sin(Δλ / 2) * Math.sin(Δλ / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * Mark attendance for a user.
 * @param {string} userId     Firestore Users doc ID
 * @param {'checkin'|'checkout'} status
 * @param {number} lat        Employee latitude
 * @param {number} lng        Employee longitude
 * @returns {Promise<{ timestamp: string, note: string }>}
 */
const markAttendance = async (userId, status, lat, lng) => {
  // 1) Validate status
  if (!['checkin', 'checkout'].includes(status)) {
    throw new Error('Trạng thái không hợp lệ');
  }
  // 2) Validate coordinates
  if (typeof lat !== 'number' || typeof lng !== 'number') {
    throw new Error('Thiếu hoặc sai định dạng vị trí');
  }

  // 3) Read machine config from Firestore
const { lat: machineLat, lng: machineLng, radius: threshold } = await getMachineConfig();

  // 4) Distance check
  const dist = getDistanceInMeters(machineLat, machineLng, lat, lng);
  if (dist > threshold) {
    throw new Error(`Vị trí không hợp lệ (cách máy ${dist.toFixed(1)} m, quá ngưỡng ${threshold} m)`);
  }

  // 3) Check for “forgotten checkout” from previous day
  const last = await findLastAttendance(userId);
  if (last && last.status === 'checkin') {
    const lastDate = new Date(last.timestamp).toDateString();
    const todayDate = new Date().toDateString();
    if (lastDate !== todayDate) {
      // auto‑checkout at midnight
      const midnight = new Date();
      midnight.setHours(0, 0, 0, 0);
      await addAttendance({
        userId,
        timestamp: midnight.toISOString(),
        status: 'checkout',
        lat: machineLat,
        lng: machineLng,
        note: 'Auto‑checkout at 00:00'
      });
    }
  }

  // 4) Compute note for this new action
  const now = new Date();
  let note = '';
  if (status === 'checkin') {
    const sched = new Date(now); sched.setHours(8, 0, 0, 0);
    const diffMin = Math.floor((now - sched)/60000);
    if (diffMin > 0) note = `Late ${diffMin} minutes`;
  } else {
    const sched = new Date(now); sched.setHours(17, 0, 0, 0);
    const diffMin = Math.floor((now - sched)/60000);
    if (diffMin < 0)      note = `Early ${-diffMin} minutes`;
    else if (diffMin > 0) note = `OT ${diffMin} minutes`;
  }

  // 5) Persist the user’s intended record
  const timestamp = now.toISOString();
  await addAttendance({ userId, timestamp, status, lat, lng, note });
  return { timestamp, note };
};

/**
 * Retrieve a user’s full attendance history.
 */
const getUserAttendance = async (userId) => {
  return await findAttendanceByUser(userId);
};

module.exports = {
  markAttendance,
  getUserAttendance
};