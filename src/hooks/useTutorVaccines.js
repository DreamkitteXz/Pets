import { useState, useEffect, useCallback } from 'react';
import { collection, getDocs, query, where, doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import { toDate } from '../utils/dates';

/**
 * Vacinas E vermífugos dos pets do tutor (ownerId == uid). Cada item traz
 * `kind` ('vaccines' | 'deworming') — a coleção de origem.
 *
 * O status é eixo único decidido pelo veterinário. O tutor apenas dá CIÊNCIA
 * (tutorAcknowledged) — não altera o status. Registros que o próprio tutor
 * enviou (`createdBy == uid`) não pedem ciência: `needsAck` já vem falso.
 */
export function useTutorVaccines() {
  const [vaccines, setVaccines] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuth();

  const fetchVaccines = useCallback(async () => {
    if (!user?.uid) return;
    try {
      const [vacSnap, dewSnap] = await Promise.all(
        ['vaccines', 'deworming'].map((col) => getDocs(query(collection(db, col), where('ownerId', '==', user.uid)))),
      );
      const tag = (kind) => (d) => {
        const data = { id: d.id, kind, ...d.data() };
        data.sentByTutor = data.createdBy === user.uid;
        data.needsAck = !data.tutorAcknowledged && !data.sentByTutor;
        return data;
      };
      const list = [...vacSnap.docs.map(tag('vaccines')), ...dewSnap.docs.map(tag('deworming'))]
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
  const acknowledge = useCallback(async (id, kind = 'vaccines') => {
    await updateDoc(doc(db, kind, id), {
      tutorAcknowledged: true,
      tutorAcknowledgedAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    await fetchVaccines();
  }, [fetchVaccines]);

  return { vaccines, loading, error, acknowledge, refresh: fetchVaccines };
}
