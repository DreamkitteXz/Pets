import { 
  collection, 
  query, 
  where, 
  getDocs, 
  addDoc, 
  updateDoc, 
  doc, 
  deleteDoc, 
  serverTimestamp 
} from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { db, storage } from '../../config/firebase';

export const vaccineService = {
  // Get all vaccines with optional filters
  async getVaccines(filters = {}) {
    try {
      const vaccinesRef = collection(db, 'vaccines');
      const constraints = [];

      if (filters.status) {
        constraints.push(where('status', '==', filters.status));
      }
      if (filters.veterinarianId) {
        constraints.push(where('veterinarianId', '==', filters.veterinarianId));
      }

      const q = query(vaccinesRef, ...constraints);
      const querySnapshot = await getDocs(q);
      
      return querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error fetching vaccines:', error);
      throw error;
    }
  },

  // Create new vaccine record
  async createVaccine(vaccineData, labelImage) {
    try {
      // Upload image if provided
      let imageUrl = null;
      if (labelImage) {
        const storageRef = ref(storage, `vaccine-labels/${Date.now()}_${labelImage.name}`);
        await uploadBytes(storageRef, labelImage);
        imageUrl = await getDownloadURL(storageRef);
      }

      const vaccineRef = collection(db, 'vaccines');
      const newVaccine = {
        ...vaccineData,
        labelImage: imageUrl,
        status: 'pending',
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      };

      const docRef = await addDoc(vaccineRef, newVaccine);
      return docRef.id;
    } catch (error) {
      console.error('Error creating vaccine:', error);
      throw error;
    }
  },

  // Update vaccine status
  async updateVaccineStatus(vaccineId, validationData) {
    try {
      const vaccineRef = doc(db, 'vaccines', vaccineId);
      await updateDoc(vaccineRef, {
        status: validationData.status,
        validationDetails: {
          validatedAt: serverTimestamp(),
          validatedBy: validationData.validatorId,
          notes: validationData.notes,
          rejectionReason: validationData.rejectionReason
        },
        updatedAt: serverTimestamp()
      });
    } catch (error) {
      console.error('Error updating vaccine:', error);
      throw error;
    }
  },

  // Delete vaccine record
  async deleteVaccine(vaccineId) {
    try {
      await deleteDoc(doc(db, 'vaccines', vaccineId));
    } catch (error) {
      console.error('Error deleting vaccine:', error);
      throw error;
    }
  }
};
