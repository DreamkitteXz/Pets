import React, { useEffect, useState } from 'react';

// ─── Assets locais (public/assets/landing/) ──────────────────────────────────
const BLOB_MASK   = '/assets/landing/blob_mask.svg';
const BLOB_FILL   = '/assets/landing/blob_fill.png';
const CORNER_DECO = '/assets/landing/corner_deco.svg';
const WAVE_BTM    = '/assets/landing/hero_wave.svg';
const PAW_MAIN    = '/assets/landing/icon_patinha.svg';
const PAW_1       = '/assets/landing/icon_patinha1.svg';
// ─────────────────────────────────────────────────────────────────────────────

// "Pets." split for staggered letter reveal
const TITLE_CHARS = ['P', 'e', 't', 's', '.'];
const CHAR_STAGGER   = 70;
const CHAR_BASE_DELAY = 220;
const TAGLINE_DELAY   = CHAR_BASE_DELAY + TITLE_CHARS.length * CHAR_STAGGER + 140;
const SUBTITLE_DELAY  = TAGLINE_DELAY + 120;
const BUTTONS_DELAY   = SUBTITLE_DELAY + 120;

const PawInBlob = ({ rotate, left, top, containerPx, innerPx, src = PAW_MAIN }) => (
  <div
    className="absolute flex items-center justify-center overflow-hidden pointer-events-none select-none"
    style={{ left, top, width: containerPx, height: containerPx }}
  >
    <div style={{ transform: `rotate(${rotate})`, flexShrink: 0 }}>
      <img src={src} alt="" className="block rounded-full object-cover" style={{ width: innerPx, height: innerPx }} />
    </div>
  </div>
);

const HeroSection = () => {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    const id = requestAnimationFrame(() => setReady(true));
    return () => cancelAnimationFrame(id);
  }, []);

  const revealStyle = (delayMs) => ({
    opacity: ready ? 1 : 0,
    transform: ready ? 'translateY(0)' : 'translateY(18px)',
    transition: `opacity 0.65s ease ${delayMs}ms, transform 0.7s cubic-bezier(0.16, 1, 0.3, 1) ${delayMs}ms`,
  });

  const btnBase = {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    height: '50px',
    paddingLeft: '28px',
    paddingRight: '28px',
    borderRadius: '14px',
    border: 'none',
    cursor: 'pointer',
    fontFamily: 'system-ui, -apple-system, Roboto, sans-serif',
    fontSize: '15px',
    fontWeight: 500,
    letterSpacing: '-0.015em',
    whiteSpace: 'nowrap',
    transition: 'transform 0.25s cubic-bezier(0.4,0,0.2,1), box-shadow 0.25s cubic-bezier(0.4,0,0.2,1)',
  };

  const btnPrimary = {
    ...btnBase,
    background: '#032b43',
    color: '#f0f4f3',
    border: '1px solid rgba(255,255,255,0.08)',
    boxShadow: '0 4px 16px rgba(3,43,67,0.28), inset 0 1px 0 rgba(255,255,255,0.06)',
  };

  const btnSecondary = {
    ...btnBase,
    background: 'rgba(240,244,243,0.7)',
    color: '#032b43',
    border: '1px solid rgba(3,43,67,0.1)',
    backdropFilter: 'blur(16px)',
    WebkitBackdropFilter: 'blur(16px)',
    boxShadow: '0 2px 8px rgba(3,43,67,0.06), inset 0 1px 0 rgba(255,255,255,0.5)',
  };

  return (
    <section
      id="hero"
      className="relative bg-white overflow-hidden"
      style={{ minHeight: '872px' }}
    >
      {/* ── Top-left corner decoration ─────────────────────────────────────── */}
      <div
        className="absolute pointer-events-none select-none"
        style={{ left: '-32px', top: '-26px', width: '299px', height: '333px', zIndex: 0 }}
      >
        <img src={CORNER_DECO} alt="" className="w-full h-full block" />
      </div>

      {/* ── Right: yellow blob + dog (floating) ───────────────────────────── */}
      <div
        className="absolute top-0 hero-float"
        style={{ left: '32.8125%', width: '67.1875%', height: '100%', minHeight: '872px', animationDelay: '0.7s' }}
      >
        <div
          className="absolute inset-0"
          style={{
            WebkitMaskImage: `url('${BLOB_MASK}')`,
            maskImage: `url('${BLOB_MASK}')`,
            WebkitMaskSize: '100% 100%',
            maskSize: '100% 100%',
            WebkitMaskRepeat: 'no-repeat',
            maskRepeat: 'no-repeat',
          }}
        >
          <img src={BLOB_FILL} alt="Golden Retriever" className="absolute inset-0 w-full h-full max-w-none object-cover block" />
        </div>

        {/* Paw prints — left cluster */}
        <PawInBlob rotate="-135.84deg" left="5.35%"  top="384px"  containerPx="165px" innerPx="117px" />
        <PawInBlob rotate="-128.51deg" left="11.18%" top="467px"  containerPx="164px" innerPx="117px" />
        <PawInBlob rotate="-95.38deg"  left="12.64%" top="600px"  containerPx="127px" innerPx="117px" />

        {/* Paw prints — right cluster */}
        <PawInBlob rotate="-137.35deg" left="83.66%" top="52px"   containerPx="165px" innerPx="117px" />
        <PawInBlob rotate="-162.2deg"  left="89.86%" top="142px"  containerPx="147px" innerPx="117px" />
        <PawInBlob rotate="-81.03deg"  left="90.45%" top="564px"  containerPx="134px" innerPx="117px" />
        <PawInBlob rotate="-90.77deg"  left="85.05%" top="639px"  containerPx="119px" innerPx="117px" />
        <PawInBlob rotate="-81.03deg"  left="86.15%" top="739px"  containerPx="134px" innerPx="117px" src={PAW_1} />
      </div>

      {/* ── Page-level paw decorations ────────────────────────────────────── */}
      <div className="absolute flex items-center justify-center overflow-hidden pointer-events-none select-none" style={{ left: '20.52%', top: '40px', width: '125px', height: '125px' }}>
        <div style={{ transform: 'rotate(4.09deg)' }}>
          <img src={PAW_1} alt="" className="block rounded-full object-cover" style={{ width: '117px', height: '117px' }} />
        </div>
      </div>
      <div className="absolute flex items-center justify-center overflow-hidden pointer-events-none select-none" style={{ left: '25.94%', top: '81px', width: '124px', height: '124px' }}>
        <div style={{ transform: 'rotate(-3.59deg)' }}>
          <img src={PAW_1} alt="" className="block rounded-full object-cover" style={{ width: '117px', height: '117px' }} />
        </div>
      </div>
      <div className="absolute flex items-center justify-center overflow-hidden pointer-events-none select-none" style={{ left: '54.79%', top: '25px', width: '157px', height: '157px' }}>
        <div style={{ transform: 'rotate(26.33deg)' }}>
          <img src={PAW_MAIN} alt="" className="block rounded-full object-cover" style={{ width: '117px', height: '117px' }} />
        </div>
      </div>
      <div className="absolute flex items-center justify-center overflow-hidden pointer-events-none select-none" style={{ left: '60.26%', top: '102px', width: '121px', height: '121px' }}>
        <div style={{ transform: 'rotate(2.24deg)' }}>
          <img src={PAW_MAIN} alt="" className="block rounded-full object-cover" style={{ width: '117px', height: '117px' }} />
        </div>
      </div>

      {/* ── Hero text content ──────────────────────────────────────────────── */}
      <div className="absolute" style={{ left: '10.68%', top: '365px' }}>
        {/* Title — letter-by-letter reveal */}
        <h1
          className="leading-none"
          style={{ fontFamily: '"Alfa Slab One", serif', fontSize: 'clamp(56px, 4.17vw, 80px)' }}
          aria-label="Pets."
        >
          {TITLE_CHARS.map((char, i) => (
            <span
              key={i}
              className="letter-reveal"
              style={{
                animationDelay: `${CHAR_BASE_DELAY + i * CHAR_STAGGER}ms`,
                animationPlayState: ready ? 'running' : 'paused',
                display: 'inline-block',
              }}
            >
              {char}
            </span>
          ))}
        </h1>
      </div>

      {/* Tagline — short, punchy, below the big title */}
      <div
        className="absolute"
        style={{ left: '10.68%', top: '462px', width: 'min(640px, 33vw)', ...revealStyle(TAGLINE_DELAY) }}
      >
        <p
          style={{
            fontFamily: 'SF Pro Display',
            fontWeight: 600,
            fontSize: 'clamp(15px, 1.04vw, 20px)',
            lineHeight: 1.35,
            color: '#032b43',
            letterSpacing: '-0.01em',
          }}
        >
          A plataforma digital de saúde animal.
        </p>
      </div>

      {/* Subtitle — concise value proposition */}
      <div
        className="absolute"
        style={{ left: '10.68%', top: '508px', width: 'min(600px, 31vw)', ...revealStyle(SUBTITLE_DELAY) }}
      >
        <p
          style={{
            fontFamily: 'SF Pro Display',
            fontWeight: 400,
            fontSize: 'clamp(13px, 0.833vw, 16px)',
            lineHeight: 1.75,
            color: 'rgba(3,43,67,0.72)',
          }}
        >
          Registre vacinas, consultas e histórico do seu pet em um único lugar —
          com acesso compartilhado entre tutores e veterinários.
        </p>
      </div>

      {/* CTA buttons */}
      <div
        className="absolute flex"
        style={{ left: '10.68%', top: '606px', gap: '12px', ...revealStyle(BUTTONS_DELAY) }}
      >
        <a href="#servicos">
          <button
            style={btnPrimary}
            onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-2px)'; e.currentTarget.style.boxShadow = '0 8px 24px rgba(3,43,67,0.32), inset 0 1px 0 rgba(255,255,255,0.08)'; }}
            onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = '0 4px 16px rgba(3,43,67,0.28), inset 0 1px 0 rgba(255,255,255,0.06)'; }}
          >
            Ver funcionalidades
          </button>
        </a>
        <a href="#sobre">
          <button
            style={btnSecondary}
            onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-2px)'; e.currentTarget.style.boxShadow = '0 6px 18px rgba(3,43,67,0.1), inset 0 1px 0 rgba(255,255,255,0.6)'; }}
            onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = '0 2px 8px rgba(3,43,67,0.06), inset 0 1px 0 rgba(255,255,255,0.5)'; }}
          >
            Saiba mais
          </button>
        </a>
      </div>

      {/* ── Bottom wave → About section ────────────────────────────────────── */}
      <div
        className="absolute pointer-events-none select-none"
        style={{ left: '-4px', bottom: '-200px', width: 'calc(100% + 8px)', zIndex: 1 }}
      >
        <img src={WAVE_BTM} alt="" className="w-full block" />
      </div>
    </section>
  );
};

export default HeroSection;
