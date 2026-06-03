import React, { createContext, useContext, useEffect, useState } from 'react';
import { useAuth } from './AuthContext';

const ThemeContext = createContext({ isDark: false, setDark: () => {} });

export const useTheme = () => useContext(ThemeContext);

/**
 * ThemeProvider — manages dark/light mode across the app.
 *
 * Priority (highest → lowest):
 *   1. User's stored preference in Firestore (userProfile.darkMode)
 *   2. Value persisted in localStorage (for instant load before Firestore resolves)
 *   3. OS / system preference via matchMedia
 *
 * Applies the `dark` or `light` class to <html> so CSS variables switch,
 * and so Tailwind's darkMode: 'class' utilities work.
 *
 * Must be rendered *inside* AuthProvider so it can access userProfile.
 */
export const ThemeProvider = ({ children }) => {
  const { userProfile } = useAuth();

  const [isDark, setIsDarkState] = useState(() => {
    // Read from localStorage on initial render (before Firestore loads)
    const stored = localStorage.getItem('petto-theme');
    if (stored === 'dark') return true;
    if (stored === 'light') return false;
    // Fall back to system preference
    return typeof window !== 'undefined'
      ? window.matchMedia('(prefers-color-scheme: dark)').matches
      : false;
  });

  // Sync from Firestore userProfile when it becomes available
  useEffect(() => {
    if (userProfile && typeof userProfile.darkMode === 'boolean') {
      setIsDarkState(userProfile.darkMode);
    }
  }, [userProfile?.darkMode]);

  // Apply class to <html> and persist whenever isDark changes
  useEffect(() => {
    const html = document.documentElement;
    if (isDark) {
      html.classList.add('dark');
      html.classList.remove('light');
    } else {
      html.classList.remove('dark');
      html.classList.add('light');
    }
    localStorage.setItem('petto-theme', isDark ? 'dark' : 'light');
  }, [isDark]);

  // Also react to OS-level changes while the user has no stored preference
  useEffect(() => {
    const mq = window.matchMedia('(prefers-color-scheme: dark)');
    const handleChange = (e) => {
      // Only follow system if the user hasn't set a personal preference
      const stored = localStorage.getItem('petto-theme');
      if (!stored || stored === 'system') setIsDarkState(e.matches);
    };
    mq.addEventListener('change', handleChange);
    return () => mq.removeEventListener('change', handleChange);
  }, []);

  /**
   * setDark(bool) — called by Settings toggle for instant feedback.
   * The Settings form still saves to Firestore on submit; this gives
   * immediate visual response without waiting for the round-trip.
   */
  const setDark = (value) => setIsDarkState(Boolean(value));

  return (
    <ThemeContext.Provider value={{ isDark, setDark }}>
      {children}
    </ThemeContext.Provider>
  );
};
