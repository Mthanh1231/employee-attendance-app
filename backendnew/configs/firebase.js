// backend/config/firebase.js
const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json'); // đường dẫn tới file JSON

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

module.exports = { admin, db };
