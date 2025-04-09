// backendnew/routes/employeeProfileUpdateRoutes.js
const express = require('express');
const router = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole    = require('../middleware/checkRole');
const { submitProfileUpdateRequest } = require('../controllers/profileUpdateRequestController');

router.post(
  '/profile-update-request',
  authenticate,
  checkRole('employee'),
  submitProfileUpdateRequest
);

module.exports = router;
