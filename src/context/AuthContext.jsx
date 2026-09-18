import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { auth, db } from '../config/firebase';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import {
  signInWithEmail,
  signUpWithEmail,
  signInWithGoogle,
  signOut,
  sendPasswordReset,
  resendVerificationEmail,
} from '../services/firebase/authService';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within an AuthProvider');
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [userProfile, setUserProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  // Re-fetch the Firestore profile for the current user. Used after onboarding
  // so routing/sidebar pick up the freshly-set role without a full reload.
  const refreshProfile = useCallback(async () => {
    const current = auth.currentUser;
    if (!current) { setUserProfile(null); return null; }
    try {
      const snap = await getDoc(doc(db, 'users', current.uid));
      const data = snap.exists() ? snap.data() : null;
      setUserProfile(data);
      return data;
    } catch {
      setUserProfile(null);
      return null;
    }
  }, []);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setUser(firebaseUser);

      if (firebaseUser) {
        try {
          const snap = await getDoc(doc(db, 'users', firebaseUser.uid));
          setUserProfile(snap.exists() ? snap.data() : null);
        } catch {
          setUserProfile(null);
        }
      } else {
        setUserProfile(null);
      }

      setLoading(false);
    });

    return unsubscribe;
  }, []);

  const value = {
    user,
    userProfile,
    loading,
    refreshProfile,
    signIn: signInWithEmail,
    signUp: signUpWithEmail,
    signInWithGoogle,
    signOut,
    sendPasswordReset,
    resendVerificationEmail,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
