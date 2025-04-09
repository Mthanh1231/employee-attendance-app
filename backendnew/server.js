require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors'); 

const userRoutes = require('./routes/userRoutes');
const employeeAttendanceRoutes = require('./routes/employeeAttendanceRoutes');
const managerRoutes = require('./routes/managerRoutes');
const employeeRoutes = require('./routes/employeeRoutes');
const employeeProfileUpdateRoutes = require('./routes/employeeProfileUpdateRoutes');
const managerProfileUpdateRoutes = require('./routes/managerProfileUpdateRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());
app.use(cors()); 

// Đăng ký router
app.use('/api/users', userRoutes);
app.use('/api/employee', employeeAttendanceRoutes);

app.use('/api/manager', managerRoutes);
app.use('/api/employee', employeeRoutes);

app.use('/api/employee', employeeProfileUpdateRoutes); 
app.use('/api/manager', managerProfileUpdateRoutes); 

app.listen(PORT, () => {
  console.log(`Server đang chạy trên cổng ${PORT}`);
});
