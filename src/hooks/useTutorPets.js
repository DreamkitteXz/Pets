import { useState, useEffect, useCallback } from 'react';
import { collection, getDocs, query, where, addDoc, serverTimestamp, Timestamp } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import { petService } from '../services/firebase/petService';

/**
 * Pets owned by the logged-in tutor (pets where ownerId == uid).
 */
export function useTutorPets() {
  const [pets, setPets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user, userProfile } = useAuth();

  const fetchPets = useCallback(async () => {
    if (!user?.uid) return;
    try {
      const q = query(collection(db, 'pets'), where('ownerId', '==', user.uid));
      const snap = await getDocs(q);
      setPets(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => { fetchPets(); }, [fetchPets]);

  // Cadastro feito pelo próprio tutor. A rule exige createdBy == ownerId == uid.
  // Nasce sem veterinário: o vínculo (`veterinarians`) acontece depois, quando o
  // tutor associar um veterinário ao pet.
  const createPet = useCallback(async (data, photoFile) => {
    if (!user?.uid) throw new Error('Sessão expirada. Faça login novamente.');
    const { birthDate, weight, allergies, ...rest } = data;
    const imageUrl = photoFile ? await petService.uploadPetPhoto(user.uid, photoFile) : null;
    const ref = await addDoc(collection(db, 'pets'), {
      ...rest,
      birthDate: Timestamp.fromDate(birthDate),
      ...(weight ? { weight } : {}),
      ...(allergies?.length ? { allergies } : {}),
      ...(imageUrl ? { imageUrl } : {}),
      ownerId: user.uid,
      ownerName: userProfile?.name || '',
      veterinarians: [],
      status: 'active',
      createdBy: user.uid,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    await fetchPets();
    return ref.id;
  }, [user, userProfile, fetchPets]);

  return { pets, loading, error, createPet, refresh: fetchPets };
}
