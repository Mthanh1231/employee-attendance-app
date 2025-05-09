require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors'); 
require('./attendanceCron');

const employeeAttendanceRoutes = require('./routes/employeeAttendanceRoutes');
const managerRoutes = require('./routes/managerRoutes');
const employeeRoutes = require('./routes/employeeRoutes');
const employeeProfileUpdateRoutes = require('./routes/employeeProfileUpdateRoutes');
const managerProfileUpdateRoutes = require('./routes/managerProfileUpdateRoutes');
const cccdRoutes = require('./routes/cccdRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());
app.use(cors()); 

// Đăng ký router

app.use('/api/employee', employeeAttendanceRoutes);
app.use('/api/employee', require('./routes/employeeAttendanceRoutes'));
app.use('/api/manager',  require('./routes/managerAttendanceRoutes')); 

app.use('/api/manager', managerRoutes);
app.use('/api/employee', employeeRoutes);

app.use('/api/employee', employeeProfileUpdateRoutes); 
app.use('/api/manager', managerProfileUpdateRoutes); 

app.use('/api/employee', cccdRoutes);

app.listen(PORT, () => {
  console.log(`Server đang chạy trên cổng ${PORT}`);
});
