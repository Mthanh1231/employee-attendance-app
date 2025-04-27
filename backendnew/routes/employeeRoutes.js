// routes/employeeRoutes.js
const express = require('express');
const router  = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole    = require('../middleware/checkRole');
const upload       = require('../configs/multer');
const {
  registerEmployee,
  loginEmployee,
  getEmployeeProfile,
  cccdScanBack,
  cccdScanFront
} = require('../controllers/employeeController');

router.post('/register', registerEmployee);
router.post('/login',    loginEmployee);
router.get ('/profile', authenticate, checkRole('employee'), getEmployeeProfile);

// Quét CCCD mặt sau
router.post(
  '/cccd-scan/back',
  authenticate, checkRole('employee'),
  upload.single('file'),
  cccdScanBack
);

// Quét CCCD mặt trước
router.post(
  '/cccd-scan/front',
  authenticate, checkRole('employee'),
  upload.single('file'),
  cccdScanFront
);

module.exports = router;
