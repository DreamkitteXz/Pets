import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useAuth } from '../context/AuthContext';
import logger from '../utils/logger';

export function useDashboard() {
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuth();

  useEffect(() => {
    async function fetchDashboardData() {
      try {
        if (!user?.uid) return;

        // Get today's start and end
        const today = new Date();
        const startOfDay = new Date(today.setHours(0, 0, 0, 0));
        const endOfDay = new Date(today.setHours(23, 59, 59, 999));

        // Fetch pets
        const petsRef = collection(db, 'pets');
        const petsQuery = query(petsRef, where('veterinarians', 'array-contains', user.uid));
        const petsSnapshot = await getDocs(petsQuery);
        
        // Fetch all appointments for the vet
        const appointmentsRef = collection(db, 'appointments');
        const appointmentsQuery = query(
          appointmentsRef, 
          where('veterinarianId', '==', user.uid)
        );
        const appointmentsSnapshot = await getDocs(appointmentsQuery);

        // Filter appointments for today in memory
        const todayAppointments = appointmentsSnapshot.docs
          .map(doc => ({
            id: doc.id,
            ...doc.data(),
            date: doc.data().date?.toDate()
          }))
          .filter(appointment => {
            const appointmentDate = appointment.date;
            return appointmentDate >= startOfDay && appointmentDate <= endOfDay;
          });

        // Count critical cases from pets data
        const criticalCases = petsSnapshot.docs
          .filter(doc => doc.data().status === 'critical')
          .length;

        // Get recent pets
        const recentPets = petsSnapshot.docs
          .map(doc => ({
            id: doc.id,
            ...doc.data(),
            birthDate: doc.data().birthDate?.toDate(),
            lastVisit: doc.data().lastVisit?.toDate()
          }))
          .sort((a, b) => (b.lastVisit || 0) - (a.lastVisit || 0))
          .slice(0, 5);

        setDashboardData({
          totalPets: petsSnapshot.size,
          todayAppointments,
          criticalCases,
          recentPets
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
