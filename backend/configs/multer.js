// backend\configs\multer.js
const multer = require('multer');
const path = require('path');

// Lưu file tạm vào thư mục /uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../uploads'));
  },
  filename: (req, file, cb) => {
    // giữ nguyên tên file kèm timestamp
    const name = Date.now() + '-' + file.originalname;
    cb(null, name);
  }
});

const upload = multer({ storage });

module.exports = upload;

