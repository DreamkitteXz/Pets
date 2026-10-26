import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { FONT, DISPLAY_FONT, BRAND_NAME } from './fonts';

// ─── Assets locais (public/assets/landing/) ──────────────────────────────────
const BLOB_MASK   = '/assets/landing/blob_mask.svg';
const BLOB_FILL   = '/assets/landing/blob_fill.jpg'; // 2000px JPEG (was 2 MB PNG); transparent area sits outside the mask
const CORNER_DECO = '/assets/landing/corner_deco.svg';
const WAVE_BTM    = '/assets/landing/hero_wave.svg';
const PAW_MAIN    = '/assets/landing/icon_patinha.svg';
const PAW_1       = '/assets/landing/icon_patinha1.svg';
// ─────────────────────────────────────────────────────────────────────────────

// Blob frame from Figma: 1290 × 872 at 1920px. Everything inside is expressed
// as % of that frame so the composition scales instead of drifting.
const BLOB_W = 1290;
const BLOB_H = 872;
const BLOB_RATIO = `${BLOB_W} / ${BLOB_H}`;

// Paw prints inside the blob — Figma px converted to % of the blob frame
const BLOB_PAWS = [
  { rotate: -135.84, left: 5.35,  top: 384, box: 165 },
  { rotate: -128.51, left: 11.18, top: 467, box: 164 },
  { rotate: -95.38,  left: 12.64, top: 600, box: 127 },
  { rotate: -137.35, left: 83.66, top: 52,  box: 165 },
  { rotate: -162.2,  left: 89.86, top: 142, box: 147 },
  { rotate: -81.03,  left: 90.45, top: 564, box: 134 },
  { rotate: -90.77,  left: 85.05, top: 639, box: 119 },
  { rotate: -81.03,  left: 86.15, top: 739, box: 134, src: PAW_1 },
];

// Paw prints that sit on the top edge of the blob (desktop only).
// The grey paws over the white text column were removed — they repeated the motif with no role.
const PAGE_PAWS = [
  { left: '54.79%', top: 25,  box: 157, rotate: 26.33 },
  { left: '60.26%', top: 102, box: 121, rotate: 2.24 },
];

const PAW_IMG = 117;

const TITLE_CHARS = [...`${BRAND_NAME}.`];
// Short sequence — the CTA must be on screen within ~0.5s
const CHAR_STAGGER    = 40;
const CHAR_BASE_DELAY = 60;
const TAGLINE_DELAY   = CHAR_BASE_DELAY + TITLE_CHARS.length * CHAR_STAGGER;
const SUBTITLE_DELAY  = TAGLINE_DELAY + 60;
const BUTTONS_DELAY   = SUBTITLE_DELAY + 60;

const Paw = ({ rotate, box, src = PAW_MAIN, style, className = 'flex' }) => (
  <div
    className={`absolute ${className} items-center justify-center overflow-hidden pointer-events-none select-none`}
    style={style}
  >
    <div style={{ transform: `rotate(${rotate}deg)`, width: `${(PAW_IMG / box) * 100}%`, flexShrink: 0 }}>
      <img src={src} alt="" className="block w-full rounded-full object-cover" style={{ aspectRatio: '1' }} />
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
    transition: `opacity 0.5s ease ${delayMs}ms, transform 0.55s cubic-bezier(0.23, 1, 0.32, 1) ${delayMs}ms`,
  });

  return (
    <section id="hero" className="relative overflow-hidden bg-white">
      {/* ── Top-left corner decoration (desktop) — starts below the nav so it never crosses the logo ── */}
      <img
        src={CORNER_DECO}
        alt=""
        className="hidden lg:block absolute pointer-events-none select-none"
        style={{ left: '-40px', top: '84px', width: 'min(170px, 10vw)', zIndex: 0 }}
      />

      {PAGE_PAWS.map((p, i) => (
        <Paw
          key={i}
          rotate={p.rotate}
          box={p.box}
          src={p.src}
          className="hidden lg:flex"
          style={{ left: p.left, top: p.top, width: `min(${p.box}px, 6.5vw)`, aspectRatio: '1', zIndex: 3 }}
        />
      ))}

      {/* Section height tracks the blob height (width × 872/1290), capped with the blob at 1040px */}
      <div className="relative lg:min-h-[max(600px,min(43.4vw,705px))] lg:flex lg:items-center">
        {/* ── Blob + dog ──────────────────────────────────────────────────
            Mobile: full-bleed on top. Tablet: narrower, right-aligned, so the CTAs stay in the first viewport.
            Desktop: anchored right, bleeding off-canvas, capped so wide screens keep the text on white. */}
        <div
          className="relative w-[118%] -ml-[9%] mt-[76px] md:w-[86%] md:ml-[18%] lg:absolute lg:top-0 lg:right-0 lg:mt-0 lg:ml-0 lg:w-[min(64vw,1040px)]"
          style={{ aspectRatio: BLOB_RATIO }}
        >
          <div className="hero-float absolute inset-0" style={{ animationDelay: '0.7s' }}>
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
              <img
                src={BLOB_FILL}
                alt="Golden Retriever sorrindo"
                width={2000}
                height={1260}
                fetchpriority="high"
                decoding="async"
                className="absolute inset-0 w-full h-full max-w-none object-cover block"
              />
            </div>

            {BLOB_PAWS.map((p, i) => (
              <Paw
                key={i}
                rotate={p.rotate}
                box={p.box}
                src={p.src}
                style={{
                  left: `${p.left}%`,
                  top: `${(p.top / BLOB_H) * 100}%`,
                  width: `${(p.box / BLOB_W) * 100}%`,
                  aspectRatio: '1',
                }}
              />
            ))}
          </div>
        </div>

        {/* ── Text column ─────────────────────────────────────────────────── */}
        <div className="landing-container relative z-[2] pt-8 pb-28 lg:py-0">
          <div className="max-w-[560px] lg:max-w-[min(500px,32vw)]">
            <p
              className="leading-none"
              style={{
                fontFamily: DISPLAY_FONT,
                fontWeight: 800,
                letterSpacing: '-0.035em',
                fontSize: 'clamp(64px, 7vw, 112px)',
                color: '#032b43',
              }}
            >
              {/* Wordmark, not the page heading — the name is provisional and says nothing
                  about the product. The value proposition below is the h1. */}
              <span className="sr-only">{BRAND_NAME}</span>
              {TITLE_CHARS.map((char, i) => (
                <span
                  key={i}
                  aria-hidden="true"
                  className="letter-reveal"
                  style={{
                    animationDelay: `${CHAR_BASE_DELAY + i * CHAR_STAGGER}ms`,
                    animationPlayState: ready ? 'running' : 'paused',
                  }}
                >
                  {char}
                </span>
              ))}
            </p>

            <h1
              className="landing-reveal landing-text-pretty mt-6"
              style={{
                fontFamily: FONT,
                fontWeight: 600,
                fontSize: 'clamp(20px, 1.5vw, 26px)',
                lineHeight: 1.3,
                letterSpacing: '-0.015em',
                color: '#032b43',
                ...revealStyle(TAGLINE_DELAY),
              }}
            >
              A plataforma digital de saúde animal.
            </h1>

            <p
              className="landing-reveal landing-text-pretty mt-4"
              style={{
                fontFamily: FONT,
                fontWeight: 400,
                fontSize: '17px',
                lineHeight: 1.65,
                color: 'rgba(3,43,67,0.72)',
                maxWidth: '60ch',
                ...revealStyle(SUBTITLE_DELAY),
              }}
            >
              Registre vacinas, consultas e histórico do seu pet em um único lugar —
              com acesso compartilhado entre tutores e veterinários.
            </p>

            <div className="landing-reveal mt-9 flex flex-wrap gap-3" style={revealStyle(BUTTONS_DELAY)}>
              <Link to="/auth" state={{ mode: 'signup' }} className="landing-btn landing-btn--lg landing-btn--dark">
                Criar conta
              </Link>
              <a href="#servicos" className="landing-btn landing-btn--lg landing-btn--glass">
                Como funciona
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* ── Bottom wave → About section ──────────────────────────────────── */}
      <img
        src={WAVE_BTM}
        alt=""
        className="absolute block pointer-events-none select-none"
        style={{ left: '-4px', width: 'calc(100% + 8px)', bottom: '-10.4vw', zIndex: 1 }}
      />
    </section>
  );
};

export default HeroSection;
