import { useState, useEffect, useCallback } from 'react';
import { collection, getDocs, query, orderBy, doc, updateDoc } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';

// Lê users/{uid}/notifications (gravadas pela Cloud Function de validação).
export function useNotifications() {
  const { user } = useAuth();
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    if (!user?.uid) return;
    try {
      const snap = await getDocs(
        query(collection(db, 'users', user.uid, 'notifications'), orderBy('createdAt', 'desc'))
      );
      setNotifications(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch {
      setNotifications([]);
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => { refresh(); }, [refresh]);

  const unreadCount = notifications.filter(n => !n.read).length;

  const markAllRead = useCallback(async () => {
    if (!user?.uid) return;
    const unread = notifications.filter(n => !n.read);
    if (unread.length === 0) return;
    setNotifications(ns => ns.map(n => ({ ...n, read: true }))); // otimista
    await Promise.all(unread.map(n =>
      updateDoc(doc(db, 'users', user.uid, 'notifications', n.id), { read: true }).catch(() => {})
    ));
  }, [user, notifications]);

  return { notifications, unreadCount, loading, markAllRead, refresh };
}
