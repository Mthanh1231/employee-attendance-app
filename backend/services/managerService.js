// services/managerService.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { findManagerByEmail, findManagerById, updateManagerById } = require('../repositories/managerRepository');
const { getAllEmployees } = require('../repositories/employeeRepository'); // Sửa: import hàm getAllEmployees
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

// Manager login
const loginManager = async ({ email, password }) => {
  const managerData = await findManagerByEmail(email);
  if (!managerData) throw new Error('Manager email không tồn tại');
  const validPassword = await bcrypt.compare(password, managerData.password);
  if (!validPassword) throw new Error('Sai mật khẩu manager');
  
  // Tạo token JWT
  const token = jwt.sign(
    { id: managerData.id, email: managerData.email, role: 'manager' },
    JWT_SECRET,
    { expiresIn: '1h' }
  );
  return { token };
};

// Đổi mật khẩu manager
const changeManagerPassword = async (managerId, oldPass, newPass) => {
  const manager = await findManagerById(managerId);
  if (!manager) throw new Error('Manager not found');
  const validPassword = await bcrypt.compare(oldPass, manager.password);
  if (!validPassword) throw new Error('Sai mật khẩu cũ');
  const hashed = await bcrypt.hash(newPass, 10);
  await updateManagerById(managerId, { password: hashed });
};

// Lấy danh sách employee
const getAllEmployeesManager = async () => {
  const employees = await getAllEmployees();
  return employees;
};

// Sửa thông tin employee
const updateEmployeeByManager = async (employeeId, data) => {
  // Giả sử employeeRepository có hàm updateEmployeeById
  const { updateEmployeeById } = require('../repositories/employeeRepository');
  await updateEmployeeById(employeeId, data);
};

// Xóa employee (ví dụ: xóa thật)
const deleteEmployee = async (employeeId) => {
  const { deleteEmployeeById } = require('../repositories/employeeRepository');
  await deleteEmployeeById(employeeId);
};

module.exports = {
  loginManager,
  changeManagerPassword,
  getAllEmployees: getAllEmployeesManager,
  updateEmployeeByManager,
  deleteEmployee
};
