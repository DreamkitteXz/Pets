import React, { useState, useEffect, useRef } from "react";
import { Bell, MessageSquare, ChevronDown, User, Bookmark, MessageCircle, Settings, LogOut, CheckCircle, XCircle } from "lucide-react";
import { auth, db } from "../../../config/firebase";
import { doc, getDoc } from "firebase/firestore";
import { signOut } from "firebase/auth";
import { useNavigate } from "react-router-dom";
import LogoutModal from "../LogoutModal/LogoutModal";
import { useNotifications } from "../../../hooks/useNotifications";
import { useChatUnread } from "../../../hooks/useChatMock";
import { toDate } from "../../../utils/dates";

export default function Header() {
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const [showNotifMenu, setShowNotifMenu] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showLogoutModal, setShowLogoutModal] = useState(false);
  const menuRef = useRef(null);
  const notifRef = useRef(null);
  const navigate = useNavigate();
  const { notifications, unreadCount, markAllRead } = useNotifications();
  const chatUnread = useChatUnread();

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

  // Close menus on outside click
  useEffect(() => {
    const handle = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target)) setShowProfileMenu(false);
      if (notifRef.current && !notifRef.current.contains(e.target)) setShowNotifMenu(false);
    };
    document.addEventListener('mousedown', handle);
    return () => document.removeEventListener('mousedown', handle);
  }, []);

  const handleLogoutClick = () => { setShowLogoutModal(true); setShowProfileMenu(false); };
  const handleLogoutConfirm = async () => {
    try { await signOut(auth); navigate("/auth"); }
    catch (e) { console.error(e); }
    finally { setShowLogoutModal(false); }
  };

  const toggleNotif = () => {
    const opening = !showNotifMenu;
    setShowNotifMenu(opening);
    if (opening) markAllRead();
  };

  const notifText = (n) => {
    if (n.type === 'VACCINE_VALIDATION') {
      return n.status === 'rejected' ? 'Uma vacina foi rejeitada' : 'Uma vacina foi validada';
    }
    return 'Notificação';
  };
  const notifTime = (n) => {
    const d = toDate(n.createdAt);
    return d ? d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }) : '';
  };

  return (
    <>
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

        {/* Right — messages + bell + profile */}
        <div className="flex items-center gap-2">

          {/* Messages → chat (T2 badge / T3 navega) */}
          <button
            onClick={() => navigate('/chat')}
            className="relative w-9 h-9 rounded-[10px] flex items-center justify-center transition-all duration-150"
            style={{ color: 'var(--text-secondary)' }}
            onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.12)'}
            onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
            title="Mensagens"
            aria-label="Mensagens"
          >
            <MessageSquare size={20} strokeWidth={1.5} />
            {chatUnread > 0 && (
              <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full" style={{ background: 'var(--apple-red)' }} />
            )}
          </button>

          {/* Notifications */}
          <div className="relative" ref={notifRef}>
            <button
              onClick={toggleNotif}
              className="relative w-9 h-9 rounded-[10px] flex items-center justify-center transition-all duration-150"
              style={{ color: 'var(--text-secondary)' }}
              onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.12)'}
              onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
            >
              <Bell size={20} strokeWidth={1.5} />
              {unreadCount > 0 && (
                <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full" style={{ background: 'var(--apple-red)' }} />
              )}
            </button>

            {showNotifMenu && (
              <div className="absolute right-0 mt-2 w-[320px] rounded-[14px] py-1 z-50 overflow-hidden fade-in-up"
                style={{ background: 'var(--surface-elevated)', boxShadow: '0 8px 40px rgba(0,0,0,0.14), 0 0 0 1px rgba(0,0,0,0.06)', animationDuration: '0.2s' }}>
                <div className="px-4 py-3" style={{ borderBottom: '1px solid var(--separator)' }}>
                  <p className="text-[14px] font-semibold" style={{ color: 'var(--text-primary)' }}>Notificações</p>
                </div>
                {notifications.length === 0 ? (
                  <div className="px-4 py-8 text-center" style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>
                    Nenhuma notificação.
                  </div>
                ) : (
                  <div className="max-h-[340px] overflow-y-auto">
                    {notifications.slice(0, 20).map((n) => {
                      const rejected = n.status === 'rejected';
                      const Icon = rejected ? XCircle : CheckCircle;
                      const color = rejected ? 'var(--apple-red)' : 'var(--apple-green)';
                      return (
                        <div key={n.id} className="px-4 py-3 flex items-start gap-3" style={{ borderBottom: '1px solid var(--separator)' }}>
                          <Icon size={16} strokeWidth={1.75} style={{ color, flexShrink: 0, marginTop: '2px' }} />
                          <div className="min-w-0">
                            <p className="text-[14px]" style={{ color: 'var(--text-primary)' }}>{notifText(n)}</p>
                            <p className="text-[12px]" style={{ color: 'var(--text-tertiary)' }}>{notifTime(n)}</p>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            )}
          </div>

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
