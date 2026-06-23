import React, { useState, useEffect } from "react";
import { DASHBOARD_SIDEBAR_BOTTOM_LINKS, DASHBOARD_SIDEBAR_LINKS, TUTOR_SIDEBAR_LINKS } from "../../../lib/consts/navigation";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { auth, db } from "../../../config/firebase";
import { doc, getDoc } from "firebase/firestore";
import { signOut } from "firebase/auth";
import { LogOut, ChevronLeft } from "lucide-react";
import LogoWhite from "../../../assets/logos/logo_white";
import LogoutModal from "../LogoutModal/LogoutModal";

export default function SideBar() {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showLogoutModal, setShowLogoutModal] = useState(false);
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

  const handleLogoutConfirm = async () => {
    try {
      await signOut(auth);
      navigate("/auth");
    } catch (error) {
      console.error("Error signing out:", error);
    } finally {
      setShowLogoutModal(false);
    }
  };

  return (
    <>
      <aside
        style={{ background: '#1C1C1E', borderRight: '1px solid rgba(84,84,88,0.4)' }}
        className={`flex flex-col transition-all duration-300 ease-in-out flex-shrink-0 ${isCollapsed ? 'w-[72px]' : 'w-[240px]'}`}
      >
        {/* Logo + collapse */}
        <div className="flex items-center justify-between h-[60px] px-4 flex-shrink-0" style={{ borderBottom: '1px solid rgba(84,84,88,0.25)' }}>
          {/* TODO: re-adicionar logo */}
          {/* {!isCollapsed && (
            <div className="overflow-hidden">
              <LogoWhite />
            </div>
          )} */}
          {isCollapsed && (
            <div
              className="w-9 h-9 rounded-[10px] flex items-center justify-center font-bold text-base mx-auto"
              style={{ background: 'rgba(255,255,255,0.08)', color: '#fff' }}
            >
              P
            </div>
          )}
          <button
            onClick={() => setIsCollapsed(!isCollapsed)}
            className="flex-shrink-0 rounded-[8px] p-1.5 transition-all duration-200"
            style={{ color: 'rgba(255,255,255,0.35)' }}
            onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,255,255,0.07)'}
            onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
          >
            <ChevronLeft
              size={16}
              strokeWidth={2}
              style={{ transform: isCollapsed ? 'rotate(180deg)' : 'none', transition: 'transform 0.3s' }}
            />
          </button>
        </div>

        {/* Main nav — links depend on the user's role */}
        <nav className="flex-1 py-3 px-2 space-y-0.5 overflow-y-auto">
          {(currentUser?.role === 'tutor' ? TUTOR_SIDEBAR_LINKS : DASHBOARD_SIDEBAR_LINKS).map((item) => (
            <SideBarLink key={item.key} item={item} isCollapsed={isCollapsed} />
          ))}
        </nav>

        {/* Bottom nav */}
        <div className="px-2 pb-3 space-y-0.5" style={{ borderTop: '1px solid rgba(84,84,88,0.25)', paddingTop: '12px' }}>
          {DASHBOARD_SIDEBAR_BOTTOM_LINKS.map((item) => (
            <SideBarLink key={item.key} item={item} isCollapsed={isCollapsed} />
          ))}

          {/* Logout */}
          <button
            onClick={() => setShowLogoutModal(true)}
            className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-[10px] transition-all duration-150 text-left ${isCollapsed ? 'justify-center' : ''}`}
            style={{ color: '#FF453A' }}
            onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,69,58,0.1)'}
            onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
          >
            <LogOut size={20} strokeWidth={1.5} className="flex-shrink-0" />
            {!isCollapsed && <span className="text-[15px]">Sair</span>}
          </button>
        </div>

        {/* User profile */}
        {!loading && currentUser && (
          <div className="px-2 pb-4 flex-shrink-0" style={{ borderTop: '1px solid rgba(84,84,88,0.25)', paddingTop: '12px' }}>
            <div
              className={`flex items-center gap-3 px-3 py-2.5 rounded-[10px] transition-all duration-150 cursor-default ${isCollapsed ? 'justify-center' : ''}`}
              onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,255,255,0.06)'}
              onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
            >
              <div
                className="w-8 h-8 rounded-full flex items-center justify-center font-semibold text-sm flex-shrink-0 text-white"
                style={{ background: 'rgba(255,255,255,0.15)' }}
              >
                {currentUser.name?.charAt(0).toUpperCase() || 'V'}
              </div>
              {!isCollapsed && (
                <div className="flex flex-col min-w-0">
                  <span className="text-[13px] font-medium text-white truncate leading-tight">{currentUser.name}</span>
                  <span className="text-[11px] truncate leading-tight" style={{ color: 'rgba(255,255,255,0.45)' }}>
                    {currentUser.role === 'veterinarian' ? `CRMV: ${currentUser.crmv || '—'}` : 'Tutor'}
                  </span>
                </div>
              )}
            </div>
          </div>
        )}
      </aside>

      <LogoutModal
        isOpen={showLogoutModal}
        onClose={() => setShowLogoutModal(false)}
        onConfirm={handleLogoutConfirm}
      />
    </>
  );
}

function SideBarLink({ item, isCollapsed }) {
  const { pathname } = useLocation();
  const isActive = pathname === item.path;

  return (
    <Link
      to={item.path}
      className={`flex items-center gap-3 px-3 py-2.5 rounded-[10px] transition-all duration-150 ${isCollapsed ? 'justify-center' : ''}`}
      style={{
        background: isActive ? 'rgba(10,132,255,0.15)' : 'transparent',
        color: isActive ? '#0A84FF' : 'rgba(255,255,255,0.55)',
        fontWeight: isActive ? '600' : '400',
        fontSize: '15px',
      }}
      onMouseEnter={e => { if (!isActive) e.currentTarget.style.background = 'rgba(255,255,255,0.07)'; }}
      onMouseLeave={e => { if (!isActive) e.currentTarget.style.background = 'transparent'; }}
    >
      <span className="text-[20px] flex items-center flex-shrink-0">{item.icon}</span>
      {!isCollapsed && <span className="truncate">{item.label}</span>}
    </Link>
  );
}
