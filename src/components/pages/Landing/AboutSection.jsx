import React from 'react';
import useScrollReveal from '../../../hooks/useScrollReveal';

// ─── Assets locais (public/assets/landing/) ──────────────────────────────────
const BLOB_BG  = '/assets/landing/about_blob.svg';
const BEAGLE   = '/assets/landing/beagle.png';
const WAVE_BTM = '/assets/landing/about_wave.svg';
const PAW_1    = '/assets/landing/icon_patinha1.svg';
const PAW_MAIN = '/assets/landing/icon_patinha.svg';
// ─────────────────────────────────────────────────────────────────────────────

const PAW_TRAIL = [
  { left: 0,        top: '40px',   rotate: '-3.09deg'  },
  { left: '4.3%',   top: '32px',   rotate: '-33.88deg' },
  { left: '8.28%',  top: '-32px',  rotate: '-52.79deg' },
  { left: '11.51%', top: '-118px', rotate: '-72.87deg' },
  { left: '16.35%', top: '-166px', rotate: '-52.79deg' },
];

const Highlight = ({ children, color }) => (
  <strong style={{ fontFamily: 'SF Pro Display', fontWeight: 700, color }}>
    {children}
  </strong>
);

const revealStyle = (visible, delay = 0) => ({
  opacity: visible ? 1 : 0,
  transform: visible ? 'translateY(0)' : 'translateY(28px)',
  transition: `opacity 0.7s ease ${delay}ms, transform 0.75s cubic-bezier(0.16, 1, 0.3, 1) ${delay}ms`,
});

const AboutSection = () => {
  const [titleRef, titleVisible] = useScrollReveal(0.15);
  const [textRef,  textVisible]  = useScrollReveal(0.12);
  const [blobRef,  blobVisible]  = useScrollReveal(0.08);

  return (
    <section
      id="sobre"
      className="relative bg-white overflow-hidden"
      style={{ paddingTop: '100px', paddingBottom: '0px' }}
    >
      {/* Paw trail — top-left decorative scatter */}
      {PAW_TRAIL.map((p, i) => (
        <div
          key={i}
          className="absolute flex items-center justify-center overflow-hidden pointer-events-none select-none"
          style={{ left: p.left, top: p.top, width: '162px', height: '162px' }}
        >
          <div style={{ transform: `rotate(${p.rotate})` }}>
            <img
              src={PAW_1}
              alt=""
              style={{ width: '117px', height: '117px', display: 'block', borderRadius: '50%', objectFit: 'cover' }}
            />
          </div>
        </div>
      ))}

      {/* ── Main content row ──────────────────────────────────────────────── */}
      {/*
        At 1920px the Figma has:
          left-padding  = 10.68%  (205px)
          text column   = ~43%    (833px)
          gap           = ~0.7%   (13px)
          blob column   = 40.7%   (782px)
          right-padding = 4.5%    (87px)
        Using flex-1 for text and a fixed vw width for the blob reproduces this
        at every viewport without overflow.
      */}
      <div
        className="flex items-center"
        style={{ paddingLeft: '10.68%', paddingRight: '4.5%', gap: '2%' }}
      >
        {/* Left column: title + body — grows/shrinks freely */}
        <div style={{ flex: '1 1 0', minWidth: 0 }}>
          <h2
            ref={titleRef}
            style={{
              fontFamily: 'SF Pro Display',
              fontSize: 'clamp(22px, 1.875vw, 36px)',
              fontWeight: 700,
              lineHeight: 1.3,
              color: '#000',
              marginBottom: '36px',
              ...revealStyle(titleVisible),
            }}
          >
            O cuidado que seu pet merece,
            <br />na palma da sua mão.
          </h2>

          <div
            ref={textRef}
            style={{
              fontFamily: 'SF Pro Display',
              fontWeight: 500,
              fontSize: 'clamp(14px, 0.9375vw, 18px)',
              lineHeight: 1.85,
              color: 'rgba(0,0,0,0.8)',
              ...revealStyle(textVisible, 100),
            }}
          >
            <p style={{ marginBottom: '22px' }}>
              Centralizamos toda a jornada de saúde do seu pet — de vacinas a consultas,
              do histórico médico às notificações de lembretes. Tudo{' '}
              <Highlight color="#80c3e8">organizado</Highlight>,{' '}
              <Highlight color="#80c3e8">seguro</Highlight> e{' '}
              <Highlight color="#80c3e8">acessível</Highlight>{' '}
              para tutores e veterinários.
            </p>
            <p>
              Desenvolvemos um sistema que conecta tutores a veterinários com precisão
              e transparência. Porque quando se trata de saúde animal,{' '}
              <Highlight color="#cb8657">cada detalhe importa</Highlight>.
            </p>
          </div>
        </div>

        {/* Right column: blob + Beagle — fixed proportional width, never shrinks */}
        <div
          ref={blobRef}
          className="hero-float"
          style={{
            position: 'relative',
            flexShrink: 0,
            width: 'min(783px, 40.8vw)',
            height: 'min(600px, 31.25vw)',
            minWidth: '260px',
            animationDelay: '0.4s',
            ...revealStyle(blobVisible, 80),
          }}
        >
          {/* Blob background — organic teal shape */}
          <img
            src={BLOB_BG}
            alt=""
            style={{
              position: 'absolute',
              inset: 0,
              width: '100%',
              height: '100%',
              display: 'block',
              objectFit: 'fill',
            }}
          />

          {/* Beagle — occupies the left 68% of the blob, vertically inset 5% */}
          <img
            src={BEAGLE}
            alt="Beagle"
            style={{
              position: 'absolute',
              left: 0,
              top: '5.45%',
              width: '68.1%',
              height: '90.5%',
              objectFit: 'contain',
              objectPosition: 'bottom left',
            }}
          />

          {/* Paw accent — bottom-right of blob */}
          <div
            className="absolute flex items-center justify-center overflow-hidden pointer-events-none select-none"
            style={{ right: '8%', bottom: '10%', width: '125px', height: '125px' }}
          >
            <div style={{ transform: 'rotate(26deg)', opacity: 0.55 }}>
              <img
                src={PAW_MAIN}
                alt=""
                style={{ width: '117px', height: '117px', display: 'block', borderRadius: '50%', objectFit: 'cover' }}
              />
            </div>
          </div>
        </div>
      </div>

      {/* ── Wave transition → HowItWorks section ────────────────────────── */}
      <div
        className="relative pointer-events-none select-none"
        style={{ marginTop: '60px', left: '-4px', width: 'calc(100% + 8px)' }}
      >
        <img src={WAVE_BTM} alt="" style={{ width: '100%', display: 'block' }} />
      </div>
    </section>
  );
};

export default AboutSection;
