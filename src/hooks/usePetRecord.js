import { useState, useEffect, useCallback } from 'react';
import {
  doc, getDoc, collection, getDocs, addDoc, query, where, orderBy, serverTimestamp,
} from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';

const toDate = (v) => {
  if (!v) return null;
  if (v.toDate instanceof Function) return v.toDate();
  if (v.seconds) return new Date(v.seconds * 1000);
  if (v instanceof Date) return v;
  return new Date(v);
};

/**
 * Aggregates a single pet's clinical record:
 *  - pet document
 *  - vaccines / deworming      → existing top-level collections, filtered by petId
 *  - consultas / pesos         → subcollections under pets/{petId}
 *
 * New record types in the future should be added as subcollections
 * (pets/{petId}/<tipo>) and fetched here following the same pattern.
 */
export function usePetRecord(petId) {
  const { user, userProfile } = useAuth();
  const [pet, setPet] = useState(null);
  const [vaccines, setVaccines] = useState([]);
  const [dewormings, setDewormings] = useState([]);
  const [consultas, setConsultas] = useState([]);
  const [pesos, setPesos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchAll = useCallback(async () => {
    if (!petId) return;
    try {
      const petSnap = await getDoc(doc(db, 'pets', petId));
      if (!petSnap.exists()) {
        setError(new Error('Paciente não encontrado'));
        setLoading(false);
        return;
      }
      setPet({ id: petSnap.id, ...petSnap.data() });

      const [vacSnap, dewSnap, consSnap, pesoSnap] = await Promise.all([
        getDocs(query(collection(db, 'vaccines'), where('petId', '==', petId))),
        getDocs(query(collection(db, 'deworming'), where('petId', '==', petId))),
        getDocs(query(collection(db, 'pets', petId, 'consultas'), orderBy('date', 'desc'))),
        getDocs(query(collection(db, 'pets', petId, 'pesos'), orderBy('date', 'asc'))),
      ]);

      const sortByDateDesc = (a, b) => (toDate(b.administrationDate) || 0) - (toDate(a.administrationDate) || 0);
      setVaccines(vacSnap.docs.map(d => ({ id: d.id, ...d.data() })).sort(sortByDateDesc));
      setDewormings(dewSnap.docs.map(d => ({ id: d.id, ...d.data() })).sort(sortByDateDesc));
      setConsultas(consSnap.docs.map(d => ({ id: d.id, ...d.data() })));
      setPesos(pesoSnap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  }, [petId]);

  useEffect(() => { fetchAll(); }, [fetchAll]);

  // ── Writers ────────────────────────────────────────────────────────────────
  const addConsulta = useCallback(async ({ date, motivo, diagnostico, observacoes }) => {
    await addDoc(collection(db, 'pets', petId, 'consultas'), {
      date: date ? new Date(date) : serverTimestamp(),
      motivo: motivo || '',
      diagnostico: diagnostico || '',
      observacoes: observacoes || '',
      veterinarianId: user?.uid || '',
      veterinarianName: userProfile?.name || '',
      createdAt: serverTimestamp(),
    });
    await fetchAll();
  }, [petId, user, userProfile, fetchAll]);

  const addPeso = useCallback(async ({ weight, date, notes }) => {
    await addDoc(collection(db, 'pets', petId, 'pesos'), {
      weight: Number(weight),
      date: date ? new Date(date) : serverTimestamp(),
      notes: notes || '',
      registeredBy: user?.uid || '',
      createdAt: serverTimestamp(),
    });
    await fetchAll();
  }, [petId, user, fetchAll]);

  return {
    pet, vaccines, dewormings, consultas, pesos,
    loading, error,
    addConsulta, addPeso, refresh: fetchAll,
  };
}
