// services/employeeService.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { createEmployee, findEmployeeByEmail, findEmployeeById, updateEmployeeById } = require('../repositories/employeeRepository');
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

const registerEmployee = async ({ email, phone, password, confirmPassword }) => {
  if (password !== confirmPassword) {
    throw new Error('Mật khẩu không khớp');
  }
  const hashedPassword = await bcrypt.hash(password, 10);
  const docId = require('crypto').randomBytes(10).toString('hex');
  const employeeId = 'EMP-' + docId;

  await createEmployee(docId, {
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
  
  // Tạo token JWT kèm role
  const token = jwt.sign(
    { id: userData.id, email: userData.email, role: 'employee' },
    JWT_SECRET,
    { expiresIn: '1h' }
  );
  return { token };
};

const getEmployeeProfile = async (userId) => {
  const user = await findEmployeeById(userId);
  if (!user) throw new Error('Không tìm thấy nhân viên');
  const { password, ...userData } = user;
  return userData;
};

const updateEmployeeAll = async (userId, data) => {
  const { cccd_info, ...otherFields } = data;
  if (cccd_info) {
    if (cccd_info.name) {
      cccd_info.cccd_name = cccd_info.name;
      delete cccd_info.name;
    }
    otherFields.cccd_info = cccd_info;
  }
  await updateEmployeeById(userId, otherFields);
};

module.exports = {
  registerEmployee,
  loginEmployee,
  getEmployeeProfile,
  updateEmployeeAll
};
