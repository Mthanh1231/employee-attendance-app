// backend/repositories/profileUpdateRequestRepository.js
const { db } = require('../configs/firebase');
const requestsCollection = db.collection('ProfileUpdateRequests');

const createRequest = async (data) => {
  const docRef = await requestsCollection.add(data);
  return docRef.id;
};

const getRequestById = async (requestId) => {
  const doc = await requestsCollection.doc(requestId).get();
  return doc.exists ? { id: doc.id, ...doc.data() } : null;
};

const getPendingRequests = async () => {
  const snapshot = await requestsCollection.where('status', '==', 'pending').get();
  const requests = [];
  snapshot.forEach(doc => requests.push({ id: doc.id, ...doc.data() }));
  return requests;
};

const updateRequestById = async (requestId, updateData) => {
  await requestsCollection.doc(requestId).update(updateData);
};

module.exports = {
  createRequest,
  getRequestById,
  getPendingRequests,
  updateRequestById
};
