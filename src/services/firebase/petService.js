import { doc, updateDoc, serverTimestamp, Timestamp } from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import imageCompression from 'browser-image-compression';
import { db, storage } from '../../config/firebase';

// Campos do pet que o tutor edita. Dono, autoria e vínculo com vets ficam de
// fora — a rule também recusa troca de ownerId/createdBy.
const EDITABLE = ['name', 'species', 'gender', 'breed', 'color', 'isNeutered', 'chipNumber', 'chronicConditions'];

export const petService = {
  // Foto do pet: comprime, remove EXIF (pode carregar a localização da casa) e
  // sobe em `pet-photos/{uid}/` — a storage rule exige uid do dono, < 5 MB e image/*.
  async uploadPetPhoto(uid, file) {
    const compressed = await imageCompression(file, {
      maxSizeMB: 1,
      maxWidthOrHeight: 1024,
      useWebWorker: true,
      fileType: 'image/jpeg',
    });
    const safeName = (file.name || 'foto').replace(/[^\w.-]+/g, '_');
    const photoRef = ref(storage, `pet-photos/${uid}/${Date.now()}_${safeName}`);
    await uploadBytes(photoRef, compressed, { contentType: 'image/jpeg' });
    return getDownloadURL(photoRef);
  },

  // Monta o documento a partir do formulário (datas e listas no formato do schema).
  toFirestore(data) {
    const out = {};
    EDITABLE.forEach((k) => { if (k in data) out[k] = data[k]; });
    if (data.birthDate) out.birthDate = Timestamp.fromDate(data.birthDate);
    if ('weight' in data) out.weight = data.weight ?? null;
    if ('allergies' in data) out.allergies = data.allergies || [];
    return out;
  },

  async updatePet(uid, petId, data, photoFile) {
    const patch = petService.toFirestore(data);
    if (photoFile) patch.imageUrl = await petService.uploadPetPhoto(uid, photoFile);
    await updateDoc(doc(db, 'pets', petId), { ...patch, updatedAt: serverTimestamp() });
  },
};
