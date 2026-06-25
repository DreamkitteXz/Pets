import React, { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../../context/AuthContext';

const NAV_LINKS = [
  { label: 'Funcionalidades', href: '#servicos' },
  { label: 'Sobre',           href: '#sobre'    },
];

const Navbar = () => {
  const [scrolled, setScrolled]   = useState(false);
  const [activeLink, setActiveLink] = useState(null);
  const { user, loading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 30);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const navStyle = {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 40,
    height: '76px',
    display: 'flex',
    alignItems: 'center',
    backgroundColor: scrolled ? 'rgba(255,255,255,0.92)' : 'transparent',
    backdropFilter: scrolled ? 'blur(16px) saturate(1.5)' : 'none',
    WebkitBackdropFilter: scrolled ? 'blur(16px) saturate(1.5)' : 'none',
    borderBottom: scrolled ? '1px solid rgba(3,43,67,0.07)' : 'none',
    boxShadow: scrolled ? '0 1px 20px rgba(3,43,67,0.06)' : 'none',
    transition: 'background-color 0.35s ease, box-shadow 0.35s ease, border-color 0.35s ease',
  };

  const linkStyle = (label) => ({
    fontFamily: 'SF Pro Display',
    fontWeight: 500,
    fontSize: '15px',
    letterSpacing: '-0.01em',
    color: '#000',
    textDecoration: 'none',
    paddingBottom: '2px',
    borderBottom: activeLink === label ? '1.5px solid #032b43' : '1.5px solid transparent',
    transition: 'color 0.2s ease, border-color 0.2s ease, opacity 0.2s ease',
  });

  return (
    <nav style={navStyle}>
      <div
        style={{
          width: '100%',
          display: 'flex',
          alignItems: 'center',
          paddingLeft: '10.68%',
          paddingRight: '10.68%',
        }}
      >
        {/* ── Logo ───────────────────────────────────────────────────────── */}
        <a
          href="#"
          style={{
            fontFamily: 'SF Pro Display',
            fontWeight: 600,
            fontSize: '20px',
            color: '#032b43',
            textDecoration: 'none',
            letterSpacing: '-0.02em',
          }}
        >
          Pets
        </a>

        {/* Thin divider */}
        <div style={{ width: '1px', height: '28px', background: 'rgba(3,43,67,0.15)', margin: '0 28px', flexShrink: 0 }} />

        {/* Nav links */}
        <div style={{ display: 'flex', gap: '28px' }}>
          {NAV_LINKS.map(({ label, href }) => (
            <a
              key={label}
              href={href}
              style={linkStyle(label)}
              onMouseEnter={e => {
                setActiveLink(label);
                e.currentTarget.style.opacity = '0.65';
              }}
              onMouseLeave={e => {
                setActiveLink(null);
                e.currentTarget.style.opacity = '1';
              }}
            >
              {label}
            </a>
          ))}
        </div>

        {/* Auth buttons */}
        <div style={{ marginLeft: 'auto', display: 'flex', gap: '8px' }}>
          <button
            disabled={loading}
            onClick={() => navigate(user ? '/app' : '/auth')}
            style={{
              fontFamily: 'SF Pro Display',
              fontWeight: 500,
              fontSize: '13px',
              letterSpacing: '-0.01em',
              height: '36px',
              paddingLeft: '18px',
              paddingRight: '18px',
              borderRadius: '10px',
              background: 'rgba(240,244,243,0.8)',
              color: '#032b43',
              border: '1px solid rgba(3,43,67,0.1)',
              backdropFilter: 'blur(12px)',
              WebkitBackdropFilter: 'blur(12px)',
              boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.6)',
              cursor: loading ? 'default' : 'pointer',
              opacity: loading ? 0.6 : 1,
              transition: 'background 0.2s, transform 0.15s, box-shadow 0.2s',
            }}
            onMouseEnter={e => { if (!loading) { e.currentTarget.style.background = 'rgba(220,232,228,0.9)'; e.currentTarget.style.transform = 'translateY(-1px)'; } }}
            onMouseLeave={e => { e.currentTarget.style.background = 'rgba(240,244,243,0.8)'; e.currentTarget.style.transform = 'translateY(0)'; }}
          >
            Entrar
          </button>
          <Link to="/auth" tabIndex={-1}>
            <button
              style={{
                fontFamily: 'SF Pro Display',
                fontWeight: 500,
                fontSize: '13px',
                letterSpacing: '-0.01em',
                height: '36px',
                paddingLeft: '18px',
                paddingRight: '18px',
                borderRadius: '10px',
                background: '#032b43',
                color: '#f0f4f3',
                border: '1px solid rgba(255,255,255,0.08)',
                boxShadow: '0 2px 8px rgba(3,43,67,0.25), inset 0 1px 0 rgba(255,255,255,0.06)',
                cursor: 'pointer',
                transition: 'background 0.2s, transform 0.15s, box-shadow 0.2s',
              }}
              onMouseEnter={e => { e.currentTarget.style.background = '#043d5c'; e.currentTarget.style.transform = 'translateY(-1px)'; e.currentTarget.style.boxShadow = '0 4px 14px rgba(3,43,67,0.3), inset 0 1px 0 rgba(255,255,255,0.08)'; }}
              onMouseLeave={e => { e.currentTarget.style.background = '#032b43'; e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = '0 2px 8px rgba(3,43,67,0.25), inset 0 1px 0 rgba(255,255,255,0.06)'; }}
            >
              Criar conta
            </button>
          </Link>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
