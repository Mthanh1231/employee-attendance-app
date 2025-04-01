// managerRoutes.js
const express = require('express');
const router = express.Router();
const authenticate = require('../middleware/authenticate');
const checkRole = require('../middleware/checkRole');

const {
  loginManager,
  changeManagerPassword,
  getAllEmployees,
  updateEmployeeByManager,
  deleteEmployee
} = require('../controllers/managerController');

// manager login => (nếu manager login? Tùy)
router.post('/login', loginManager);

// manager endpoints
router.put('/change-password', authenticate, checkRole('manager'), changeManagerPassword);
router.get('/employees', authenticate, checkRole('manager'), getAllEmployees);
router.put('/employees/:employeeId', authenticate, checkRole('manager'), updateEmployeeByManager);
router.delete('/employees/:employeeId', authenticate, checkRole('manager'), deleteEmployee);

module.exports = router;
