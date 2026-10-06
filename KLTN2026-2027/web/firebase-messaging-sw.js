importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyA_wF_riP8kSiiLSojT2kAe0OwdXVz5-5E",
  appId: "1:476605524890:web:471cda610fe48ddf4e6823",
  messagingSenderId: "476605524890",
  projectId: "sports-venue-cb204",
  authDomain: "sports-venue-cb204.firebaseapp.com",
  storageBucket: "sports-venue-cb204.firebasestorage.app",
  measurementId: "G-JGM3HNSPYL"
});

const messaging = firebase.messaging();
