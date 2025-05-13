// controllers/managerController.js
const managerService = require('../services/managerService');

// Đăng nhập manager
const loginManager = async (req, res) => {
  try {
    const { email, password } = req.body;
    const { token } = await managerService.loginManager({ email, password });
    res.json({ message: 'Manager login thành công', token });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Đổi mật khẩu
const changeManagerPassword = async (req, res) => {
  try {
    const { oldPass, newPass } = req.body;
    await managerService.changeManagerPassword(req.user.id, oldPass, newPass);
    res.json({ message: 'Đổi mật khẩu thành công' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Lấy danh sách employee
const getAllEmployees = async (req, res) => {
  try {
    const employees = await managerService.getAllEmployees();
    res.json({ employees });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Sửa thông tin employee
const updateEmployeeByManager = async (req, res) => {
  try {
    const { employeeId } = req.params; 
    await managerService.updateEmployeeByManager(employeeId, req.body);
    res.json({ message: 'Manager sửa employee thành công' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Xóa employee
const deleteEmployee = async (req, res) => {
  try {
    const { employeeId } = req.params;
    await managerService.deleteEmployee(employeeId);
    res.json({ message: 'Xóa employee thành công' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = {
  loginManager,
  changeManagerPassword,
  getAllEmployees,
  updateEmployeeByManager,
  deleteEmployee
};
