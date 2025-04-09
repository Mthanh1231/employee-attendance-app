// backendnew/routes/managerProfileUpdateRoutes.js
const express = require('express');
const router = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole    = require('../middleware/checkRole');
const {
  getProfileUpdateRequests,
  processProfileUpdateRequest
} = require('../controllers/profileUpdateRequestController');

router.get(
  '/profile-update-requests',
  authenticate,
  checkRole('manager'),
  getProfileUpdateRequests
);

router.put(
  '/profile-update-requests/:requestId',
  authenticate,
  checkRole('manager'),
  processProfileUpdateRequest
);

module.exports = router;
