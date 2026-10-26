import React, { useState, useEffect, useCallback, useRef } from 'react';
import { FONT, DISPLAY_FONT } from './fonts';
import useScrollReveal from '../../../hooks/useScrollReveal';

// ─── Assets locais (public/assets/landing/) ──────────────────────────────────
const DASH_WAVE = '/assets/landing/dash_wave.svg';
const PAW_A = '/assets/landing/icon_patinha2.svg';
const PAW_B = '/assets/landing/icon_patinha3.svg';
const PAW_C = '/assets/landing/icon_patinha4.svg';
const PAW_D = '/assets/landing/icon_patinha5.svg';
const PAW_E = '/assets/landing/icon_patinha6.svg';
const PAW_F = '/assets/landing/icon_patinha7.svg';
const PET_IMAGES = [
  '/assets/landing/step1.png',
  '/assets/landing/step2.png',
  '/assets/landing/step3.png',
  '/assets/landing/step4.png',
  '/assets/landing/step5.png',
];
// ─────────────────────────────────────────────────────────────────────────────

// Signature color of each step's bubble (used for active glow on bubble + paw tint + tab bar)
const STEP_COLORS = [
  '#5bb8d4', // Step 1 — blue
  '#3dbca3', // Step 2 — teal
  '#1a4a62', // Step 3 — navy
  '#e8a840', // Step 4 — amber
  '#e87040', // Step 5 — orange
];

const STEPS = [
  {
    title: '1º Passo — Cadastro do pet',
    description: 'O tutor cria o perfil do pet no app. Em minutos, já pode registrar vacinas, consultas e dados de saúde.',
  },
  {
    title: '2º Passo — Vínculo veterinário',
    description: 'Ao registrar uma vacina, o tutor vincula o procedimento ao médico-veterinário responsável pela aplicação.',
  },
  {
    title: '3º Passo — Sincronização automática',
    description: 'O registro aparece instantaneamente no painel do veterinário — sem sincronização manual, sem burocracia.',
  },
  {
    title: '4º Passo — Validação profissional',
    description: 'O veterinário revisa e valida o registro com um clique, garantindo a integridade do histórico de saúde.',
  },
  {
    title: '5º Passo — Carteira atualizada',
    description: 'Após a validação, a carteira de vacinação é atualizada em tempo real e disponibilizada para download no app.',
  },
];

// "1º Passo — Cadastro do pet" → "Cadastro do pet" (tab label)
const stepName = (title) => title.split(' — ')[1] || title;

const TEXT_SWAP_MS = 200; // matches .carousel-text transition

// ─── Desktop stage layout (Figma frame 29:603 — 1927 × 787 px) ──────────────
const BUBBLE_CONFIG = [
  { leftPct: '3.61%',  topPct: '38.39%', widthPct: '17.01%' }, // Step 1
  { leftPct: '21.58%', topPct: '24.81%', widthPct: '17.86%' }, // Step 2
  { leftPct: '41.05%', topPct: '19.57%', widthPct: '19.12%' }, // Step 3 — centre / highest
  { leftPct: '61.13%', topPct: '27.15%', widthPct: '17.44%' }, // Step 4
  { leftPct: '79.55%', topPct: '34.82%', widthPct: '18.92%' }, // Step 5
];

// Paw decorations — positioned inside the stage (% of frame)
// `zone` = which step's color glow this paw inherits
const STAGE_PAWS = [
  { src: PAW_A, left: '4.59%',  top: '49.6%', rotate: '-52.79deg', opacity: 1,   zone: 0 },
  { src: PAW_A, left: '10.04%', top: '48.8%', rotate: '-52.79deg', opacity: 1,   zone: 0 },
  { src: PAW_A, left: '5.52%',  top: '61.0%', rotate: '-52.79deg', opacity: 1,   zone: 0 },
  { src: PAW_A, left: '13.83%', top: '37.0%', rotate: '-37.25deg', opacity: 0.5, zone: 0 },
  { src: PAW_B, left: '18.8%',  top: '41.3%', rotate: '-39.45deg', opacity: 1,   zone: 1 },
  { src: PAW_B, left: '24.05%', top: '30.7%', rotate: '-29.78deg', opacity: 1,   zone: 1 },
  { src: PAW_B, left: '29.5%',  top: '35.4%', rotate: '-35.99deg', opacity: 1,   zone: 1 },
  { src: PAW_B, left: '33.9%',  top: '26.9%', rotate: '-28.78deg', opacity: 1,   zone: 1 },
  { src: PAW_C, left: '38.7%',  top: '33.7%', rotate: '-31.64deg', opacity: 1,   zone: 2 },
  { src: PAW_C, left: '53.9%',  top: '29.1%', rotate: '-15.81deg', opacity: 1,   zone: 2 },
  { src: PAW_D, left: '59.6%',  top: '32.1%', rotate: '-3.09deg',  opacity: 1,   zone: 3 },
  { src: PAW_E, left: '62.5%',  top: '40.9%', rotate: '4.14deg',   opacity: 1,   zone: 3 },
  { src: PAW_F, left: '77.2%',  top: '40.2%', rotate: '-14.61deg', opacity: 1,   zone: 3 },
  { src: PAW_F, left: '92.6%',  top: '49.4%', rotate: '-21.66deg', opacity: 1,   zone: 4 },
];

// One pet bubble. The active glow is a static drop-shadow copy underneath —
// only its opacity animates (compositor-only), never `filter`.
const Bubble = ({ index, isActive, onSelect, style, buttonRef }) => (
  <button
    ref={buttonRef}
    type="button"
    className="carousel-bubble"
    onClick={() => onSelect(index)}
    aria-label={STEPS[index].title}
    aria-controls="step-panel"
    aria-current={isActive ? 'step' : undefined}
    style={{
      transform: isActive ? 'scale(1.09)' : 'scale(0.93)',
      transition: 'transform 300ms cubic-bezier(0.23, 1, 0.32, 1)',
      zIndex: isActive ? 3 : 1,
      transformOrigin: 'bottom center',
      ...style,
    }}
  >
    <div style={{ position: 'relative' }}>
      <img
        src={PET_IMAGES[index]}
        alt=""
        aria-hidden="true"
        loading="lazy"
        decoding="async"
        style={{
          position: 'absolute',
          inset: 0,
          width: '100%',
          height: 'auto',
          display: 'block',
          filter: `drop-shadow(0px 12px 28px rgba(0,0,0,0.15)) drop-shadow(0px 0px 18px ${STEP_COLORS[index]}55)`,
          opacity: isActive ? 1 : 0,
          transition: 'opacity 300ms ease',
        }}
      />
      <img
        src={PET_IMAGES[index]}
        alt=""
        loading="lazy"
        decoding="async"
        style={{
          position: 'relative',
          width: '100%',
          height: 'auto',
          display: 'block',
          filter: 'drop-shadow(0px 4px 10px rgba(0,0,0,0.08))',
        }}
      />
    </div>
  </button>
);

const HowItWorksSection = () => {
  const [headRef, headVisible] = useScrollReveal(0.1);
  // `active` drives bubbles/tabs immediately (instant feedback);
  // `shown` drives the text, swapped mid-crossfade.
  const [active, setActive]         = useState(0);
  const [shown, setShown]           = useState(0);
  const [textHidden, setTextHidden] = useState(false);
  const swapRef                     = useRef(null);
  const stripRef                    = useRef(null);
  const stripItemRefs               = useRef([]);
  const tabRefs                     = useRef([]);

  const goTo = useCallback((nextIndex) => {
    setActive(nextIndex);
    setTextHidden(true);
    clearTimeout(swapRef.current);
    swapRef.current = setTimeout(() => {
      setShown(nextIndex);
      setTextHidden(false);
    }, TEXT_SWAP_MS);
  }, []);

  useEffect(() => () => clearTimeout(swapRef.current), []);

  // Centre a bubble inside the mobile strip (no scrollIntoView — it scrolls the page)
  const centerInStrip = useCallback((item) => {
    const strip = stripRef.current;
    if (!strip || !item || strip.offsetParent === null) return;
    strip.scrollTo({
      left: item.offsetLeft - (strip.clientWidth - item.clientWidth) / 2,
      behavior: 'smooth',
    });
  }, []);

  // Keep the active bubble in view
  useEffect(() => {
    centerInStrip(stripItemRefs.current[active]);
  }, [active, centerInStrip]);

  // Arrow-key navigation across tabs (WAI-ARIA tabs pattern)
  const onTabKeyDown = (e) => {
    const delta = { ArrowRight: 1, ArrowLeft: -1 }[e.key];
    let next;
    if (delta) next = (active + delta + STEPS.length) % STEPS.length;
    else if (e.key === 'Home') next = 0;
    else if (e.key === 'End') next = STEPS.length - 1;
    else return;
    e.preventDefault();
    goTo(next);
    tabRefs.current[next]?.focus();
  };

  const step = STEPS[shown];

  return (
    <section id="servicos" className="relative overflow-hidden bg-white" style={{ paddingBottom: 'clamp(80px, 9vw, 140px)' }}>
      {/* The dashed wave separator lives at the end of AboutSection — one is enough. */}
      {/* ── Section header ────────────────────────────────────────────────── */}
      <div
        ref={headRef}
        className="landing-reveal landing-container relative z-[1] text-center"
        style={{
          paddingTop: 'clamp(48px, 5vw, 80px)',
          opacity: headVisible ? 1 : 0,
          transform: headVisible ? 'translateY(0)' : 'translateY(24px)',
          transition: 'opacity 0.5s ease, transform 0.55s cubic-bezier(0.23, 1, 0.32, 1)',
        }}
      >
        <h2
          className="landing-text-pretty mx-auto"
          style={{
            fontFamily: DISPLAY_FONT,
            fontWeight: 700,
            fontSize: 'clamp(32px, 3.4vw, 52px)',
            lineHeight: 1.1,
            letterSpacing: '-0.025em',
            color: '#032b43',
            maxWidth: '20ch',
          }}
        >
          Documentação veterinária em 5 passos,{' '}
          <span style={{ color: '#2a76a3' }}>sem burocracia</span>
        </h2>
      </div>

      {/* ── Desktop stage — aspect-ratio shell (1927:787) keeps the Figma composition ── */}
      <div className="relative hidden lg:block w-full mt-10" style={{ aspectRatio: '1927 / 787' }}>
        <img
          src={DASH_WAVE}
          alt=""
          className="absolute inset-0 block w-full h-full pointer-events-none select-none"
          style={{ objectFit: 'fill' }}
        />

        {STAGE_PAWS.map((p, i) => {
          const pawImgStyle = {
            width: 'min(117px, 6.1vw)',
            height: 'min(117px, 6.1vw)',
            display: 'block',
            borderRadius: '50%',
            objectFit: 'cover',
          };
          return (
            <div
              key={i}
              className="absolute flex items-center justify-center overflow-hidden pointer-events-none select-none"
              style={{
                left: p.left,
                top: p.top,
                width: 'min(164px, 8.5vw)',
                height: 'min(164px, 8.5vw)',
                opacity: p.opacity,
              }}
            >
              <div style={{ position: 'relative', transform: `rotate(${p.rotate})`, flexShrink: 0 }}>
                <img
                  src={p.src}
                  alt=""
                  aria-hidden="true"
                  style={{
                    ...pawImgStyle,
                    position: 'absolute',
                    inset: 0,
                    filter: `drop-shadow(0px 0px 7px ${STEP_COLORS[p.zone]})`,
                    opacity: p.zone === active ? 1 : 0,
                    transition: 'opacity 300ms ease',
                  }}
                />
                <img src={p.src} alt="" style={{ ...pawImgStyle, position: 'relative' }} />
              </div>
            </div>
          );
        })}

        {BUBBLE_CONFIG.map((b, i) => (
          <Bubble
            key={i}
            index={i}
            isActive={i === active}
            onSelect={goTo}
            style={{ position: 'absolute', left: b.leftPct, top: b.topPct, width: b.widthPct }}
          />
        ))}
      </div>

      {/* ── Mobile strip — horizontal scroll-snap ─────────────────────────── */}
      {/* Keyboard focus also brings the focused bubble into view */}
      <div
        ref={stripRef}
        className="bubble-strip lg:hidden mt-6"
        onFocus={(e) => centerInStrip(e.target)}
      >
        {PET_IMAGES.map((_, i) => (
          <Bubble
            key={i}
            index={i}
            isActive={i === active}
            onSelect={goTo}
            buttonRef={(el) => { stripItemRefs.current[i] = el; }}
          />
        ))}
      </div>

      {/* ── Step tabs — every step is visible and reachable, nothing auto-advances ── */}
      <div className="landing-container">
        <div
          role="tablist"
          aria-label="Passos"
          className="mx-auto grid grid-cols-5 gap-3 md:gap-6 max-w-[1080px] lg:-mt-6"
          onKeyDown={onTabKeyDown}
        >
          {STEPS.map((s, i) => (
            <button
              key={i}
              ref={(el) => { tabRefs.current[i] = el; }}
              type="button"
              role="tab"
              id={`step-tab-${i}`}
              aria-selected={i === active}
              aria-controls="step-panel"
              aria-label={s.title}
              tabIndex={i === active ? 0 : -1}
              className="step-tab"
              style={{ '--step-color': STEP_COLORS[i] }}
              onClick={() => goTo(i)}
            >
              <span style={{ fontFamily: DISPLAY_FONT, fontWeight: 700, fontSize: '15px', fontVariantNumeric: 'tabular-nums' }}>
                {String(i + 1).padStart(2, '0')}
              </span>
              <span
                className="hidden md:block landing-text-pretty"
                style={{ fontFamily: FONT, fontWeight: 600, fontSize: '15px', lineHeight: 1.3 }}
              >
                {stepName(s.title)}
              </span>
            </button>
          ))}
        </div>

        {/* ── Step panel ──────────────────────────────────────────────────── */}
        <div
          id="step-panel"
          role="tabpanel"
          aria-labelledby={`step-tab-${shown}`}
          className="carousel-text mx-auto text-center"
          data-hidden={textHidden}
          style={{ maxWidth: '640px', marginTop: 'clamp(32px, 4vw, 48px)', minHeight: '150px' }}
        >
          <h3
            style={{
              fontFamily: DISPLAY_FONT,
              fontWeight: 700,
              fontSize: 'clamp(22px, 1.8vw, 30px)',
              letterSpacing: '-0.02em',
              color: '#032b43',
              marginBottom: '12px',
            }}
          >
            {/* The number already lives in the active tab — the heading carries only the name */}
            {stepName(step.title)}
          </h3>
          <p
            className="landing-text-pretty"
            style={{
              fontFamily: FONT,
              fontWeight: 400,
              fontSize: '17px',
              lineHeight: 1.7,
              color: 'rgba(3,43,67,0.75)',
            }}
          >
            {step.description}
          </p>
        </div>
      </div>
    </section>
  );
};

export default HowItWorksSection;
