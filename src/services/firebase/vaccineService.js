import { 
  collection, 
  query, 
  where, 
  getDocs, 
  addDoc,
  updateDoc,
  doc,
  serverTimestamp
} from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { db, storage } from '../../config/firebase';
import logger from '../../utils/logger';
import imageCompression from 'browser-image-compression';

export const vaccineService = {
  // Upload label image with EXIF stripping — returns download URL
  async uploadLabelImage(labelImage) {
    const stripped = await imageCompression(labelImage, {
      maxSizeMB: 4,
      useWebWorker: true,
      fileType: 'image/jpeg',
    });
    const storageRef = ref(storage, `vaccine-labels/${Date.now()}_${labelImage.name}`);
    await uploadBytes(storageRef, stripped);
    return getDownloadURL(storageRef);
  },

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
      logger.error('Error fetching vaccines:', error);
      throw error;
    }
  },

  // Cria um registro de "aplicação" (vacina ou vermífugo) — lógica compartilhada.
  // `data.status` é respeitado (padrão 'pending'); o cadastro feito pelo vet chega
  // com 'approved' + vetValidation. `data.location` (opcional) vai para
  // labelImageMetadata.location. A foto reusa o upload com EXIF strip.
  async createApplication(collectionName, data, labelImage) {
    try {
      const { location, status, ...rest } = data;

      let imageUrl = null;
      let labelImageMetadata = null;
      if (labelImage) {
        imageUrl = await vaccineService.uploadLabelImage(labelImage);
        labelImageMetadata = {
          name: labelImage.name || '',
          size: labelImage.size || 0,
          contentType: labelImage.type || 'image/jpeg',
          timeCreated: serverTimestamp(),
          updated: serverTimestamp(),
          ...(location ? { location } : {}),
        };
      }

      const ref = collection(db, collectionName);
      const newDoc = {
        ...rest,
        labelImage: imageUrl,
        ...(labelImageMetadata ? { labelImageMetadata } : {}),
        status: status || 'pending',
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      };

      const docRef = await addDoc(ref, newDoc);
      return docRef.id;
    } catch (error) {
      logger.error(`Error creating application in '${collectionName}':`, error);
      throw error;
    }
  },

  // Vacina (coleção `vaccines`).
  async createVaccine(vaccineData, labelImage) {
    return vaccineService.createApplication('vaccines', vaccineData, labelImage);
  },

  // Vermífugo (coleção `deworming`) — mesmo fluxo/validação da vacina.
  async createDeworming(dewormingData, labelImage) {
    return vaccineService.createApplication('deworming', dewormingData, labelImage);
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
      logger.error('Error updating vaccine:', error);
      throw error;
    }
  },

  // Edição de campos clínicos (permitida só enquanto pending — as regras impedem
  // edição após validação). Não toca status/validationDetails.
  async updateApplication(collectionName, id, data) {
    try {
      await updateDoc(doc(db, collectionName, id), {
        ...data,
        updatedAt: serverTimestamp(),
      });
    } catch (error) {
      logger.error(`Error updating ${collectionName}/${id}:`, error);
      throw error;
    }
  },
  async updateVaccine(id, data) { return vaccineService.updateApplication('vaccines', id, data); },
  async updateDeworming(id, data) { return vaccineService.updateApplication('deworming', id, data); },

  // Exclusão LÓGICA (soft-delete) — preserva o registro e a foto para auditoria.
  // `deletedBy` deve ser o uid do veterinário responsável (exigido pelas regras).
  async softDelete(collectionName, id, deletedBy) {
    try {
      await updateDoc(doc(db, collectionName, id), {
        active: false,
        deletedAt: serverTimestamp(),
        deletedBy,
        updatedAt: serverTimestamp(),
      });
    } catch (error) {
      logger.error(`Error soft-deleting ${collectionName}/${id}:`, error);
      throw error;
    }
  },
  async deleteVaccine(vaccineId, deletedBy) { return vaccineService.softDelete('vaccines', vaccineId, deletedBy); },
  async deleteDeworming(dewormingId, deletedBy) { return vaccineService.softDelete('deworming', dewormingId, deletedBy); },
};
