import { useState, useEffect } from 'react';
import { collection, getDocs, query, where } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';

export function useClinics() {
  const [clinics, setClinics] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuth();

  useEffect(() => {
    async function fetchClinics() {
      if (!user?.uid) return;
      try {
        // Only clinics where the logged-in vet is in the `veterinarians` array.
        const q = query(
          collection(db, 'clinics'),
          where('veterinarians', 'array-contains', user.uid)
        );
        const snap = await getDocs(q);
        setClinics(snap.docs.map(doc => ({ id: doc.id, ...doc.data() })));
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    }
    fetchClinics();
  }, [user]);

  return { clinics, loading, error };
}
