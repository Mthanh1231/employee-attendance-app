// backend/repositories/attendanceRepository.js
const { db } = require('../configs/firebase');
const attendanceCollection = db.collection('Attendance');

/**
 * @param {Object} params
 * @param {string} params.userId
 * @param {string} params.timestamp    ISO string
 * @param {string} params.status       'checkin'|'checkout'
 * @param {number} params.lat
 * @param {number} params.lng
 * @param {string} params.note         e.g. 'Late 5 minutes', 'Early 10 minutes', 'OT 20 minutes'
 */

const addAttendance = async ({ userId, timestamp, status, lat, lng }) => {
  await attendanceCollection.add({
    user_id: userId,
    timestamp,
    status,
    lat,
    lng
  });
};

const findAttendanceByUser = async (userId) => {
  const snapshot = await attendanceCollection
    .where('user_id', '==', userId)
    .orderBy('timestamp', 'desc')
    .get();
  const results = [];
  snapshot.forEach(doc => results.push({ id: doc.id, ...doc.data() }));
  return results;
};

const findLastAttendance = async (userId) => {
  const snapshot = await attendanceCollection
    .where('user_id', '==', userId)
    .orderBy('timestamp', 'desc')
    .limit(1)
    .get();
  if (snapshot.empty) return null;
  const doc = snapshot.docs[0];
  return { id: doc.id, ...doc.data() };
};

module.exports = {
  addAttendance,
  findAttendanceByUser,
  findLastAttendance
};
