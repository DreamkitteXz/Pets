import React from 'react';
import { FONT, DISPLAY_FONT } from './fonts';
import useScrollReveal from '../../../hooks/useScrollReveal';

// ─── Assets locais (public/assets/landing/) ──────────────────────────────────
const BLOB_BG  = '/assets/landing/about_blob.svg';
const BEAGLE   = '/assets/landing/beagle.png';
const WAVE_BTM = '/assets/landing/about_wave.svg';
const PAW_MAIN = '/assets/landing/icon_patinha.svg';
// ─────────────────────────────────────────────────────────────────────────────
// Paws are reserved for the hero blob and the steps trail, where they carry meaning.

const Highlight = ({ children, color }) => (
  <strong style={{ fontWeight: 700, color }}>{children}</strong>
);

const revealStyle = (visible, delay = 0) => ({
  opacity: visible ? 1 : 0,
  transform: visible ? 'translateY(0)' : 'translateY(24px)',
  transition: `opacity 0.5s ease ${delay}ms, transform 0.55s cubic-bezier(0.23, 1, 0.32, 1) ${delay}ms`,
});

const bodyStyle = {
  fontFamily: FONT,
  fontWeight: 400,
  fontSize: '17px',
  lineHeight: 1.75,
  color: 'rgba(3,43,67,0.78)',
  maxWidth: '60ch',
};

const AboutSection = () => {
  const [titleRef, titleVisible] = useScrollReveal(0.15);
  const [blobRef,  blobVisible]  = useScrollReveal(0.08);
  const [quoteRef, quoteVisible] = useScrollReveal(0.3);

  return (
    <section id="sobre" className="relative overflow-hidden bg-white" style={{ paddingTop: 'clamp(96px, 10vw, 160px)' }}>

      {/* ── Text + beagle ─────────────────────────────────────────────────── */}
      <div className="landing-container grid items-center gap-14 lg:grid-cols-12 lg:gap-8">
        <div ref={titleRef} className="landing-reveal lg:col-span-6" style={revealStyle(titleVisible)}>
          <h2
            className="landing-text-pretty"
            style={{
              fontFamily: DISPLAY_FONT,
              fontSize: 'clamp(32px, 3.4vw, 52px)',
              fontWeight: 700,
              lineHeight: 1.1,
              letterSpacing: '-0.025em',
              color: '#032b43',
              marginBottom: '28px',
            }}
          >
            O cuidado que seu pet merece, na palma da sua mão.
          </h2>

          <p className="landing-text-pretty" style={{ ...bodyStyle, marginBottom: '20px' }}>
            Centralizamos toda a jornada de saúde do seu pet — de vacinas a consultas,
            do histórico médico às notificações de lembretes. Tudo{' '}
            <Highlight color="#2a76a3">organizado</Highlight>,{' '}
            <Highlight color="#2a76a3">seguro</Highlight> e{' '}
            <Highlight color="#2a76a3">acessível</Highlight>{' '}
            para tutores e veterinários.
          </p>
          <p className="landing-text-pretty" style={bodyStyle}>
            Desenvolvemos um sistema que conecta tutores a veterinários com precisão
            e transparência.
          </p>
        </div>

        {/* Outer: scroll reveal transform. Inner: blob composition (static — only the hero floats). */}
        <div ref={blobRef} className="landing-reveal lg:col-span-6" style={revealStyle(blobVisible, 80)}>
          <div className="relative w-full max-w-[783px] mx-auto" style={{ aspectRatio: '783 / 599' }}>
            <img src={BLOB_BG} alt="" className="absolute inset-0 block w-full h-full" style={{ objectFit: 'fill' }} />
            <img
              src={BEAGLE}
              alt="Beagle"
              loading="lazy"
              decoding="async"
              className="absolute"
              style={{
                left: 0,
                top: '5.45%',
                width: '68.1%',
                height: '90.5%',
                objectFit: 'contain',
                objectPosition: 'bottom left',
              }}
            />
            <div
              className="absolute flex items-center justify-center overflow-hidden pointer-events-none select-none"
              style={{ right: '8%', bottom: '10%', width: '16%', aspectRatio: '1' }}
            >
              <div style={{ transform: 'rotate(26deg)', opacity: 0.55, width: '94%' }}>
                <img src={PAW_MAIN} alt="" className="block w-full rounded-full" style={{ aspectRatio: '1' }} />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Pull quote — full-width typographic break ─────────────────────── */}
      <blockquote
        ref={quoteRef}
        className="landing-reveal landing-container landing-text-pretty text-center"
        style={{
          marginTop: 'clamp(96px, 10vw, 160px)',
          fontFamily: DISPLAY_FONT,
          fontWeight: 700,
          fontSize: 'clamp(32px, 4.4vw, 68px)',
          lineHeight: 1.08,
          letterSpacing: '-0.03em',
          color: '#032b43',
          ...revealStyle(quoteVisible),
        }}
      >
        <span className="block mx-auto" style={{ maxWidth: '18ch' }}>
          Porque quando se trata de saúde animal,{' '}
          <span style={{ color: '#b87344' }}>cada detalhe importa.</span>
        </span>
      </blockquote>

      {/* ── Wave transition → HowItWorks section ────────────────────────── */}
      <img
        src={WAVE_BTM}
        alt=""
        className="relative block pointer-events-none select-none"
        style={{ marginTop: 'clamp(40px, 5vw, 80px)', left: '-4px', width: 'calc(100% + 8px)' }}
      />
    </section>
  );
};

export default AboutSection;
