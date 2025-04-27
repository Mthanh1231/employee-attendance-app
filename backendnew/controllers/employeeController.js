// controllers/employeeController.js
const employeeService = require('../services/employeeService');
const { processCccdImage } = require('../services/cccdService');

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

// Quét mặt sau
const cccdScanBack = async (req, res) => {
  try {
    const result = await processCccdImage(req.user.id, req.file.path, 'back');
    res.json({ message: 'Quét CCCD mặt sau thành công', result });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: e.message });
  }
};

// Quét mặt trước
const cccdScanFront = async (req, res) => {
  try {
    const result = await processCccdImage(req.user.id, req.file.path, 'front');
    res.json({ message: 'Quét CCCD mặt trước thành công', result });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: e.message });
  }
};


module.exports = {
  registerEmployee,
  loginEmployee,
  getEmployeeProfile,
  cccdScanBack,
  cccdScanFront
};
