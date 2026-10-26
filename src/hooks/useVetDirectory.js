import { useState, useEffect } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';

/**
 * Diretório público de veterinários (`vet_directory`).
 *
 * É uma projeção de `users` mantida pela CF `mirrorVetDirectory`: só vets
 * ativos com CRMV, e só name/crmv/specialties/yearsOfExperience — nunca cpf,
 * e-mail, telefone ou endereço. `users` continua fechado para o tutor.
 */
export function useVetDirectory(enabled = true) {
  const [vets, setVets] = useState([]);
  const [loading, setLoading] = useState(enabled);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!enabled) return undefined;
    let cancelled = false;
    (async () => {
      try {
        const snap = await getDocs(collection(db, 'vet_directory'));
        const list = snap.docs
          .map((d) => ({ uid: d.id, ...d.data() }))
          .sort((a, b) => (a.name || '').localeCompare(b.name || '', 'pt-BR'));
        if (!cancelled) setVets(list);
      } catch (err) {
        if (!cancelled) setError(err);
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => { cancelled = true; };
  }, [enabled]);

  return { vets, loading, error };
}
