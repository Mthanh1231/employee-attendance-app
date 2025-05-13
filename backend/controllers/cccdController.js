// backend/conrtrollers/cccdController.js

const { processCccdImage } = require('../services/cccdService');

/**
 * POST /api/employee/cccd-scan
 * Single file field: "image"
 */
async function uploadCccd(req, res) {
  try {
    // multer puts file metadata in req.file
    const { file } = req;
    if (!file) {
      return res.status(400).json({ message: 'Vui lòng tải lên ảnh CCCD' });
    }

    // process + update profile
    const cccdInfo = await processCccdImage(req.user.id, file.path);

    // return the newly updated cccd_info
    return res.json({ message: 'CCCD đã được quét', cccd_info: cccdInfo });
  } catch (err) {
    console.error('Lỗi quét CCCD:', err);
    return res.status(500).json({ message: err.message });
  }
}

module.exports = { uploadCccd };
