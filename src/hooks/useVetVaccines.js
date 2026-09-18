import { useState, useEffect, useCallback } from 'react';
import { collection, query, where, getDocs } from "firebase/firestore";
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import logger from '../utils/logger';

const useVetVaccines = () => {
  const { user } = useAuth();
  const [vaccines, setVaccines] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchVaccines = useCallback(async () => {
    if (!user) {
      setLoading(false);
      return;
    }
    try {
      const q = query(collection(db, "vaccines"), where("veterinarianId", "==", user.uid));
      const querySnapshot = await getDocs(q);
      // Exclui registros com exclusão lógica (active === false). Legados sem o
      // campo `active` continuam visíveis.
      const vaccinesData = querySnapshot.docs
        .map(doc => ({ id: doc.id, ...doc.data() }))
        .filter(v => v.active !== false);
      setVaccines(vaccinesData);
      setError(null);
    } catch (err) {
      logger.error("Error fetching vaccines:", err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => { fetchVaccines(); }, [fetchVaccines]);

  return { vaccines, loading, error, refresh: fetchVaccines };
};

export default useVetVaccines;
