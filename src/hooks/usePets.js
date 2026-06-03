import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import logger from '../utils/logger';

export function usePets() {
  const [pets, setPets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuth();

  useEffect(() => {
    async function fetchPets() {
      try {
        const petsRef = collection(db, 'pets');
        // Create a query where veterinarians array contains current user's ID
        const q = query(petsRef, where('veterinarians', 'array-contains', user.uid));
        const querySnapshot = await getDocs(q);
        const petsData = querySnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
          birthDate: doc.data().birthDate?.toDate(),
          createdAt: doc.data().createdAt?.toDate(),
          updatedAt: doc.data().updatedAt?.toDate()
        }));

        setPets(petsData);
        setLoading(false);
      } catch (err) {
        logger.error('Error fetching pets:', err);
        setError(err);
        setLoading(false);
      }
    }

    if (user?.uid) {
      fetchPets();
    }
  }, [user]);

  return { pets, loading, error };
}
