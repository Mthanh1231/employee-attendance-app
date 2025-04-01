// backend/controllers/userController.js
const userService = require('../services/userService');

// Đăng ký
const register = async (req, res) => {
  try {
    const { email, phone, password, confirmPassword } = req.body;
    const employeeId = await userService.registerUser({ email, phone, password, confirmPassword });
    res.status(201).json({ message: 'Đăng ký thành công', employeeId });
  } catch (error) {
    console.error("Lỗi đăng ký:", error);
    res.status(400).json({ message: error.message });
  }
};

// Đăng nhập
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const { token } = await userService.loginUser({ email, password });
    res.json({ message: 'Đăng nhập thành công', token });
  } catch (error) {
    console.error("Lỗi đăng nhập:", error);
    res.status(400).json({ message: error.message });
  }
};

// Xem thông tin cá nhân
const getUserProfile = async (req, res) => {
  try {
    const userData = await userService.getProfile(req.user.id);
    res.json({ user: userData });
  } catch (error) {
    console.error("Lỗi lấy thông tin người dùng:", error);
    res.status(404).json({ message: error.message });
  }
};

const updateUserAll = async (req, res) => {
  try {
    // Body có cả phone, name, cccd_info, ...
    await userService.updateUserAll(req.user.id, req.body);
    res.json({ message: 'Cập nhật toàn bộ thông tin thành công' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getAllUsers = async (req, res) => {
    try {
      const allUsers = await userService.getAllUsers();
      res.json({ users: allUsers });
    } catch (error) {
      console.error("Lỗi lấy danh sách người dùng:", error);
      res.status(500).json({ message: 'Lỗi lấy danh sách người dùng', error: error.message });
    }
  };

module.exports = {
  register,
  login,
  getUserProfile,
  updateUserAll,
  getAllUsers
};
