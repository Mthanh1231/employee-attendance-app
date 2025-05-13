// backend/repositories/configRepository.js
const { db } = require('../configs/firebase');
const configs = db.collection('Configs');

/**
 * Fetch the machine's location & radius from Firestore.
 * Throws if missing.
 */
async function getMachineConfig() {
  const doc = await configs.doc('machines').get();
  if (!doc.exists) {
    throw new Error('Machine configuration not found in Firestore');
  }
  const data = doc.data();
  if (!data.locations || !Array.isArray(data.locations) || data.locations.length === 0) {
    throw new Error('No machine locations configured');
  }
  const { lat, lng, radius } = data.locations[0];
  return {
    lat: parseFloat(lat),
    lng: parseFloat(lng),
    radius: parseFloat(radius)
  };
}

module.exports = { getMachineConfig };
