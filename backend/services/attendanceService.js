// backend/services/attendanceService.js

require('dotenv').config();
const { getMachineConfig } = require('../repositories/configRepository');
const {
  addAttendance,
  findAttendanceByUser,
  findLastAttendance
} = require('../repositories/attendanceRepository');
const {
  isWeekend,
  getDay,
  startOfDay,
  format,
  endOfMonth,
  addDays
} = require('date-fns');
const {
  zonedTimeToUtc,
  utcToZonedTime
} = require('date-fns-tz');

// Timezone constant
const TIMEZONE = 'Asia/Ho_Chi_Minh';

// Convert local time to UTC for storage
function toUTC(date) {
  return zonedTimeToUtc(date, TIMEZONE);
}

// Convert UTC to local time for display
function toLocal(utcDate) {
  return utcToZonedTime(utcDate, TIMEZONE);
}

// 0 = Sunday … 6 = Saturday; workdays = Mon (1) → Fri (5)
function isWorkday(date) {
  const localDate = toLocal(date);
  const d = getDay(localDate);
  return d >= 1 && d <= 5;
}

// Haversine formula to compute distance in meters :contentReference[oaicite:0]{index=0}
function deg2rad(deg) {
  return deg * (Math.PI / 180);
}
function getDistanceInMeters(lat1, lon1, lat2, lon2) {
  const R = 6371e3; // Earth's radius in meters
  const φ1 = deg2rad(lat1);
  const φ2 = deg2rad(lat2);
  const Δφ = deg2rad(lat2 - lat1);
  const Δλ = deg2rad(lon2 - lon1);
  const a =
    Math.sin(Δφ/2) * Math.sin(Δφ/2) +
    Math.cos(φ1) * Math.cos(φ2) *
    Math.sin(Δλ/2) * Math.sin(Δλ/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Core attendance action
async function markAttendance(userId, status, lat, lng) {
  if (!['checkin','checkout'].includes(status)) {
    throw new Error('Trạng thái không hợp lệ');
  }
  if ((lat != null && typeof lat !== 'number') ||
      (lng != null && typeof lng !== 'number')) {
    throw new Error('Thiếu hoặc sai định dạng vị trí');
  }

  const now = toUTC(new Date());
  const workday = isWorkday(now);
  const weekend = isWeekend(now);

  // Location check for weekdays only
  if (!weekend) {
    const { lat: mLat, lng: mLng, radius } = await getMachineConfig();
    const dist = getDistanceInMeters(mLat, mLng, lat, lng);
    if (dist > radius) {
      throw new Error(`Vị trí không hợp lệ (cách máy ${dist.toFixed(1)} m)`);  
    }
  }

  // Autocheckout at midnight if forgot checkout on a workday
  if (workday) {
    const last = await findLastAttendance(userId);
    if (last?.status === 'checkin') {
      const lastDate = toLocal(new Date(last.timestamp)).toDateString();
      const todayDate = toLocal(now).toDateString();
      if (lastDate !== todayDate) {
        await addAttendance({
          userId,
          timestamp: toUTC(startOfDay(now)).toISOString(),
          status: 'checkout',
          lat: null,
          lng: null,
          note: 'Autocheckout at 00:00'
        });
      }
    }
  }

  // Compute note (early/late/OT), still record actual timestamp
  let note = '';
  if (status === 'checkin') {
    const localNow = toLocal(now);
    const sched = new Date(localNow); 
    sched.setHours(8,0,0,0);
    const delta = Math.floor((localNow - sched) / 60000);
    if (delta > 0)      note = `Late ${delta} minutes`;
    else if (delta < 0) note = `Early ${Math.abs(delta)} minutes`;
  } else { // checkout
    const localNow = toLocal(now);
    const sched = new Date(localNow); 
    sched.setHours(17,0,0,0);
    const delta = Math.floor((localNow - sched) / 60000);
    if (delta > 0)      note = `OT ${delta} minutes`;
    else if (delta < 0) note = `Early ${Math.abs(delta)} minutes`;
  }

  await addAttendance({
    userId,
    timestamp: now.toISOString(),
    status,
    lat,
    lng,
    note
  });
  return { timestamp: now.toISOString(), note };
}

// Fetch raw attendance history
async function getUserAttendance(userId) {
  return await findAttendanceByUser(userId);
}

// Build a month-view calendar with status + detail per day
async function buildCalendar(userId, monthParam) {
  // "YYYY-MM" or default to current month :contentReference[oaicite:1]{index=1}
  const monthStr = monthParam || format(new Date(), 'yyyy-MM');
  const [year, mon] = monthStr.split('-').map(Number);
  const start = new Date(year, mon - 1, 1);
  const end   = endOfMonth(start);

  // Load all records once per user
  const allAtt = await findAttendanceByUser(userId);
  const calendar = [];

  for (let dt = start; dt <= end; dt = addDays(dt,1)) {
    const localDt = toLocal(dt);
    const recs = allAtt.filter(a => {
      const attDate = toLocal(new Date(a.timestamp));
      return attDate.getFullYear() === localDt.getFullYear() &&
             attDate.getMonth() === localDt.getMonth() &&
             attDate.getDate() === localDt.getDate();
    });
    let status  = 'none';
    let detail  = null;

    if (isWorkday(localDt)) {
      // Must have both to be "present"
      const ins  = recs.filter(r=>r.status==='checkin')
                       .map(r=>toLocal(new Date(r.timestamp)));
      const outs = recs.filter(r=>r.status==='checkout')
                       .map(r=>toLocal(new Date(r.timestamp)));

      if (ins.length && outs.length) {
        status = 'present';

        // Clamp earliest in to ≥08:00, latest out to ≤17:00
        const day8  = new Date(localDt); day8.setHours( 8,0,0,0);
        const day17 = new Date(localDt); day17.setHours(17,0,0,0);
        const earliestIn = new Date(Math.min(...ins));
        const latestOut   = new Date(Math.max(...outs));
        const clampIn   = earliestIn  < day8  ? day8  : earliestIn;
        const clampOut  = latestOut   > day17 ? day17 : latestOut;

        // Compute worked hours
        const hrsWorked = (clampOut - clampIn) / 36e5; // ms→h

        if (hrsWorked >= 8) {
          detail = 'full';
        } else {
          detail = `need more effort (${(8 - hrsWorked).toFixed(2)}h missing)`;
        }
      } else {
        status = 'absent';
        detail = 'absent';
      }
    } else {
      // Weekend
      status = recs.length ? 'ot' : 'none';
      detail = recs.length ? 'ot' : null;
    }

    calendar.push({ date: localDt.toISOString().slice(0,10), status, detail });
  }

  return { calendar };
}

module.exports = {
  markAttendance,
  getUserAttendance,
  isWorkday,
  buildCalendar
};
