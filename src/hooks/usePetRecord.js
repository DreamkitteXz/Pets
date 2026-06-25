import { useState, useEffect, useCallback } from 'react';
import {
  doc, getDoc, collection, getDocs, addDoc, query, where, orderBy, serverTimestamp,
} from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import { toDate } from '../utils/dates';

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
    if (!petId || !user?.uid) return;
    try {
      const petSnap = await getDoc(doc(db, 'pets', petId));
      if (!petSnap.exists()) {
        setError(new Error('Paciente não encontrado'));
        setLoading(false);
        return;
      }
      setPet({ id: petSnap.id, ...petSnap.data() });

      // Regras do Firestore não são filtros: vaccines/deworming exigem
      // veterinarianId==uid (vet) OU ownerId==uid (tutor). Uma query só por
      // petId seria recusada ("Missing or insufficient permissions"), então
      // escopamos pelo campo do papel e filtramos o petId no cliente.
      const scopeField = userProfile?.role === 'tutor' ? 'ownerId' : 'veterinarianId';

      const [vacSnap, dewSnap, consSnap, pesoSnap] = await Promise.all([
        getDocs(query(collection(db, 'vaccines'), where(scopeField, '==', user.uid))),
        getDocs(query(collection(db, 'deworming'), where(scopeField, '==', user.uid))),
        getDocs(query(collection(db, 'pets', petId, 'consultas'), orderBy('date', 'desc'))),
        getDocs(query(collection(db, 'pets', petId, 'pesos'), orderBy('date', 'asc'))),
      ]);

      const sortByDateDesc = (a, b) => (toDate(b.administrationDate) || 0) - (toDate(a.administrationDate) || 0);
      setVaccines(vacSnap.docs.map(d => ({ id: d.id, ...d.data() })).filter(v => v.petId === petId && v.active !== false).sort(sortByDateDesc));
      setDewormings(dewSnap.docs.map(d => ({ id: d.id, ...d.data() })).filter(d => d.petId === petId && d.active !== false).sort(sortByDateDesc));
      setConsultas(consSnap.docs.map(d => ({ id: d.id, ...d.data() })));
      setPesos(pesoSnap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  }, [petId, user, userProfile]);

  useEffect(() => { fetchAll(); }, [fetchAll]);

  // ── Writers ────────────────────────────────────────────────────────────────
  const addConsulta = useCallback(async ({ date, motivo, diagnostico, observacoes }) => {
    const uid = user?.uid || '';
    await addDoc(collection(db, 'pets', petId, 'consultas'), {
      date: date ? new Date(date) : serverTimestamp(),
      motivo: motivo || '',
      diagnostico: diagnostico || '',
      observacoes: observacoes || '',
      veterinarianId: uid,
      veterinarianName: userProfile?.name || '',
      // Trilha de auditoria
      createdBy: uid,
      updatedBy: uid,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    await fetchAll();
  }, [petId, user, userProfile, fetchAll]);

  const addPeso = useCallback(async ({ weight, date, notes }) => {
    const uid = user?.uid || '';
    await addDoc(collection(db, 'pets', petId, 'pesos'), {
      weight: Number(weight),
      date: date ? new Date(date) : serverTimestamp(),
      notes: notes || '',
      registeredBy: uid,
      // Trilha de auditoria
      createdBy: uid,
      updatedBy: uid,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    await fetchAll();
  }, [petId, user, fetchAll]);

  return {
    pet, vaccines, dewormings, consultas, pesos,
    loading, error,
    addConsulta, addPeso, refresh: fetchAll,
  };
}
