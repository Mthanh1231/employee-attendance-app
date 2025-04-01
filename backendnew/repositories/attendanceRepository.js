// backend/repositories/attendanceRepository.js
const { db } = require('../configs/firebase');

const attendanceCollection = db.collection('Attendance');

const addAttendance = async ({ userId, timestamp, status }) => {
  await attendanceCollection.add({
    user_id: userId,
    timestamp,
    status
  });
};

const findAttendanceByUser = async (userId) => {
  const snapshot = await attendanceCollection.where('user_id', '==', userId).get();
  const results = [];
  snapshot.forEach(doc => {
    results.push({ id: doc.id, ...doc.data() });
  });
  // Sắp xếp theo timestamp giảm dần (tùy ý)
  results.sort((a, b) => b.timestamp.localeCompare(a.timestamp));
  return results;
};

module.exports = {
  addAttendance,
  findAttendanceByUser
};
