import { useState, useEffect } from 'react';
import { collection, getDocs, orderBy, query } from 'firebase/firestore';
import { db } from '../config/firebase';

// Catálogo controlado de vacinas/vermífugos.
// type: 'vacina' → vaccineCatalog | 'vermifugo' → dewormerCatalog
// Item: { name, manufacturer, species: [String] (ou ['all']), reforcoDias: Number }
export function useCatalog(type) {
  const col = type === 'vermifugo' ? 'dewormerCatalog' : 'vaccineCatalog';
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    (async () => {
      try {
        const snap = await getDocs(query(collection(db, col), orderBy('name')));
        if (active) setItems(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      } catch {
        if (active) setItems([]); // catálogo vazio/sem índice → entrada livre
      } finally {
        if (active) setLoading(false);
      }
    })();
    return () => { active = false; };
  }, [col]);

  return { items, loading };
}
