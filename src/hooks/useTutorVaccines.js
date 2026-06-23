import { useState, useEffect, useCallback } from 'react';
import { collection, getDocs, query, where, doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';

const toDate = (v) => {
  if (!v) return null;
  if (v.toDate instanceof Function) return v.toDate();
  if (v.seconds) return new Date(v.seconds * 1000);
  return new Date(v);
};

/**
 * Vaccines for the tutor's pets (ownerId == uid), with tutor-side approval.
 * Writes to validationDetails.tutorValidation and recomputes the top-level status.
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
        .sort((a, b) => (toDate(b.administrationDate) || 0) - (toDate(a.administrationDate) || 0));
      setVaccines(list);
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => { fetchVaccines(); }, [fetchVaccines]);

  const respond = useCallback(async (vaccineId, decision, notes = '') => {
    // decision: 'approved' | 'rejected'
    const v = vaccines.find(x => x.id === vaccineId);
    const vetStatus = v?.validationDetails?.vetValidation?.status;
    // Top-level status: both approved → approved; tutor rejects → tutorRejected
    let status = decision === 'approved'
      ? (vetStatus === 'approved' ? 'approved' : 'tutorApproved')
      : 'tutorRejected';

    await updateDoc(doc(db, 'vaccines', vaccineId), {
      status,
      'validationDetails.tutorValidation': {
        status: decision,
        validatedAt: serverTimestamp(),
        validatedBy: user?.uid || '',
        notes: notes || '',
        rejectionReason: decision === 'rejected' ? notes : '',
      },
      updatedAt: serverTimestamp(),
    });
    await fetchVaccines();
  }, [vaccines, user, fetchVaccines]);

  return { vaccines, loading, error, respond, refresh: fetchVaccines };
}
