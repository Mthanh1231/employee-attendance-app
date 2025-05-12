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

router.get('/profile', authenticate, checkRole('manager'), async (req, res) => {
  const { findManagerById } = require('../repositories/managerRepository');
  try {
    const manager = await findManagerById(req.user.id);
    if (!manager) return res.status(404).json({ message: 'Manager not found' });
    const { password, ...managerInfo } = manager;
    res.json(managerInfo);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
