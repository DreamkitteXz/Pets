import { useState, useEffect } from 'react';
import { collection, getDocs, query, where } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';

const DAY = 24 * 60 * 60 * 1000;

const toDate = (v) => {
  if (!v) return null;
  if (v.toDate instanceof Function) return v.toDate();
  if (v.seconds) return new Date(v.seconds * 1000);
  if (v instanceof Date) return v;
  return new Date(v);
};

/**
 * Aggregated metrics for the "Meus Pacientes" page cards.
 * Counts vaccines due in the next 30 days and consultations in the last 30 days,
 * both scoped to the logged-in veterinarian.
 */
export function usePatientStats() {
  const [stats, setStats] = useState({ upcomingVaccines: 0, recentConsultations: 0 });
  const [loading, setLoading] = useState(true);
  const { user } = useAuth();

  useEffect(() => {
    async function fetchStats() {
      if (!user?.uid) return;
      try {
        const now = new Date();
        const in30 = new Date(now.getTime() + 30 * DAY);
        const ago30 = new Date(now.getTime() - 30 * DAY);

        const [vaccinesSnap, apptSnap] = await Promise.all([
          getDocs(query(collection(db, 'vaccines'), where('veterinarianId', '==', user.uid))),
          getDocs(query(collection(db, 'appointments'), where('veterinarianId', '==', user.uid))),
        ]);

        const upcomingVaccines = vaccinesSnap.docs.filter(d => {
          const due = toDate(d.data().nextDueDate);
          return due && due >= now && due <= in30;
        }).length;

        const recentConsultations = apptSnap.docs.filter(d => {
          const date = toDate(d.data().date);
          return date && date >= ago30 && date <= now;
        }).length;

        setStats({ upcomingVaccines, recentConsultations });
      } catch (err) {
        // Non-blocking: cards just show 0 on failure.
        setStats({ upcomingVaccines: 0, recentConsultations: 0 });
      } finally {
        setLoading(false);
      }
    }
    fetchStats();
  }, [user]);

  return { stats, loading };
}
