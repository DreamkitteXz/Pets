// Import the functions you need from the SDKs you need
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getAnalytics } from 'firebase/analytics';

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDR6vDXEFD97Rfg_LYip-r4-fR1unHyU0M",
  authDomain: "pet-app-fccae.firebaseapp.com",
  projectId: "pet-app-fccae",
  storageBucket: "pet-app-fccae.appspot.com",
  messagingSenderId: "581507658371",
  appId: "1:581507658371:web:be365836533eb733b7a1b6",
  measurementId: "G-Q2NZLHJJ8V"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const analytics = getAnalytics(app);

export default app;
