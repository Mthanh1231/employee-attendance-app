// backend/repositories/attendanceRepository.js
const { db } = require('../configs/firebase');
const attendanceCollection = db.collection('Attendance');

const addAttendance = async ({ userId, timestamp, status, lat, lng, note }) => {
  await attendanceCollection.add({
    user_id: userId,
    timestamp,
    status,
    lat,
    lng,
    note
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

// Lấy attendance của user trong ngày cụ thể
const findAttendanceByDate = async (userId, date) => {
  const dayStart = new Date(date);
  dayStart.setHours(0,0,0,0);
  const dayEnd = new Date(date);
  dayEnd.setHours(23,59,59,999);
  const snapshot = await attendanceCollection
    .where('user_id','==',userId)
    .where('timestamp','>=', dayStart.toISOString())
    .where('timestamp','<=', dayEnd.toISOString())
    .get();
  const recs = { checkin: false, checkout: false, absent: false };
  snapshot.forEach(doc => {
    const { status } = doc.data();
    recs[status] = true;
  });
  return recs;
};

async function deleteAllAttendance() {
  const snapshot = await attendanceCollection.get();
  const batch = db.batch();
  snapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });
  await batch.commit();
}

module.exports = { addAttendance, findAttendanceByUser, findLastAttendance, findAttendanceByDate, deleteAllAttendance  };