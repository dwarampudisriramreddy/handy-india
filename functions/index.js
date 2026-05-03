const functions = require('firebase-functions');

// Note: Razorpay standard integration usually happens on the client-side for Flutter,
// or via a separate backend validation step.
// We've moved the logic to the client app for now.

exports.ping = functions.https.onRequest((request, response) => {
  response.send("Handy India Backend is online.");
});
