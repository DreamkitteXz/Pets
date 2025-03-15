import { db } from '../../config/firebase';
import { 
  collection, 
  addDoc, 
  serverTimestamp 
} from 'firebase/firestore';

export const notificationService = {
  async sendVaccineValidationNotification(userId, vaccineId, status) {
    try {
      const notificationsRef = collection(db, `users/${userId}/notifications`);
      await addDoc(notificationsRef, {
        type: 'VACCINE_VALIDATION',
        vaccineId,
        status,
        read: false,
        createdAt: serverTimestamp()
      });
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  }
};
