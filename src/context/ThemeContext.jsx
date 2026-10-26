import React, { createContext, useContext, useEffect, useState } from 'react';
import { doc, updateDoc } from 'firebase/firestore';
import { auth, db } from '../config/firebase';
import { useAuth } from './AuthContext';

const ThemeContext = createContext({ isDark: false, setDark: () => {} });

export const useTheme = () => useContext(ThemeContext);

const STORAGE_KEY = 'petto-theme';

/**
 * ThemeProvider — manages dark/light mode across the app.
 *
 * O tema padrão é CLARO (não segue o modo escuro do sistema). A fonte da
 * verdade é `userProfile.darkMode` no Firestore: só fica escuro com
 * `darkMode === true`. O localStorage é apenas cache para não piscar no
 * carregamento, antes do perfil chegar.
 *
 * Applies the `dark` or `light` class to <html> so CSS variables switch,
 * and so Tailwind's darkMode: 'class' utilities work.
 *
 * Must be rendered *inside* AuthProvider so it can access userProfile.
 */
export const ThemeProvider = ({ children }) => {
  const { user, userProfile, loading } = useAuth();

  const [isDark, setIsDarkState] = useState(() => {
    try { return localStorage.getItem(STORAGE_KEY) === 'dark'; } catch { return false; }
  });

  // Perfil carregado manda; sem login (ou conta sem preferência) é claro.
  useEffect(() => {
    if (loading) return;
    setIsDarkState(Boolean(user && userProfile?.darkMode === true));
  }, [loading, user, userProfile?.darkMode]);

  // Apply class to <html> and persist whenever isDark changes
  useEffect(() => {
    const html = document.documentElement;
    html.classList.toggle('dark', isDark);
    html.classList.toggle('light', !isDark);
    try { localStorage.setItem(STORAGE_KEY, isDark ? 'dark' : 'light'); } catch { /* sem storage */ }
  }, [isDark]);

  /**
   * setDark(bool) — chamado pelo toggle em Configurações. Aplica na hora e já
   * grava no perfil, para o toggle e o tema nunca ficarem divergentes.
   */
  const setDark = async (value) => {
    const next = Boolean(value);
    setIsDarkState(next);
    const uid = auth.currentUser?.uid;
    if (!uid) return;
    try {
      await updateDoc(doc(db, 'users', uid), { darkMode: next });
    } catch {
      // Sem salvar, voltar ao valor anterior mantém tela e toggle coerentes.
      setIsDarkState(!next);
    }
  };

  return (
    <ThemeContext.Provider value={{ isDark, setDark }}>
      {children}
    </ThemeContext.Provider>
  );
};
