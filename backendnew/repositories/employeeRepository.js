// backendnew/repositories/employeeRepository.js
const { db } = require('../configs/firebase');
const employeeCollection = db.collection('Users'); // Dùng chung collection “Users”

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

// Tìm employee theo id
const findEmployeeById = async (id) => {
  const docRef = await employeeCollection.doc(id).get();
  if (!docRef.exists) return null;
  const data = docRef.data();
  if (data.role !== 'employee') return null; // check role
  return { id: docRef.id, ...data };
};

// Cập nhật employee
const updateEmployeeById = async (id, updateData) => {
  await employeeCollection.doc(id).update(updateData);
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
const deleteEmployeeById = async (id) => {
  await employeeCollection.doc(id).delete();
};

module.exports = {
  createEmployee,
  findEmployeeByEmail,
  findEmployeeById,
  updateEmployeeById,
  getAllEmployees,
  deleteEmployeeById
};
