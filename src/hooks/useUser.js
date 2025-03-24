import { useState, useEffect } from 'react';
import { doc, getDoc, updateDoc } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext'; // Update import path

export function useUser() {
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuth();

  useEffect(() => {
    async function fetchUserData() {
      try {
        if (!user?.uid) return;
        const userDoc = await getDoc(doc(db, 'users', user.uid));
        if (userDoc.exists()) {
          setUserData(userDoc.data());
        }
        setLoading(false);
      } catch (err) {
        console.error('Error fetching user data:', err);
        setError(err);
        setLoading(false);
      }
    }

    fetchUserData();
  }, [user]);

  const updateUserData = async (newData) => {
    try {
      if (!user?.uid) throw new Error('No user authenticated');
      await updateDoc(doc(db, 'users', user.uid), newData);
      setUserData(prev => ({ ...prev, ...newData }));
      return true;
    } catch (err) {
      console.error('Error updating user data:', err);
      setError(err);
      return false;
    }
  };

  return { userData, loading, error, updateUserData };
}
