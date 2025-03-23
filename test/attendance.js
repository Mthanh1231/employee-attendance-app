// backend/attendance.js
const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = admin.firestore();
const authenticate = require('./middleware/authenticate');

// Endpoint: Chấm công (check-in / check-out)
router.post('/attendance', authenticate, async (req, res) => {
  const { status } = req.body; // status: 'checkin' hoặc 'checkout'
  const timestamp = new Date().toISOString();
  try {
    await db.collection('Attendance').add({
      user_id: req.user.id,
      timestamp,
      status,
    });
    res.json({ message: `Chấm công ${status} thành công`, timestamp });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi chấm công', error });
  }
});

module.exports = router;
