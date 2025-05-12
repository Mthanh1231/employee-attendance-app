// backendnew/services/profileUpdateRequestService.js
const repo = require('../repositories/profileUpdateRequestRepository');
const { updateEmployeeById } = require('../repositories/employeeRepository');

const submitProfileUpdateRequest = async (employeeId, data) => {
  // Nếu có thông tin CCCD, đổi key "name" thành "cccd_name" để không ghi đè thông tin cá nhân cơ bản
  if (data.cccd_info && data.cccd_info.name) {
    data.cccd_info.cccd_name = data.cccd_info.name;
    delete data.cccd_info.name;
  }

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
    let updateData = { ...request.newData };
    if (updateData.cccd_info) {
      updateData = { ...updateData, ...updateData.cccd_info };
      // delete updateData.cccd_info;
    }
    // Không cho phép ghi đè các trường hệ thống
    delete updateData.role;
    delete updateData.employeeId;
    delete updateData.password;
    await updateEmployeeById(request.employeeId, updateData);
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
