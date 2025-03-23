// backend/server.js
const express = require('express');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Đảm bảo file này có trong thư mục backend

const app = express();
const PORT = process.env.PORT || 3000;

// Khởi tạo Firebase Admin SDK với service account key
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();

// Cấu hình middleware
app.use(bodyParser.json());

// Secret key cho JWT (nên lưu ở biến môi trường)
const JWT_SECRET = 'your_jwt_secret';

// ----------------------
// Endpoint: Đăng ký tài khoản
// Chỉ yêu cầu: email, phone, password, confirmPassword
// Mỗi người dùng đăng ký thành công sẽ có thêm trường employeeId
// ----------------------
app.post('/register', async (req, res) => {
  const { email, phone, password, confirmPassword } = req.body;

  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'Mật khẩu không khớp' });
  }
  try {
    // Hash mật khẩu
    const hashedPassword = await bcrypt.hash(password, 10);
    // Tạo document mới trong collection "Users"
    const userRef = db.collection('Users').doc();
    // Tạo employeeId bằng cách thêm tiền tố "EMP-" vào id của document
    const employeeId = "EMP-" + userRef.id;
    // Lưu thông tin người dùng vào Firestore với employeeId và cccd_info ban đầu là null
    await userRef.set({
      email,
      phone,
      password: hashedPassword,
      employeeId,
      cccd_info: {
        place: null,
        date: null,
        home: null,
        cccd_name: null,  // tên quét từ CCCD
        img: null,
        na: null,
        id: null,
        s: null,
        ddnd: null,
        tg: null
      }
    });
    res.status(201).json({ message: 'Đăng ký thành công', employeeId });
  } catch (error) {
    console.error("Lỗi đăng ký:", error);
    res.status(500).json({ message: 'Lỗi đăng ký', error: error.message });
  }
});

// ----------------------
// Endpoint: Đăng nhập
// ----------------------
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    // Tìm kiếm người dùng theo email
    const snapshot = await db.collection('Users').where('email', '==', email).get();
    if (snapshot.empty) {
      return res.status(400).json({ message: 'Email không tồn tại' });
    }
    let userData;
    snapshot.forEach(doc => {
      userData = { id: doc.id, ...doc.data() };
    });
    // So sánh mật khẩu đã hash
    const validPassword = await bcrypt.compare(password, userData.password);
    if (!validPassword) {
      return res.status(400).json({ message: 'Sai mật khẩu' });
    }
    // Tạo token JWT
    const token = jwt.sign({ id: userData.id, email: userData.email }, JWT_SECRET, { expiresIn: '1h' });
    res.json({ message: 'Đăng nhập thành công', token });
  } catch (error) {
    console.error("Lỗi đăng nhập:", error);
    res.status(500).json({ message: 'Lỗi đăng nhập', error: error.message });
  }
});

// Import middleware xác thực JWT
const authenticate = require('./middleware/authenticate');

// ----------------------
// Endpoint: Xem thông tin cá nhân
// ----------------------
app.get('/profile', authenticate, async (req, res) => {
  try {
    const userRef = await db.collection('Users').doc(req.user.id).get();
    if (!userRef.exists) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }
    // Loại bỏ trường password khi trả về thông tin người dùng
    const { password, ...userData } = userRef.data();
    res.json({ user: userData });
  } catch (error) {
    console.error("Lỗi lấy thông tin người dùng:", error);
    res.status(500).json({ message: 'Lỗi lấy thông tin', error: error.message });
  }
});

// ----------------------
// Endpoint: Cập nhật thông tin cá nhân (sửa thông tin chung)
// ----------------------
app.put('/profile', authenticate, async (req, res) => {
  const updateData = req.body;
  try {
    await db.collection('Users').doc(req.user.id).update(updateData);
    res.json({ message: 'Cập nhật thành công' });
  } catch (error) {
    console.error("Lỗi cập nhật thông tin:", error);
    res.status(500).json({ message: 'Lỗi cập nhật thông tin', error: error.message });
  }
});

// ----------------------
// Endpoint: Cập nhật thông tin CCCD (xác thực qua căn cước)
// ----------------------
app.put('/profile/cccd', authenticate, async (req, res) => {
  // Dữ liệu từ quá trình quét CCCD, ví dụ:
  // {
  //   "place": "Thôn Tú Linh., Tân Bình., TP. Thái Bình., Thái Bình.",
  //   "date": "21/04/1994",
  //   "home": "Tân Bình., TP. Thái Bình., Thái Bình.",
  //   "name": "NGUYỄN ĐÌNH QUÝ.",
  //   "img": "../../data/img/croptrc/img_1.jpg",
  //   "na": ". Việt Nam.",
  //   "id": "034094005502.",
  //   "s": "Nam.",
  //   "ddnd": "Nốt ruồi: C1 2cm dưới mép., trái.",
  //   "tg": ", , "
  // }
  const cccdData = req.body;
  // Đổi key "name" thành "cccd_name" để không ghi đè thông tin cá nhân cơ bản
  if (cccdData.name) {
    cccdData.cccd_name = cccdData.name;
    delete cccdData.name;
  }
  try {
    await db.collection('Users').doc(req.user.id).update({
      cccd_info: cccdData
    });
    res.json({ message: 'Cập nhật thông tin CCCD thành công', cccd_info: cccdData });
  } catch (error) {
    console.error("Lỗi cập nhật thông tin CCCD:", error);
    res.status(500).json({ message: 'Lỗi cập nhật thông tin CCCD', error: error.message });
  }
});

// Import router chấm công (nếu có)
const attendanceRoutes = require('./attendance');
app.use('/api', attendanceRoutes);

// Khởi chạy server
app.listen(PORT, () => {
  console.log(`Server đang chạy trên cổng ${PORT}`);
});
