// backend/repositories/configRepository.js
const { db } = require('../configs/firebase');
const configs = db.collection('Configs');

/**
 * Fetch the machine’s location & radius from Firestore.
 * Throws if missing.
 */
async function getMachineConfig() {
  const doc = await configs.doc('machine').get();
  if (!doc.exists) {
    throw new Error('Machine configuration not found in Firestore');
  }
  const { lat, lng, radius } = doc.data();
  return {
    lat: parseFloat(lat),
    lng: parseFloat(lng),
    radius: parseFloat(radius)
  };
}

module.exports = { getMachineConfig };
