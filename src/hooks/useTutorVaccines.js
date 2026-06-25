import { useState, useEffect, useCallback } from 'react';
import { collection, getDocs, query, where, doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import { toDate } from '../utils/dates';

/**
 * Vaccines for the tutor's pets (ownerId == uid).
 * O status é eixo único decidido pelo veterinário. O tutor apenas dá CIÊNCIA
 * (tutorAcknowledged) — não altera o status.
 */
export function useTutorVaccines() {
  const [vaccines, setVaccines] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuth();

  const fetchVaccines = useCallback(async () => {
    if (!user?.uid) return;
    try {
      const q = query(collection(db, 'vaccines'), where('ownerId', '==', user.uid));
      const snap = await getDocs(q);
      const list = snap.docs
        .map(d => ({ id: d.id, ...d.data() }))
        .filter(v => v.active !== false)
        .sort((a, b) => (toDate(b.administrationDate) || 0) - (toDate(a.administrationDate) || 0));
      setVaccines(list);
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => { fetchVaccines(); }, [fetchVaccines]);

  // Ciência do tutor — apenas marca que o tutor viu/confirmou o registro.
  // NÃO altera o status (que é decisão do veterinário).
  const acknowledge = useCallback(async (vaccineId) => {
    await updateDoc(doc(db, 'vaccines', vaccineId), {
      tutorAcknowledged: true,
      tutorAcknowledgedAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    await fetchVaccines();
  }, [fetchVaccines]);

  return { vaccines, loading, error, acknowledge, refresh: fetchVaccines };
}
