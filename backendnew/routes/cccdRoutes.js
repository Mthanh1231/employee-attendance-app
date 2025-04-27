// backendnew/routes/cccdRoutes.js

const express = require('express');
const router  = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole    = require('../middleware/checkRole');
const uploadMulter = require('../configs/multer');
const { uploadCccd } = require('../controllers/cccdController');

// only employees can scan their CCCD
router.post(
  '/cccd-scan',
  authenticate,
  checkRole('employee'),
  uploadMulter.single('image'),
  uploadCccd
);

module.exports = router;
