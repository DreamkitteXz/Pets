import React, { useState, useEffect, useRef } from "react";
import { Bell, Search, ChevronDown, User, Bookmark, MessageCircle, Settings, LogOut } from "lucide-react";
import { auth, db } from "../../../config/firebase";
import { doc, getDoc } from "firebase/firestore";
import { signOut } from "firebase/auth";
import { useNavigate } from "react-router-dom";
import LogoutModal from "../LogoutModal/LogoutModal";

export default function Header() {
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showLogoutModal, setShowLogoutModal] = useState(false);
  const [showDevToast, setShowDevToast] = useState(false);
  const menuRef = useRef(null);
  const navigate = useNavigate();

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged(async (user) => {
      if (user) {
        const userDoc = await getDoc(doc(db, "users", user.uid));
        if (userDoc.exists()) setCurrentUser(userDoc.data());
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  // Close menu on outside click
  useEffect(() => {
    const handle = (e) => { if (menuRef.current && !menuRef.current.contains(e.target)) setShowProfileMenu(false); };
    document.addEventListener('mousedown', handle);
    return () => document.removeEventListener('mousedown', handle);
  }, []);

  const handleLogoutClick = () => { setShowLogoutModal(true); setShowProfileMenu(false); };
  const handleLogoutConfirm = async () => {
    try { await signOut(auth); navigate("/auth"); }
    catch (e) { console.error(e); }
    finally { setShowLogoutModal(false); }
  };

  const unreadCount = 2;

  const handleNotificationClick = () => {
    setShowDevToast(true);
    setTimeout(() => setShowDevToast(false), 3000);
  };

  return (
    <>
      {/* Dev toast */}
      {showDevToast && (
        <div className="fixed bottom-6 right-6 z-[100] text-white text-sm px-4 py-2.5 rounded-[12px] fade-in-up"
          style={{ background: '#1C1C1E', boxShadow: '0 8px 24px rgba(0,0,0,0.3)' }}>
          🚧 Sistema de notificações em desenvolvimento
        </div>
      )}

      <header
        className="h-[60px] flex-shrink-0 flex items-center justify-between px-6 sticky top-0 z-30"
        style={{
          backdropFilter: 'blur(20px) saturate(180%)',
          WebkitBackdropFilter: 'blur(20px) saturate(180%)',
          background: 'var(--header-bg)',
          borderBottom: '1px solid var(--separator)',
        }}
      >
        {/* Left — brand */}
        <div className="flex items-center gap-2">
          <span className="font-semibold text-[17px]" style={{ color: 'var(--text-primary)', letterSpacing: '-0.01em' }}>
            Pets
          </span>
          <span className="text-[13px]" style={{ color: 'var(--text-tertiary)' }}>
            {currentUser?.role === 'tutor' ? 'Tutor' : 'Veterinário'}
          </span>
        </div>

        {/* Right — search + bell + profile */}
        <div className="flex items-center gap-2">

          {/* Search */}
          <div className="hidden md:flex items-center gap-2 px-3 py-2 rounded-[10px] w-52"
            style={{ background: 'var(--header-search-bg)' }}>
            <Search size={14} strokeWidth={1.5} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
            <input
              type="text"
              placeholder="Buscar..."
              className="bg-transparent border-none outline-none text-[15px] w-full placeholder:text-[--apple-gray-2]"
              style={{ color: 'var(--text-primary)' }}
            />
          </div>

          {/* Bell */}
          <button
            onClick={handleNotificationClick}
            className="relative w-9 h-9 rounded-[10px] flex items-center justify-center transition-all duration-150"
            style={{ color: 'var(--text-secondary)' }}
            onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.12)'}
            onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
          >
            <Bell size={20} strokeWidth={1.5} />
            {unreadCount > 0 && (
              <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full"
                style={{ background: 'var(--apple-red)' }} />
            )}
          </button>

          {/* Profile */}
          {!loading && currentUser && (
            <div className="relative" ref={menuRef}>
              <button
                onClick={() => setShowProfileMenu(!showProfileMenu)}
                className="flex items-center gap-2 px-2.5 py-1.5 rounded-[10px] transition-all duration-150"
                onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.12)'}
                onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
              >
                <div
                  className="w-7 h-7 rounded-full flex items-center justify-center font-semibold text-[12px] text-white flex-shrink-0"
                  style={{ background: 'var(--apple-blue)' }}
                >
                  {currentUser.name?.charAt(0).toUpperCase() || 'V'}
                </div>
                <span className="hidden md:block text-[14px] font-medium max-w-[120px] truncate" style={{ color: 'var(--text-primary)' }}>
                  {currentUser.name?.split(' ')[0]}
                </span>
                <ChevronDown size={14} strokeWidth={2} style={{ color: 'var(--text-tertiary)', transform: showProfileMenu ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s' }} />
              </button>

              {/* Dropdown */}
              {showProfileMenu && (
                <div
                  className="absolute right-0 mt-2 w-[220px] rounded-[14px] py-1 z-50 overflow-hidden fade-in-up"
                  style={{
                    background: 'var(--surface-elevated)',
                    boxShadow: '0 8px 40px rgba(0,0,0,0.14), 0 0 0 1px rgba(0,0,0,0.06)',
                    animationDuration: '0.2s',
                  }}
                >
                  {/* User header */}
                  <div className="px-4 py-3" style={{ borderBottom: '1px solid var(--separator)' }}>
                    <p className="text-[14px] font-semibold" style={{ color: 'var(--text-primary)' }}>{currentUser.name}</p>
                    <p className="text-[12px]" style={{ color: 'var(--text-secondary)' }}>{currentUser.email}</p>
                  </div>

                  {/* Menu items */}
                  {[
                    { icon: User, label: 'Meu Perfil', to: '/profile' },
                    currentUser?.role === 'tutor'
                      ? { icon: Bookmark, label: 'Meus Pets', to: '/meus-pets' }
                      : { icon: Bookmark, label: 'Meus Pacientes', to: '/pets' },
                    { icon: MessageCircle, label: 'Mensagens', to: null },
                    { icon: Settings, label: 'Configurações', to: '/settings' },
                  ].map(({ icon: Icon, label, to }) => (
                    <button
                      key={label}
                      onClick={() => { setShowProfileMenu(false); if (to) navigate(to); }}
                      className="w-full flex items-center gap-3 px-4 py-2.5 text-left transition-colors duration-100"
                      style={{ color: 'var(--text-primary)', fontSize: '15px' }}
                      onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.08)'}
                      onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                    >
                      <Icon size={16} strokeWidth={1.5} style={{ color: 'var(--apple-blue)', flexShrink: 0 }} />
                      {label}
                    </button>
                  ))}

                  <div style={{ borderTop: '1px solid var(--separator)', marginTop: '4px', paddingTop: '4px' }}>
                    <button
                      onClick={handleLogoutClick}
                      className="w-full flex items-center gap-3 px-4 py-2.5 text-left transition-colors duration-100"
                      style={{ color: 'var(--apple-red)', fontSize: '15px' }}
                      onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,59,48,0.06)'}
                      onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                    >
                      <LogOut size={16} strokeWidth={1.5} style={{ flexShrink: 0 }} />
                      Sair
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </header>

      <LogoutModal
        isOpen={showLogoutModal}
        onClose={() => setShowLogoutModal(false)}
        onConfirm={handleLogoutConfirm}
      />
    </>
  );
}
