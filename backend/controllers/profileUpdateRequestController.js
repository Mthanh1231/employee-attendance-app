// backend/controllers/profileUpdateRequestController.js
const svc = require('../services/profileUpdateRequestService');

const submitProfileUpdateRequest = async (req, res) => {
  try {
    const employeeId = req.user.appId;
    const requestId = await svc.submitProfileUpdateRequest(employeeId, req.body);
    res.status(201).json({ message: 'Yêu cầu đã gửi', requestId });
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
};

const getProfileUpdateRequests = async (req, res) => {
  try {
    const requests = await svc.getPendingProfileUpdateRequests();
    res.json({ requests });
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
};

const processProfileUpdateRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { status, managerNotes } = req.body;
    await svc.processProfileUpdateRequest(requestId, status, managerNotes);
    res.json({ message: 'Request đã được xử lý' });
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
};

module.exports = {
  submitProfileUpdateRequest,
  getProfileUpdateRequests,
  processProfileUpdateRequest
};
