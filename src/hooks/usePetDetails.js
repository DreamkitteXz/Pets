import { useState, useEffect } from 'react';
import { doc, getDoc, collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';

export function usePetDetails(petId) {
  const [pet, setPet] = useState(null);
  const [vaccines, setVaccines] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchPetDetails() {
      if (!petId) return;
      
      try {
        // Fetch pet details
        const petDoc = await getDoc(doc(db, 'pets', petId));
        if (!petDoc.exists()) {
          throw new Error('Pet not found');
        }

        const petData = {
          id: petDoc.id,
          ...petDoc.data(),
          birthDate: petDoc.data().birthDate?.toDate(),
          createdAt: petDoc.data().createdAt?.toDate(),
          updatedAt: petDoc.data().updatedAt?.toDate()
        };

        // Fetch associated vaccines
        const vaccinesQuery = query(
          collection(db, 'vaccines'),
          where('petId', '==', petId)
        );
        const vaccineSnapshot = await getDocs(vaccinesQuery);
        const vaccinesData = vaccineSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
          administrationDate: doc.data().administrationDate?.toDate(),
          nextDueDate: doc.data().nextDueDate?.toDate()
        }));

        setPet(petData);
        setVaccines(vaccinesData);
        setLoading(false);
      } catch (err) {
        console.error('Error fetching pet details:', err);
        setError(err);
        setLoading(false);
      }
    }

    fetchPetDetails();
  }, [petId]);

  return { pet, vaccines, loading, error };
}
