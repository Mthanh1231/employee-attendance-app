// services/cccdService.js
const axios     = require('axios');
const fs        = require('fs');
const FormData  = require('form-data');
const { updateEmployeeById } = require('../repositories/employeeRepository');

// Lấy từ .env
const backUrl  = process.env.CCCD_BACK_API;
const frontUrl = process.env.CCCD_FRONT_API;

/**
 * Gửi file lên Python OCR pipeline (front hoặc back),
 * cập nhật cccd_info tương ứng.
 */
async function processCccdImage(userId, filePath, side) {
  const url = side === 'front' ? frontUrl : backUrl;
  const form = new FormData();
  form.append('file', fs.createReadStream(filePath));

  const resp = await axios.post(url, form, {
    headers: form.getHeaders(),
    timeout: 60000
  });

  const { ocr_results, warped_image_path } = resp.data;

  // Map chung cho cả front/back
  const cccd_info = {
    front:  null,
    back:   null
  };

  // Nếu là front, lưu vào cccd_info.front
  if (side === 'front') {
    cccd_info.front = {
      warped_image_path,
      fields: ocr_results
    };
  } else {
    cccd_info.back = {
      warped_image_path,
      fields: ocr_results
    };
  }

  // Cập nhật Firestore: gộp với cccd_info đã có (nếu quét 2 lần)
  await updateEmployeeById(userId, { [`cccd_info.${side}`]: cccd_info[side] });

  return cccd_info[side];
}

module.exports = { processCccdImage };
