// backendnew/attendanceCron.js

const cron = require('node-cron');
const { subDays, startOfDay } = require('date-fns');

// Đúng: dùng './' vì attendanceCron.js nằm ở thư mục gốc
const { getAllEmployees } = require('./repositories/employeeRepository');
const { findAttendanceByDate, addAttendance } = require('./repositories/attendanceRepository');
const { isWorkday } = require('./services/attendanceService');

// Chạy lúc 00:05 mỗi ngày
cron.schedule('5 0 * * *', async () => {
  console.log('Running absent detection job...');
  const users = await getAllEmployees();
  const yesterday = subDays(new Date(), 1);

  if (isWorkday(yesterday)) {
    for (const u of users) {
      const recs = await findAttendanceByDate(u.id, yesterday);
      if (!recs.checkin || !recs.checkout) {
        await addAttendance({
          userId: u.id,
          timestamp: startOfDay(yesterday).toISOString(),
          status: 'absent',
          lat: null,
          lng: null,
          note: 'Absent'
        });
      }
    }
  }
});
