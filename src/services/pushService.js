import { getMessaging, getToken, isSupported } from 'firebase/messaging';
import { doc, setDoc, serverTimestamp } from 'firebase/firestore';
import app, { db } from '../config/firebase';

// Chave pública "Web Push certificates" do Firebase (Configurações do projeto →
// Cloud Messaging). Sem ela o push fica desligado e só o e-mail avisa.
const VAPID_KEY = process.env.REACT_APP_FCM_VAPID_KEY;

/** Push disponível neste navegador (no iPhone, só com o site instalado na tela inicial). */
export async function pushAvailable() {
  if (!VAPID_KEY || typeof window === 'undefined' || !('Notification' in window) || !('serviceWorker' in navigator)) return false;
  try { return await isSupported(); } catch { return false; }
}

export const pushPermission = () => (typeof Notification === 'undefined' ? 'unsupported' : Notification.permission);

/** Pede permissão, registra o aparelho e guarda o token em users/{uid}/fcmTokens. */
export async function enablePush(uid) {
  const permission = await Notification.requestPermission();
  if (permission !== 'granted') return { ok: false, reason: permission };
  const registration = await navigator.serviceWorker.register('/firebase-messaging-sw.js');
  const token = await getToken(getMessaging(app), { vapidKey: VAPID_KEY, serviceWorkerRegistration: registration });
  if (!token) return { ok: false, reason: 'no-token' };
  await setDoc(doc(db, 'users', uid, 'fcmTokens', token), {
    token,
    createdAt: serverTimestamp(),
    userAgent: navigator.userAgent.slice(0, 300),
  });
  return { ok: true };
}
