// backendnew/services/profileUpdateRequestService.js
const repo = require('../repositories/profileUpdateRequestRepository');
const { updateEmployeeById } = require('../repositories/employeeRepository');

const submitProfileUpdateRequest = async (employeeId, data) => {
  return await repo.createRequest({
    employeeId,
    newData: data,
    status: 'pending',
    submittedAt: new Date().toISOString()
  });
};

const getPendingProfileUpdateRequests = async () => {
  return await repo.getPendingRequests();
};

const processProfileUpdateRequest = async (requestId, decision, managerNotes = '') => {
  // 1) Lấy request
  const request = await repo.getRequestById(requestId);
  if (!request) throw new Error('Request không tồn tại');
  if (request.status !== 'pending') throw new Error('Request đã được xử lý');

  // 2) Nếu approved → cập nhật employee
  if (decision === 'approved') {
    await updateEmployeeById(request.employeeId, request.newData);
  }

  // 3) Cập nhật trạng thái request
  await repo.updateRequestById(requestId, {
    status: decision,
    processedAt: new Date().toISOString(),
    managerNotes
  });
};

module.exports = {
  submitProfileUpdateRequest,
  getPendingProfileUpdateRequests,
  processProfileUpdateRequest
};
