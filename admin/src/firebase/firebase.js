import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyDk4Lo-iiRC3z6ZHACuGdRPTq6S82qd5qQ",
  authDomain: "sortsnap-0494.firebaseapp.com",
  projectId: "sortsnap-0494",
  storageBucket: "sortsnap-0494.firebasestorage.app",
  messagingSenderId: "487439039376",
  appId: "1:487439039376:web:f891c596266fd58e865115",
};

const app = initializeApp(firebaseConfig);

export const db = getFirestore(app);
export const auth = getAuth(app);