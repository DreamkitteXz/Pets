import { useState, useEffect } from 'react';
import { collection, getDocs, query, where } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';

/**
 * Pets owned by the logged-in tutor (pets where ownerId == uid).
 */
export function useTutorPets() {
  const [pets, setPets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuth();

  useEffect(() => {
    async function fetchPets() {
      if (!user?.uid) return;
      try {
        const q = query(collection(db, 'pets'), where('ownerId', '==', user.uid));
        const snap = await getDocs(q);
        setPets(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    }
    fetchPets();
  }, [user]);

  return { pets, loading, error };
}
