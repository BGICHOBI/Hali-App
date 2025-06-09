/*
 Firebase Cloud Functions for Hali App v1
 - STK-Push (M-Pesa Daraja)
 - Firestore triggers to update user balances
 - sendToUser callable
 - buyProduct callable
*/

const functions = require('firebase-functions');
const admin     = require('firebase-admin');
const axios     = require('axios');

// init Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// Daraja credentials from functions config
const { key: MPESA_KEY, secret: MPESA_SECRET, shortcode: MPESA_SHORTCODE, passkey: MPESA_PASSKEY } = functions.config().mpesa;
// Daraja endpoints
default_config = {
  baseURL: 'https://sandbox.safaricom.co.ke',
  headers: { 'Content-Type': 'application/json' }
};

/**
 * Generate OAuth token from Daraja
 */
async function getDarajaToken() {
  const resp = await axios.get('/oauth/v1/generate?grant_type=client_credentials', {
    baseURL: default_config.baseURL,
    auth: { username: MPESA_KEY, password: MPESA_SECRET }
  });
  return resp.data.access_token;
}

/**
 * 1️⃣ STK-Push: initiate M-Pesa payment
 */
exports.stkPush = functions.https.onCall(async (data, context) => {
  const { phone, amount } = data;
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');

  const token = await getDarajaToken();
  const timestamp = new Date().toISOString().replace(/[^0-9]/g, '').slice(0, 14);
  const password = Buffer.from(MPESA_SHORTCODE + MPESA_PASSKEY + timestamp).toString('base64');

  const payload = {
    BusinessShortCode: MPESA_SHORTCODE,
    Password: password,
    Timestamp: timestamp,
    TransactionType: 'CustomerPayBillOnline',
    Amount: amount,
    PartyA: phone,
    PartyB: MPESA_SHORTCODE,
    PhoneNumber: phone,
    CallBackURL: functions.config().mpesa.callbackurl || 'https://us-central1-' + process.env.GCP_PROJECT + '.cloudfunctions.net/stkCallback',
    AccountReference: context.auth.uid,
    TransactionDesc: 'Hali Wallet Top-Up'
  };

  const res = await axios.post('/mpesa/stkpush/v1/processrequest', payload, {
    baseURL: default_config.baseURL,
    headers: { Authorization: `Bearer ${token}` }
  });

  // Store request for callback correlation
  await db.collection('mpesa_requests').doc(res.data.CheckoutRequestID).set({
    uid: context.auth.uid,
    phone,
    amount,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    status: 'PENDING'
  });

  return { CheckoutRequestID: res.data.CheckoutRequestID };
});

/**
 * 1️⃣b STK-Push CALLBACK: handle Daraja result
 */
exports.stkCallback = functions.https.onRequest(async (req, res) => {
  const body = req.body;
  const cb = body.Body.stkCallback;
  const id = cb.CheckoutRequestID;
  const result = cb.ResultCode;

  // fetch original request
  const reqDoc = await db.collection('mpesa_requests').doc(id).get();
  if (!reqDoc.exists) return res.status(200).send('No matching request');
  const { uid, amount } = reqDoc.data();

  // update status
  await reqDoc.ref.update({ status: result === 0 ? 'SUCCESS' : 'FAILED', raw: body });

  if (result === 0) {
    // increment user balance
    await db.collection('users').doc(uid)
      .update({ balance: admin.firestore.FieldValue.increment(amount) });
  }

  res.status(200).send('OK');
});

/**
 * 2️⃣ sendToUser: peer transfer
 */
exports.sendToUser = functions.https.onCall(async (data, context) => {
  const { toUid, amount } = data;
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  const fromUid = context.auth.uid;
  if (fromUid === toUid) throw new functions.https.HttpsError('invalid-argument', 'Cannot send to yourself');

  // transaction to move funds
  await db.runTransaction(async (tx) => {
    const fromRef = db.collection('users').doc(fromUid);
    const toRef   = db.collection('users').doc(toUid);
    const [fromSnap, toSnap] = await Promise.all([tx.get(fromRef), tx.get(toRef)]);
    if (!toSnap.exists) throw new functions.https.HttpsError('not-found', 'Recipient not found');
    const fromBal = fromSnap.data().balance;
    if (fromBal < amount) throw new functions.https.HttpsError('failed-precondition', 'Insufficient funds');

    tx.update(fromRef, { balance: fromBal - amount });
    tx.update(toRef,   { balance: admin.firestore.FieldValue.increment(amount) });
  });

  return { success: true };
});

/**
 * 3️⃣ buyProduct: in-app purchase
 */
exports.buyProduct = functions.https.onCall(async (data, context) => {
  const { productId, price } = data;
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  const uid = context.auth.uid;

  await db.runTransaction(async (tx) => {
    const uRef = db.collection('users').doc(uid);
    const uSnap = await tx.get(uRef);
    const bal = uSnap.data().balance;
    if (bal < price) throw new functions.https.HttpsError('failed-precondition', 'Insufficient funds');

    // decrement balance and record purchase
    tx.update(uRef, { balance: bal - price });
    tx.set(uRef.collection('purchases').doc(), {
      productId,
      price,
      purchasedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  });
  return { success: true };
});
