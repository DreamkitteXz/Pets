import React, { useState, useEffect, useCallback, useRef } from 'react';
import useScrollReveal from '../../../hooks/useScrollReveal';

// ─── Figma Assets (refreshed 2026-05-28) ──────────────────────────────────────

// Subtle dashed arc that introduces the section (Frame 31:604)
const WAVE_TOP  = 'https://www.figma.com/api/mcp/asset/694a4215-11cc-40ec-9552-62b89b4bc493';

// Dashed wavy arc behind all 5 pet bubbles (Vector13, 1927×674px)
const DASH_WAVE = 'https://www.figma.com/api/mcp/asset/9f1d5bd8-5fd5-41bf-ba7c-b687d6239708';

// Paw prints — 6 tint variants
const PAW_A = 'https://www.figma.com/api/mcp/asset/91704d76-b261-4446-ae32-c934a54d1389'; // IconPatinha2
const PAW_B = 'https://www.figma.com/api/mcp/asset/80119cf7-ee0f-485f-a046-e7bf277492db'; // IconPatinha3
const PAW_C = 'https://www.figma.com/api/mcp/asset/dda6cc8f-4d88-4f20-9374-a0aa2c2e1f9f'; // IconPatinha4
const PAW_D = 'https://www.figma.com/api/mcp/asset/2112c3f6-0f5e-4246-893f-353d251a56db'; // IconPatinha5
const PAW_E = 'https://www.figma.com/api/mcp/asset/8cff3f6d-60ab-4fbc-b7bb-c07a042ba98a'; // IconPatinha6
const PAW_F = 'https://www.figma.com/api/mcp/asset/3133c7a3-7bda-4e75-aca1-1877bc783296'; // IconPatinha7

// Pet bubble composites — one per step, left-to-right Figma order
const PET_IMAGES = [
  'https://www.figma.com/api/mcp/asset/a0c3dff1-8bab-4d28-947a-15fb46ec716f', // Step 1 — Siamese (blue)
  'https://www.figma.com/api/mcp/asset/5d849a05-03f9-4c61-962f-6bb8d94c7382', // Step 2 — Boxer (teal)
  'https://www.figma.com/api/mcp/asset/c6f838e5-19c8-4a30-8e2a-ef628d85e343', // Step 3 — Border Collie (navy)
  'https://www.figma.com/api/mcp/asset/1309e246-b67d-4d72-8b59-c918896d9b03', // Step 4 — Tabby (amber)
  'https://www.figma.com/api/mcp/asset/7a4e05e4-bbb8-4328-8138-b2d43d28e6e5', // Step 5 — Golden (orange)
];
// ─────────────────────────────────────────────────────────────────────────────

// Signature color of each step's bubble (used for active glow on bubble + paw tint)
const STEP_COLORS = [
  '#5bb8d4', // Step 1 — blue
  '#3dbca3', // Step 2 — teal
  '#1a4a62', // Step 3 — navy
  '#e8a840', // Step 4 — amber
  '#e87040', // Step 5 — orange
];

const STEPS = [
  {
    title: '1° Passo — Cadastro do pet',
    description: 'O tutor cria o perfil do pet no app. Em minutos, já pode registrar vacinas, consultas e dados de saúde.',
  },
  {
    title: '2° Passo — Vínculo veterinário',
    description: 'Ao registrar uma vacina, o tutor vincula o procedimento ao médico-veterinário responsável pela aplicação.',
  },
  {
    title: '3° Passo — Sincronização automática',
    description: 'O registro aparece instantaneamente no painel do veterinário — sem sincronização manual, sem burocracia.',
  },
  {
    title: '4° Passo — Validação profissional',
    description: 'O veterinário revisa e valida o registro com um clique, garantindo a integridade do histórico de saúde.',
  },
  {
    title: '5° Passo — Carteira atualizada',
    description: 'Após a validação, a carteira de vacinação é atualizada em tempo real e disponibilizada para download no app.',
  },
];

const AUTO_ADVANCE_MS = 5000;

// ─── Carousel stage layout (Figma frame 29:603 — 1927 × 787 px) ─────────────
const BUBBLE_CONFIG = [
  { leftPct: '3.61%',  topPct: '38.39%', widthPct: '17.01%' }, // Step 1
  { leftPct: '21.58%', topPct: '24.81%', widthPct: '17.86%' }, // Step 2
  { leftPct: '41.05%', topPct: '19.57%', widthPct: '19.12%' }, // Step 3 — centre / highest
  { leftPct: '61.13%', topPct: '27.15%', widthPct: '17.44%' }, // Step 4
  { leftPct: '79.55%', topPct: '34.82%', widthPct: '18.92%' }, // Step 5

];

// Paw decorations — positioned inside the carousel stage (% of frame)
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

const HowItWorksSection = () => {
  const [headRef, headVisible] = useScrollReveal(0.1);
  const [active, setActive]    = useState(0);
  const [visible, setVisible]  = useState(true);
  const [key, setKey]          = useState(0);
  const timerRef               = useRef(null);

  const startTimer = useCallback(() => {
    clearInterval(timerRef.current);
    timerRef.current = setInterval(() => {
      setVisible(false);
      setTimeout(() => {
        setActive((prev) => (prev + 1) % STEPS.length);
        setKey((k) => k + 1);
        setVisible(true);
      }, 280);
    }, AUTO_ADVANCE_MS);
  }, []);

  useEffect(() => {
    startTimer();
    return () => clearInterval(timerRef.current);
  }, [startTimer]);

  const goTo = useCallback((nextIndex) => {
    if (nextIndex === active) return;
    clearInterval(timerRef.current);
    setVisible(false);
    setTimeout(() => {
      setActive(nextIndex);
      setKey((k) => k + 1);
      setVisible(true);
      startTimer();
    }, 280);
  }, [active, startTimer]);

  const step = STEPS[active];
  const activeColor = STEP_COLORS[active];

  return (
    <section
      id="servicos"
      className="relative overflow-hidden bg-white"
      style={{ paddingBottom: '80px' }}
    >
      {/* ── Frame 31:604 — subtle dashed arc separator ────────────────────── */}
      <div
        className="pointer-events-none select-none"
        style={{ position: 'relative', left: '-4px', width: 'calc(100% + 8px)', marginBottom: '-32px' }}
      >
        <img src={WAVE_TOP} alt="" style={{ width: '100%', display: 'block' }} />
      </div>

      {/* ── Section header ────────────────────────────────────────────────── */}
      <div
        ref={headRef}
        className="text-center"
        style={{
          paddingTop: '80px',
          paddingLeft: '16.1%',
          paddingRight: '16.1%',
          position: 'relative',
          zIndex: 1,
          opacity: headVisible ? 1 : 0,
          transform: headVisible ? 'translateY(0)' : 'translateY(28px)',
          transition: 'opacity 0.7s ease, transform 0.75s cubic-bezier(0.16, 1, 0.3, 1)',
        }}
      >
        <p
          className="font-bold uppercase"
          style={{
            fontFamily: 'SF Pro Display',
            fontSize: 'clamp(11px, 0.833vw, 16px)',
            letterSpacing: '5px',
            color: 'rgba(3,43,67,0.45)',
            marginBottom: '18px',
          }}
        >
          COMO FUNCIONA
        </p>
        <h2
          className="font-bold"
          style={{
            fontFamily: 'SF Pro Display',
            fontSize: 'clamp(22px, 1.875vw, 36px)',
            lineHeight: 1.25,
            color: '#000',
            maxWidth: '900px',
            margin: '0 auto',
          }}
        >
          Documentação veterinária em 5 passos,{' '}
          <span style={{ color: '#80c3e8' }}>sem burocracia</span>
        </h2>
      </div>

      {/* ── Carousel stage ────────────────────────────────────────────────── */}
      {/*
        Aspect-ratio shell (1927:787 ≈ 40.84%) keeps all absolute elements
        proportionally positioned at every viewport width.
      */}
      <div style={{ position: 'relative', width: '100%', marginTop: '40px' }}>
        <div style={{ position: 'relative', width: '100%', paddingBottom: '40.84%', height: 0 }}>
          <div style={{ position: 'absolute', inset: 0 }}>

            {/* Dashed wavy arc background */}
            <img
              src={DASH_WAVE}
              alt=""
              style={{
                position: 'absolute',
                inset: 0,
                width: '100%',
                height: '100%',
                display: 'block',
                objectFit: 'fill',
                pointerEvents: 'none',
                userSelect: 'none',
              }}
            />

            {/* Paw decorations — tinted with active step's color when in zone */}
            {STAGE_PAWS.map((p, i) => {
              const isActiveZone = p.zone === active;
              return (
                <div
                  key={i}
                  className="flex items-center justify-center overflow-hidden"
                  style={{
                    position: 'absolute',
                    left: p.left,
                    top: p.top,
                    width: 'min(164px, 8.5vw)',
                    height: 'min(164px, 8.5vw)',
                    opacity: p.opacity,
                    pointerEvents: 'none',
                    userSelect: 'none',
                    filter: isActiveZone
                      ? `drop-shadow(0px 0px 7px ${activeColor})`
                      : 'none',
                    transition: 'filter 0.6s ease',
                  }}
                >
                  <div style={{ transform: `rotate(${p.rotate})`, flexShrink: 0 }}>
                    <img
                      src={p.src}
                      alt=""
                      style={{
                        width: 'min(117px, 6.1vw)',
                        height: 'min(117px, 6.1vw)',
                        display: 'block',
                        borderRadius: '50%',
                        objectFit: 'cover',
                      }}
                    />
                  </div>
                </div>
              );
            })}

            {/* ── 5 pet bubbles ─────────────────────────────────────────── */}
            {BUBBLE_CONFIG.map((b, i) => {
              const isActive = i === active;
              return (
                <div
                  key={i}
                  onClick={() => goTo(i)}
                  style={{
                    position: 'absolute',
                    left: b.leftPct,
                    top: b.topPct,
                    width: b.widthPct,
                    // Scale active up slightly; inactive just slightly smaller — no opacity dimming
                    transform: isActive ? 'scale(1.09)' : 'scale(0.93)',
                    // Active gets a colored drop-shadow glow; inactive just a faint shadow
                    filter: isActive
                      ? `drop-shadow(0px 12px 28px rgba(0,0,0,0.15)) drop-shadow(0px 0px 18px ${activeColor}55)`
                      : 'drop-shadow(0px 4px 10px rgba(0,0,0,0.08))',
                    transition: 'transform 0.55s cubic-bezier(0.16,1,0.3,1), filter 0.55s ease',
                    zIndex: isActive ? 3 : 1,
                    cursor: 'pointer',
                    transformOrigin: 'bottom center',
                  }}
                >
                  {/* Inner div carries the float animation without conflicting with scale */}
                  <div className={isActive ? 'carousel-bubble-float' : ''}>
                    <img
                      src={PET_IMAGES[i]}
                      alt={`Passo ${i + 1}`}
                      style={{ width: '100%', height: 'auto', display: 'block' }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* ── Step content ──────────────────────────────────────────────────── */}
      <div
        style={{
          textAlign: 'center',
          padding: '12px 24px 0',
          transition: 'opacity 0.28s ease',
          opacity: visible ? 1 : 0,
        }}
      >
        <h3
          key={`title-${key}`}
          className="carousel-in font-bold"
          style={{
            fontFamily: 'SF Pro Display',
            fontSize: 'clamp(20px, 1.5625vw, 30px)',
            color: '#000',
            marginBottom: '14px',
            animationDelay: '0.05s',
          }}
        >
          {step.title}
        </h3>
        <p
          key={`desc-${key}`}
          className="carousel-in"
          style={{
            fontFamily: 'SF Pro Display',
            fontWeight: 500,
            fontSize: 'clamp(14px, 0.9375vw, 18px)',
            lineHeight: 1.75,
            color: 'rgba(0,0,0,0.7)',
            maxWidth: '620px',
            margin: '0 auto',
            animationDelay: '0.12s',
          }}
        >
          {step.description}
        </p>
      </div>

      {/* ── Dot indicators + nav ──────────────────────────────────────────── */}
      <div
        className="flex flex-col items-center"
        style={{ marginTop: '28px', gap: '16px' }}
      >
        {/* Custom CSS pill dots — replaces pre-rendered Figma images */}
        <div
          className="flex items-center"
          role="tablist"
          aria-label="Navegação do carrossel"
          style={{ gap: '6px' }}
        >
          {STEPS.map((_, i) => (
            <button
              key={i}
              role="tab"
              aria-selected={i === active}
              aria-label={`Ir para passo ${i + 1}`}
              onClick={() => goTo(i)}
              style={{
                width:  i === active ? '28px' : '8px',
                height: '8px',
                borderRadius: '99px',
                border: 'none',
                cursor: 'pointer',
                padding: 0,
                background: i === active ? STEP_COLORS[active] : 'rgba(3,43,67,0.2)',
                boxShadow: i === active ? `0 0 8px ${STEP_COLORS[active]}88` : 'none',
                transition: 'width 0.35s cubic-bezier(0.16,1,0.3,1), background 0.4s ease, box-shadow 0.4s ease',
                outline: 'none',
              }}
              onFocus={e  => { e.currentTarget.style.outline = `2px solid ${STEP_COLORS[active]}`; }}
              onBlur={e   => { e.currentTarget.style.outline = 'none'; }}
            />
          ))}
        </div>

        {/* Prev / Next */}
        <div className="flex" style={{ gap: '10px' }}>
          {[
            { label: 'Passo anterior', delta: -1, path: 'M10 3L5 8L10 13' },
            { label: 'Próximo passo',  delta:  1, path: 'M6 3L11 8L6 13'  },
          ].map(({ label, delta, path }) => (
            <button
              key={label}
              aria-label={label}
              onClick={() => goTo((active + delta + STEPS.length) % STEPS.length)}
              className="flex items-center justify-center cursor-pointer"
              style={{
                width: '40px',
                height: '40px',
                borderRadius: '50%',
                border: '1.5px solid rgba(3,43,67,0.15)',
                background: 'rgba(255,255,255,0.9)',
                backdropFilter: 'blur(8px)',
                WebkitBackdropFilter: 'blur(8px)',
                transition: 'border-color 0.2s, background 0.2s, transform 0.2s',
                outline: 'none',
                flexShrink: 0,
              }}
              onMouseEnter={e => { e.currentTarget.style.borderColor = '#032b43'; e.currentTarget.style.transform = 'scale(1.08)'; }}
              onMouseLeave={e => { e.currentTarget.style.borderColor = 'rgba(3,43,67,0.15)'; e.currentTarget.style.transform = 'scale(1)'; }}
            >
              <svg width="14" height="14" viewBox="0 0 16 16" fill="none">
                <path d={path} stroke="#032b43" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </button>
          ))}
        </div>
      </div>
    </section>
  );
};

export default HowItWorksSection;
