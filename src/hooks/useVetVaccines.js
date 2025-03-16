import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from "firebase/firestore";
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';

const useVetVaccines = () => {
  const { user } = useAuth();
  const [vaccines, setVaccines] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let isMounted = true;

    const fetchVaccines = async () => {
      if (!user) {
        console.log('No user found, skipping fetch');
        setLoading(false);
        return;
      }
      
      try {
        console.log('Current user:', user);
        const vaccineCollection = collection(db, "vaccines");
        const q = query(vaccineCollection, where("veterinarianId", "==", user.uid));
        const querySnapshot = await getDocs(q);
        
        if (!isMounted) return;

        const vaccinesData = querySnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        
        console.log('Fetched vaccines:', vaccinesData);
        setVaccines(vaccinesData);
        setError(null);
      } catch (error) {
        console.error("Error fetching vaccines:", error);
        setError(error.message);
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };

    fetchVaccines();
    return () => {
      isMounted = false;
    };
  }, [user]);

  return { vaccines, loading, error };
};

export default useVetVaccines;
