import { useEffect, useMemo, useState } from 'react';
import { collection, getDocs, query, where } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';

/**
 * Clínicas que podem ser escolhidas ao registrar uma aplicação.
 *  • vet   — só as clínicas de que ele faz parte (a CF createVaccineRecord exige).
 *  • tutor — qualquer clínica ativa (quem aplicou pode não ser o vet que valida),
 *            com as do veterinário escolhido primeiro.
 */
export function useClinicOptions({ enabled, isTutorMode, vetId }) {
  const { user } = useAuth();
  const [clinics, setClinics] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!enabled || !user?.uid) return undefined;
    let cancelled = false;
    setLoading(true);
    const q = isTutorMode
      ? query(collection(db, 'clinics'), where('status', '==', 'active'))
      : query(collection(db, 'clinics'), where('veterinarians', 'array-contains', user.uid));
    getDocs(q)
      .then((snap) => {
        if (!cancelled) {
          setClinics(snap.docs.map((d) => ({ id: d.id, ...d.data() })).filter((c) => c.status !== 'inactive'));
        }
      })
      .catch(() => { if (!cancelled) setClinics([]); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [enabled, isTutorMode, user?.uid]);

  const options = useMemo(() => {
    const isVets = (c) => !!vetId && (c.veterinarians || []).includes(vetId);
    return [...clinics].sort((a, b) => (isVets(b) - isVets(a)) || (a.name || '').localeCompare(b.name || '', 'pt-BR'))
      .map((c) => ({ ...c, ofSelectedVet: isVets(c) }));
  }, [clinics, vetId]);

  return { clinics: options, loading };
}

export const formatClinicAddress = (a) => {
  if (!a || typeof a !== 'object') return typeof a === 'string' ? a : '';
  return [
    a.street && a.number ? `${a.street}, ${a.number}` : a.street,
    a.neighborhood,
    a.city && a.state ? `${a.city}/${a.state}` : a.city,
  ].filter(Boolean).join(' · ');
};
