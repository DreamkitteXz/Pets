import React, { useEffect, useState } from 'react';
import { FONT, BRAND_NAME } from './fonts';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../../context/AuthContext';

const NAV_LINKS = [
  { label: 'Funcionalidades', href: '#servicos' },
  { label: 'Sobre',           href: '#sobre'    },
];

const Navbar = () => {
  const [scrolled, setScrolled] = useState(false);
  const { user, loading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 30);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <nav
      className="fixed inset-x-0 top-0 z-40 flex items-center"
      style={{
        height: '76px',
        backgroundColor: scrolled ? 'rgba(255,255,255,0.92)' : 'rgba(255,255,255,0)',
        // blur(0px) instead of 'none' so the blur itself can transition
        backdropFilter: scrolled ? 'blur(16px) saturate(1.5)' : 'blur(0px) saturate(1)',
        WebkitBackdropFilter: scrolled ? 'blur(16px) saturate(1.5)' : 'blur(0px) saturate(1)',
        borderBottom: `1px solid ${scrolled ? 'rgba(3,43,67,0.07)' : 'transparent'}`,
        transition: 'background-color 200ms ease, border-color 200ms ease, backdrop-filter 200ms ease, -webkit-backdrop-filter 200ms ease',
      }}
    >
      <div className="landing-container flex items-center">
        {/* Logo — provisional slot until the real mark exists */}
        <a
          href="#hero"
          className="flex items-center gap-2.5 no-underline hover:no-underline"
          style={{ fontFamily: FONT, fontWeight: 600, fontSize: '20px', color: '#032b43', letterSpacing: '-0.02em' }}
        >
          <span className="landing-logo-slot" aria-hidden="true" />
          {BRAND_NAME}
        </a>

        {/* Nav links — hidden on small screens, the page is a single scroll */}
        <div className="hidden md:flex items-center">
          <div className="mx-7 h-7 w-px flex-shrink-0" style={{ background: 'rgba(3,43,67,0.15)' }} />
          <div className="flex gap-7">
            {NAV_LINKS.map(({ label, href }) => (
              <a key={label} href={href} className="landing-nav-link">
                {label}
              </a>
            ))}
          </div>
        </div>

        {/* Auth buttons */}
        <div className="ml-auto flex gap-2">
          <button
            type="button"
            disabled={loading}
            onClick={() => navigate(user ? '/app' : '/auth')}
            className="landing-btn landing-btn--sm landing-btn--glass"
          >
            Entrar
          </button>
          {!user && (
            <Link to="/auth" state={{ mode: 'signup' }} className="landing-btn landing-btn--sm landing-btn--dark">
              Criar conta
            </Link>
          )}
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
