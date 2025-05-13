// backend/repositories/employeeRepository.js
const { db } = require('../configs/firebase');
const employeeCollection = db.collection('Users'); // Dùng chung collection "Users"

// Tạo employee
const createEmployee = async (docId, data) => {
  await employeeCollection.doc(docId).set(data);
};

// Tìm employee theo email
const findEmployeeByEmail = async (email) => {
  const snapshot = await employeeCollection
    .where('email', '==', email)
    .where('role', '==', 'employee')
    .get();
  if (snapshot.empty) return null;

  let userData = null;
  snapshot.forEach(doc => {
    userData = { id: doc.id, ...doc.data() };
  });
  return userData;
};

// Tìm employee theo appId
const findEmployeeByAppId = async (appId) => {
  const docRef = await employeeCollection.doc(appId).get();
  if (!docRef.exists) {
    console.log('Không tìm thấy document với appId:', appId);
    return null;
  }
  const data = docRef.data();
  console.log('Dữ liệu lấy được từ Firestore:', data);
  if (data.role !== 'employee') {
    console.log('Role không đúng:', data.role);
    return null;
  }
  return { appId: docRef.id, ...data };
};

// Loại bỏ các trường undefined khỏi object
function removeUndefined(obj) {
  return Object.fromEntries(Object.entries(obj).filter(([_, v]) => v !== undefined));
}

// Cập nhật employee
const updateEmployeeByAppId = async (appId, updateData) => {
  await employeeCollection.doc(appId).update(updateData);
};

// Cập nhật employee theo Firestore document id (userId)
const updateEmployeeById = async (userId, updateData) => {
  if (!userId || typeof userId !== 'string' || userId.trim() === '') {
    throw new Error('userId không hợp lệ khi cập nhật employee');
  }
  await employeeCollection.doc(userId).update(removeUndefined(updateData));
};

// Lấy danh sách employee
const getAllEmployees = async () => {
  const snapshot = await employeeCollection.where('role', '==', 'employee').get();
  const employees = [];
  snapshot.forEach(doc => {
    employees.push({ id: doc.id, ...doc.data() });
  });
  return employees;
};

// Xóa employee
const deleteEmployeeByAppId = async (appId) => {
  await employeeCollection.doc(appId).delete();
};

module.exports = {
  createEmployee,
  findEmployeeByEmail,
  findEmployeeByAppId,
  updateEmployeeByAppId,
  updateEmployeeById,
  getAllEmployees,
  deleteEmployeeByAppId
};
