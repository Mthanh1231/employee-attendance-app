// controllers/employeeController.js
const employeeService = require('../services/employeeService');

// Đăng ký
const registerEmployee = async (req, res) => {
  try {
    const { email, phone, password, confirmPassword } = req.body;
    const employeeId = await employeeService.registerEmployee({ email, phone, password, confirmPassword });
    res.status(201).json({ message: 'Đăng ký thành công', employeeId });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Đăng nhập
const loginEmployee = async (req, res) => {
  try {
    const { email, password } = req.body;
    const { token } = await employeeService.loginEmployee({ email, password });
    res.json({ message: 'Đăng nhập thành công', token });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Xem thông tin
const getEmployeeProfile = async (req, res) => {
  try {
    const userData = await employeeService.getEmployeeProfile(req.user.id);
    res.json({ user: userData });
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

// Cập nhật thông tin (gộp cccd_info)
const updateEmployeeAll = async (req, res) => {
  try {
    await employeeService.updateEmployeeAll(req.user.id, req.body);
    res.json({ message: 'Cập nhật thông tin thành công' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = {
  registerEmployee,
  loginEmployee,
  getEmployeeProfile,
  updateEmployeeAll
};
