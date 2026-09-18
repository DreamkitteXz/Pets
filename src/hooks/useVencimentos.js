import { useState, useEffect } from 'react';
import { collection, getDocs, query, where, orderBy } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import { toDate, toMillis } from '../utils/dates';

const DAY = 24 * 60 * 60 * 1000;

/**
 * Vencimentos de vacinas + vermífugos do veterinário, via QUERY INDEXADA
 * (where veterinarianId == uid AND nextDueDate <= hoje+90d, ordenado por nextDueDate).
 * Requer o índice composto (veterinarianId, nextDueDate) — ver firestore.indexes.json.
 * Respeita a exclusão lógica (active !== false, filtro barato no resultado já recortado).
 */
export function useVencimentos() {
  const { user } = useAuth();
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchAll() {
      if (!user?.uid) return;
      try {
        const cutoff = new Date(Date.now() + 90 * DAY);
        const fetchCol = (col, tipo) =>
          getDocs(query(
            collection(db, col),
            where('veterinarianId', '==', user.uid),
            where('nextDueDate', '<=', cutoff),
            orderBy('nextDueDate', 'asc'),
          )).then(snap =>
            snap.docs
              .map(d => ({ id: d.id, tipo, ...d.data() }))
              .filter(x => x.active !== false)
          );

        const [vacs, dews] = await Promise.all([
          fetchCol('vaccines', 'vacina'),
          fetchCol('deworming', 'vermifugo'),
        ]);

        const merged = [...vacs, ...dews]
          .filter(x => toDate(x.nextDueDate))
          .sort((a, b) => toMillis(a.nextDueDate) - toMillis(b.nextDueDate));

        setItems(merged);
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    }
    fetchAll();
  }, [user]);

  return { items, loading, error };
}
