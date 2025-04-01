// backendnew/repositories/managerRepository.js

const { db } = require('../configs/firebase');  // Đảm bảo file firebase.js tồn tại trong thư mục configs

// Sử dụng chung collection "Users"
const managerCollection = db.collection('Users');

const findManagerByEmail = async (email) => {
  const snapshot = await managerCollection
    .where('email', '==', email)
    .where('role', '==', 'manager')
    .get();
  if (snapshot.empty) return null;
  let managerData = null;
  snapshot.forEach(doc => {
    managerData = { id: doc.id, ...doc.data() };
  });
  return managerData;
};

const findManagerById = async (id) => {
  const docRef = await managerCollection.doc(id).get();
  if (!docRef.exists) return null;
  const data = docRef.data();
  if (data.role !== 'manager') return null;
  return { id: docRef.id, ...data };
};

const updateManagerById = async (id, updateData) => {
  await managerCollection.doc(id).update(updateData);
};

module.exports = {
  findManagerByEmail,
  findManagerById,
  updateManagerById
};
