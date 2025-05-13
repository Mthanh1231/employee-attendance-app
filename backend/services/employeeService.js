// services/employeeService.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { createEmployee, findEmployeeByEmail, findEmployeeByAppId, updateEmployeeById } = require('../repositories/employeeRepository');
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

const registerEmployee = async ({ email, phone, password, confirmPassword }) => {
  if (password !== confirmPassword) {
    throw new Error('Mật khẩu không khớp');
  }
  const hashedPassword = await bcrypt.hash(password, 10);
  const docAppId = require('crypto').randomBytes(10).toString('hex');
  const employeeId = 'EMP-' + docAppId;

  await createEmployee(docAppId, {
    email,
    phone,
    password: hashedPassword,
    role: 'employee',
    employeeId,
    cccd_info: {
      place: null,
      date: null,
      home: null,
      cccd_name: null,
      img: null,
      na: null,
      id: null,
      s: null,
      ddnd: null,
      tg: null
    }
  });

  return employeeId;
};

const loginEmployee = async ({ email, password }) => {
  const userData = await findEmployeeByEmail(email);
  if (!userData) throw new Error('Email không tồn tại');
  const validPassword = await bcrypt.compare(password, userData.password);
  if (!validPassword) throw new Error('Sai mật khẩu');
  
  // Sửa: Tạo token JWT với appId thay vì id
  const token = jwt.sign(
    { appId: userData.id, email: userData.email, role: 'employee' },
    JWT_SECRET,
    { expiresIn: '1h' }
  );
  return { token };
};

const getEmployeeProfile = async (appId) => {
  const user = await findEmployeeByAppId(appId);
  if (!user) throw new Error('Không tìm thấy nhân viên');
  const { password, ...userData } = user;
  return userData;
};

module.exports = {
  registerEmployee,
  loginEmployee,
  getEmployeeProfile,
};
