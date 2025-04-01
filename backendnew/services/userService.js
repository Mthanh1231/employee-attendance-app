// backend/services/userService.js
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { createUser, findUserByEmail, findUserById, updateUserById } = require('../repositories/userRepository');
const userRepository = require('../repositories/userRepository');

const JWT_SECRET = process.env.JWT_SECRET; // nên lưu ở biến môi trường

// Đăng ký
const registerUser = async ({ email, phone, password, confirmPassword }) => {
  if (password !== confirmPassword) {
    throw new Error('Mật khẩu không khớp');
  }
  // Hash mật khẩu
  const hashedPassword = await bcrypt.hash(password, 10);
  // Tạo document mới trong collection "Users"
  const docRefId = require('crypto').randomBytes(10).toString('hex'); // hoặc dùng doc() Firestore
  // Tạo employeeId
  const employeeId = 'EMP-' + docRefId;

  await createUser(docRefId, {
    email,
    phone,
    password: hashedPassword,
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

// Đăng nhập
const loginUser = async ({ email, password }) => {
  const userData = await findUserByEmail(email);
  if (!userData) {
    throw new Error('Email không tồn tại');
  }
  const validPassword = await bcrypt.compare(password, userData.password);
  if (!validPassword) {
    throw new Error('Sai mật khẩu');
  }
  // Tạo token JWT
  const token = jwt.sign({ id: userData.id, email: userData.email }, JWT_SECRET, { expiresIn: '1h' });
  return { token };
};

// Lấy thông tin người dùng
const getProfile = async (userId) => {
  const user = await findUserById(userId);
  if (!user) {
    throw new Error('Không tìm thấy người dùng');
  }
  // Xóa trường password khi trả về
  const { password, ...userData } = user;
  return userData;
};

const updateUserAll = async (userId, data) => {
  // data có thể gồm { phone, name, cccd_info: { place, date, ... } }
  const { cccd_info, ...otherFields } = data;

  if (cccd_info) {
    // Nếu cccd_info có trường 'name', đổi thành cccd_name
    if (cccd_info.name) {
      cccd_info.cccd_name = cccd_info.name;
      delete cccd_info.name;
    }
    // Gộp cccd_info vào otherFields
    otherFields.cccd_info = cccd_info;
  }
  await updateUserById(userId, otherFields);
};

const getAllUsers = async () => {
    const users = await userRepository.getAllUsers();
    // Xóa password khỏi từng user
    const sanitizedUsers = users.map(({ password, ...rest }) => rest);
    return sanitizedUsers;
  };

module.exports = {
  registerUser,
  loginUser,
  getProfile,
  updateUserAll,
  getAllUsers
};
