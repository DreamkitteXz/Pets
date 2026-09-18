import { useState, useEffect } from 'react';
import { collection, query, where, orderBy, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import logger from '../utils/logger';
import { toDate } from '../utils/dates';

const DAY = 24 * 60 * 60 * 1000;
const WEEKDAYS = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

export function useDashboard() {
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuth();

  useEffect(() => {
    async function fetchDashboardData() {
      try {
        if (!user?.uid) return;

        const now = new Date();
        const startOfDay = new Date(new Date().setHours(0, 0, 0, 0));
        const endOfDay = new Date(new Date().setHours(23, 59, 59, 999));
        const in30 = new Date(now.getTime() + 30 * DAY);

        // ── Parallel fetches scoped to the vet ───────────────────────────────
        // Vacinas próximas e vermífugos vencidos usam QUERY INDEXADA por nextDueDate
        // (índice composto veterinarianId+nextDueDate) — sem baixar tudo e filtrar.
        const [petsSnapshot, appointmentsSnapshot, upcomingVacSnap, overdueDewSnap] = await Promise.all([
          getDocs(query(collection(db, 'pets'), where('veterinarians', 'array-contains', user.uid))),
          getDocs(query(collection(db, 'appointments'), where('veterinarianId', '==', user.uid))),
          getDocs(query(collection(db, 'vaccines'),
            where('veterinarianId', '==', user.uid),
            where('nextDueDate', '>=', now),
            where('nextDueDate', '<=', in30),
            orderBy('nextDueDate', 'asc'))),
          getDocs(query(collection(db, 'deworming'),
            where('veterinarianId', '==', user.uid),
            where('nextDueDate', '<', now),
            orderBy('nextDueDate', 'asc'))),
        ]);

        const appointments = appointmentsSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
          date: toDate(doc.data().date),
        }));

        // Today's appointments
        const todayAppointments = appointments.filter(a =>
          a.date && a.date >= startOfDay && a.date <= endOfDay
        );

        // ── Weekly distribution (current week, Sun→Sat) for the bar chart ────
        const startOfWeek = new Date(startOfDay);
        startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());
        const endOfWeek = new Date(startOfWeek.getTime() + 7 * DAY);
        const weeklyData = WEEKDAYS.map(label => ({ day: label, consultas: 0 }));
        let weekAppointments = 0;
        appointments.forEach(a => {
          if (a.date && a.date >= startOfWeek && a.date < endOfWeek) {
            weeklyData[a.date.getDay()].consultas += 1;
            weekAppointments += 1;
          }
        });

        // Contadores a partir da query indexada — só resta excluir soft-deleted
        // (filtro barato sobre o resultado já recortado pelo índice).
        const upcomingVaccines = upcomingVacSnap.docs.filter(d => d.data().active !== false).length;
        const overdueDewormings = overdueDewSnap.docs.filter(d => d.data().active !== false).length;

        const recentPets = petsSnapshot.docs
          .map(doc => ({
            id: doc.id,
            ...doc.data(),
            birthDate: toDate(doc.data().birthDate),
            lastVisit: toDate(doc.data().lastVisit),
          }))
          .sort((a, b) => (b.lastVisit || 0) - (a.lastVisit || 0))
          .slice(0, 5);

        setDashboardData({
          totalPets: petsSnapshot.size,
          todayAppointments,
          weekAppointments,
          weeklyData,
          upcomingVaccines,
          overdueDewormings,
          recentPets,
        });

        setLoading(false);
      } catch (err) {
        logger.error('Error fetching dashboard data:', err);
        setError(err);
        setLoading(false);
      }
    }

    fetchDashboardData();
  }, [user]);

  return { dashboardData, loading, error };
}
