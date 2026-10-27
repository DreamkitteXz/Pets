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
      // Vacinas E vermífugos do vet: mesmo formato, mesma validação (a CF
      // recebe `collection`). `kind` diz de qual coleção cada um veio.
      const [vacSnap, dewSnap] = await Promise.all(['vaccines', 'deworming'].map((col) =>
        getDocs(query(collection(db, col), where("veterinarianId", "==", user.uid)))));
      // Exclui registros com exclusão lógica (active === false). Legados sem o
      // campo `active` continuam visíveis.
      const vaccinesData = [
        ...vacSnap.docs.map(doc => ({ id: doc.id, ...doc.data(), kind: 'vaccines' })),
        ...dewSnap.docs.map(doc => ({ id: doc.id, ...doc.data(), kind: 'deworming' })),
      ].filter(v => v.active !== false);
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
