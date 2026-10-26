import React from 'react';
import { Link } from 'react-router-dom';
import { FONT, BRAND_NAME } from './fonts';
import { useAuth } from '../../../context/AuthContext';

// ─── Figma brand colors ────────────────────────────────────────────────────────
// Footer background: #023047 (Figma node 25:548)
// ─────────────────────────────────────────────────────────────────────────────

// Only destinations that exist. Add links here when their pages ship.
const FOOTER_LINKS = [
  { label: 'Funcionalidades', href: '#servicos' },
  { label: 'Sobre',           href: '#sobre'    },
];

const FooterSection = () => {
  const { user } = useAuth();

  return (
  <footer className="landing-footer" style={{ backgroundColor: '#023047', fontFamily: FONT }}>
    <div className="landing-container" style={{ paddingTop: 'clamp(56px, 6vw, 88px)', paddingBottom: '32px' }}>
      <div className="flex flex-col gap-10 md:flex-row md:items-start md:justify-between">
        {/* Brand */}
        <div className="max-w-[340px]">
          <div className="flex items-center gap-2.5 mb-4" style={{ color: '#f0f4f3' }}>
            <span className="landing-logo-slot" aria-hidden="true" />
            <span style={{ fontWeight: 600, fontSize: '20px', letterSpacing: '-0.02em' }}>{BRAND_NAME}</span>
          </div>
          <p className="landing-text-pretty" style={{ fontSize: '15px', lineHeight: 1.7, color: 'rgba(240,244,243,0.6)' }}>
            Vacinas, consultas e histórico do seu pet, compartilhados com o veterinário.
          </p>
        </div>

        {/* Navigation + actions */}
        <div className="flex flex-col gap-6 sm:flex-row sm:items-center sm:gap-10">
          <nav aria-label="Rodapé">
            <ul className="flex gap-7 list-none p-0 m-0">
              {FOOTER_LINKS.map(({ label, href }) => (
                <li key={label}>
                  <a href={href} className="landing-footer-link" style={{ fontWeight: 500, fontSize: '15px' }}>
                    {label}
                  </a>
                </li>
              ))}
            </ul>
          </nav>
          <div className="flex gap-2">
            <Link to={user ? '/app' : '/auth'} className="landing-btn landing-btn--sm landing-btn--outline">
              Entrar
            </Link>
            {!user && (
              <Link to="/auth" state={{ mode: 'signup' }} className="landing-btn landing-btn--sm landing-btn--light">
                Criar conta
              </Link>
            )}
          </div>
        </div>
      </div>

      <p
        className="mt-14 pt-6"
        style={{
          borderTop: '1px solid rgba(240,244,243,0.1)',
          fontWeight: 500,
          fontSize: '13px',
          color: 'rgba(240,244,243,0.62)',
        }}
      >
        © {new Date().getFullYear()} {BRAND_NAME}. Todos os direitos reservados.
      </p>
    </div>
  </footer>
  );
};

export default FooterSection;
