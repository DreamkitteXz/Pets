import React from 'react';
import { Link } from 'react-router-dom';

// ─── Figma brand colors ────────────────────────────────────────────────────────
// Footer background: #023047 (Figma node 25:548)
// ─────────────────────────────────────────────────────────────────────────────

const PRODUCT_LINKS = [
  { label: 'Serviços',      href: '#servicos' },
  { label: 'Como funciona', href: '#servicos' },
  { label: 'Preços',        href: '#' },
  { label: 'Integrações',   href: '#' },
];

const COMPANY_LINKS = [
  { label: 'Sobre nós',  href: '#sobre' },
  { label: 'Blog',       href: '#' },
  { label: 'Carreiras',  href: '#' },
  { label: 'Contato',    href: '#contato' },
];

const LEGAL_LINKS = [
  { label: 'Privacidade',   href: '#' },
  { label: 'Termos de uso', href: '#' },
  { label: 'Cookies',       href: '#' },
];

// Inline SVG social icons
const IconInstagram = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <rect x="2" y="2" width="20" height="20" rx="5" ry="5"/>
    <circle cx="12" cy="12" r="4"/>
    <circle cx="17.5" cy="6.5" r="0.75" fill="currentColor" stroke="none"/>
  </svg>
);

const IconFacebook = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/>
  </svg>
);

const IconTwitter = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <path d="M4 4l16 16M20 4L4 20" strokeWidth="0" />
    <path d="M2 3h6.5l13 18H15L2 3z"/>
    <path d="M22 3l-7.5 8.5"/>
    <path d="M2 21l7.5-8.5"/>
  </svg>
);

const FooterLink = ({ label, href }) => (
  <li>
    <a
      href={href}
      className="landing-link"
      style={{
        fontFamily: 'SF Pro Display',
        fontWeight: 500,
        fontSize: '14px',
        color: 'rgba(240,244,243,0.6)',
        transition: 'color 0.2s ease',
        textDecoration: 'none',
      }}
      onMouseEnter={e => { e.currentTarget.style.color = '#f0f4f3'; }}
      onMouseLeave={e => { e.currentTarget.style.color = 'rgba(240,244,243,0.6)'; }}
    >
      {label}
    </a>
  </li>
);

const FooterCol = ({ heading, links }) => (
  <div>
    <p
      className="font-semibold uppercase mb-5"
      style={{
        fontFamily: 'SF Pro Display',
        fontSize: '11px',
        color: 'rgba(240,244,243,0.4)',
        letterSpacing: '0.18em',
      }}
    >
      {heading}
    </p>
    <ul className="space-y-3 list-none p-0 m-0">
      {links.map(({ label, href }) => (
        <FooterLink key={label} label={label} href={href} />
      ))}
    </ul>
  </div>
);

const FooterSection = () => (
  <footer style={{ backgroundColor: '#023047' }}>
    {/* ── Main body ─────────────────────────────────────────────────────── */}
    <div
      className="flex justify-between flex-wrap gap-12"
      style={{ padding: '72px 60px 60px' }}
    >
      {/* Brand column */}
      <div style={{ maxWidth: '280px', flex: '0 0 auto' }}>
        {/* Logo placeholder */}
        <div className="flex items-center gap-3 mb-5">
          <div
            className="flex items-center justify-center rounded-xl"
            style={{
              width: '40px',
              height: '40px',
              background: 'rgba(240,244,243,0.1)',
              border: '1px solid rgba(240,244,243,0.15)',
            }}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="rgba(240,244,243,0.5)" strokeWidth="1.5">
              <path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2z"/>
              <path d="M8 12h8M12 8v8"/>
            </svg>
          </div>
          <span
            style={{
              fontFamily: 'SF Pro Display',
              fontWeight: 600,
              fontSize: '18px',
              color: '#f0f4f3',
            }}
          >
            Pets
          </span>
        </div>

        <p
          style={{
            fontFamily: 'SF Pro Display',
            fontWeight: 500,
            fontSize: '14px',
            color: 'rgba(240,244,243,0.5)',
            lineHeight: 1.75,
          }}
        >
          A plataforma de saúde digital mais completa para o cuidado do seu pet.
          Praticidade, segurança e carinho em um só lugar.
        </p>

        {/* Social links */}
        <div className="flex gap-3 mt-6">
          {[IconInstagram, IconFacebook, IconTwitter].map((Icon, i) => (
            <a
              key={i}
              href="#"
              className="landing-link flex items-center justify-center"
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '8px',
                background: 'rgba(240,244,243,0.08)',
                border: '1px solid rgba(240,244,243,0.1)',
                color: 'rgba(240,244,243,0.5)',
                transition: 'background 0.2s, color 0.2s, border-color 0.2s',
              }}
              onMouseEnter={e => {
                e.currentTarget.style.background = 'rgba(240,244,243,0.14)';
                e.currentTarget.style.color = '#f0f4f3';
                e.currentTarget.style.borderColor = 'rgba(240,244,243,0.2)';
              }}
              onMouseLeave={e => {
                e.currentTarget.style.background = 'rgba(240,244,243,0.08)';
                e.currentTarget.style.color = 'rgba(240,244,243,0.5)';
                e.currentTarget.style.borderColor = 'rgba(240,244,243,0.1)';
              }}
            >
              <Icon />
            </a>
          ))}
        </div>
      </div>

      {/* Link columns */}
      <FooterCol heading="Produto"  links={PRODUCT_LINKS} />
      <FooterCol heading="Empresa"  links={COMPANY_LINKS} />
      <FooterCol heading="Legal"    links={LEGAL_LINKS} />

      {/* CTA mini column */}
      <div style={{ flex: '0 0 auto' }}>
        <p
          className="font-semibold uppercase mb-5"
          style={{
            fontFamily: 'SF Pro Display',
            fontSize: '11px',
            color: 'rgba(240,244,243,0.4)',
            letterSpacing: '0.18em',
          }}
        >
          Comece agora
        </p>
        <div className="flex flex-col gap-3">
          <Link to="/auth">
            <button
              className="cursor-pointer block w-full"
              style={{
                fontFamily: 'SF Pro Display',
                fontWeight: 600,
                fontSize: '14px',
                height: '42px',
                paddingLeft: '24px',
                paddingRight: '24px',
                borderRadius: '10px',
                background: '#f0f4f3',
                color: '#032b43',
                border: 'none',
                whiteSpace: 'nowrap',
                transition: 'background 0.2s ease, transform 0.15s ease',
              }}
              onMouseEnter={e => { e.currentTarget.style.background = '#dce8e4'; e.currentTarget.style.transform = 'translateY(-1px)'; }}
              onMouseLeave={e => { e.currentTarget.style.background = '#f0f4f3'; e.currentTarget.style.transform = 'translateY(0)'; }}
            >
              Criar conta
            </button>
          </Link>
          <Link to="/auth">
            <button
              className="cursor-pointer block w-full"
              style={{
                fontFamily: 'SF Pro Display',
                fontWeight: 600,
                fontSize: '14px',
                height: '42px',
                paddingLeft: '24px',
                paddingRight: '24px',
                borderRadius: '10px',
                background: 'transparent',
                color: 'rgba(240,244,243,0.6)',
                border: '1px solid rgba(240,244,243,0.18)',
                whiteSpace: 'nowrap',
                transition: 'border-color 0.2s, color 0.2s, transform 0.15s ease',
              }}
              onMouseEnter={e => { e.currentTarget.style.borderColor = 'rgba(240,244,243,0.38)'; e.currentTarget.style.color = '#f0f4f3'; e.currentTarget.style.transform = 'translateY(-1px)'; }}
              onMouseLeave={e => { e.currentTarget.style.borderColor = 'rgba(240,244,243,0.18)'; e.currentTarget.style.color = 'rgba(240,244,243,0.6)'; e.currentTarget.style.transform = 'translateY(0)'; }}
            >
              Entrar
            </button>
          </Link>
        </div>
      </div>
    </div>

    {/* ── Divider + copyright ─────────────────────────────────────────────── */}
    <div
      className="flex items-center justify-between flex-wrap gap-3"
      style={{
        borderTop: '1px solid rgba(240,244,243,0.08)',
        padding: '24px 60px',
      }}
    >
      <p
        style={{
          fontFamily: 'SF Pro Display',
          fontWeight: 500,
          fontSize: '13px',
          color: 'rgba(240,244,243,0.3)',
        }}
      >
        © {new Date().getFullYear()} Pets. Todos os direitos reservados.
      </p>
      <p
        style={{
          fontFamily: 'SF Pro Display',
          fontWeight: 500,
          fontSize: '13px',
          color: 'rgba(240,244,243,0.3)',
        }}
      >
        Feito com carinho para quem ama pets 🐾
      </p>
    </div>
  </footer>
);

export default FooterSection;
