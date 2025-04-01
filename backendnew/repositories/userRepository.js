// backend/repositories/userRepository.js
const { db } = require('../configs/firebase');

// Collection "Users"
const userCollection = db.collection('Users');

const createUser = async (docId, userData) => {
  await userCollection.doc(docId).set(userData);
};

const findUserByEmail = async (email) => {
  const snapshot = await userCollection.where('email', '==', email).get();
  if (snapshot.empty) return null;

  let userData = null;
  snapshot.forEach(doc => {
    userData = { id: doc.id, ...doc.data() };
  });
  return userData;
};

const findUserById = async (id) => {
  const docRef = await userCollection.doc(id).get();
  if (!docRef.exists) return null;
  return { id: docRef.id, ...docRef.data() };
};

const updateUserById = async (id, updateData) => {
  await userCollection.doc(id).update(updateData);
};

const getAllUsers = async () => {
    const snapshot = await userCollection.get(); // Lấy tất cả document trong collection Users
    const users = [];
    snapshot.forEach(doc => {
      users.push({ id: doc.id, ...doc.data() });
    });
    return users;
  };

module.exports = {
  createUser,
  findUserByEmail,
  findUserById,
  updateUserById,
    getAllUsers
};
