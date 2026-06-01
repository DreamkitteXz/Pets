import React, { useState } from 'react';
import { ClipboardList, CalendarCheck, Users } from 'lucide-react';
import useScrollReveal from '../../../hooks/useScrollReveal';

// ─── Figma paw decorations ────────────────────────────────────────────────────
const PAW_TL = 'https://www.figma.com/api/mcp/asset/5062962d-cbe4-4184-91f0-55740a778739';
const PAW_BR = 'https://www.figma.com/api/mcp/asset/219829e0-6b0f-4707-9c5f-49267337e232';
// ─────────────────────────────────────────────────────────────────────────────

const FEATURES = [
  {
    Icon: ClipboardList,
    accent: '#80c3e8',
    accentBg: 'rgba(128,195,232,0.12)',
    title: 'Histórico Médico Digital',
    description:
      'Registre e acesse vacinas, consultas, exames e medicamentos do seu pet com facilidade. Tudo organizado e disponível quando você precisar.',
  },
  {
    Icon: CalendarCheck,
    accent: '#cb8657',
    accentBg: 'rgba(203,134,87,0.1)',
    title: 'Agendamentos Inteligentes',
    description:
      'Marque consultas com seu veterinário e receba lembretes automáticos. Nunca mais esqueça uma vacina ou retorno importante.',
  },
  {
    Icon: Users,
    accent: '#032b43',
    accentBg: 'rgba(3,43,67,0.07)',
    title: 'Conectado ao Veterinário',
    description:
      'Compartilhe o histórico do seu pet com o veterinário de forma segura e instantânea. Menos burocracia, mais cuidado e atenção.',
  },
];

const HOVER_DEFAULT = { transform: 'translateY(0)', boxShadow: '0 4px 24px rgba(3,43,67,0.05)', borderColor: 'rgba(3,43,67,0.08)' };
const HOVER_ACTIVE  = { transform: 'translateY(-7px)', boxShadow: '0 16px 48px rgba(3,43,67,0.12)', borderColor: 'rgba(128,195,232,0.45)' };

const FeatureCard = ({ Icon, accent, accentBg, title, description, delay, visible }) => {
  const [hovered, setHovered] = useState(false);
  const hoverState = hovered ? HOVER_ACTIVE : HOVER_DEFAULT;

  return (
    <div
      style={{
        width: '519px',
        flexShrink: 0,
        background: '#ffffff',
        borderRadius: '20px',
        padding: '40px 36px',
        border: `1.5px solid ${hoverState.borderColor}`,
        boxShadow: hoverState.boxShadow,
        transform: hoverState.transform,
        transition: 'transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease, opacity 0.7s ease',
        opacity: visible ? 1 : 0,
        transitionDelay: `${delay}ms`,
        cursor: 'default',
      }}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
      {/* Icon circle */}
      <div
        className="flex items-center justify-center mb-8"
        style={{ width: '64px', height: '64px', borderRadius: '16px', background: accentBg }}
      >
        <Icon size={28} color={accent} strokeWidth={1.8} />
      </div>

      {/* Title */}
      <h3
        className="text-brand-dark font-bold mb-4 leading-tight"
        style={{fontFamily: 'SF Pro Display', fontSize: '20px' }}
      >
        {title}
      </h3>

      {/* Description */}
      <p
        className="leading-relaxed"
        style={{ fontFamily: 'SF Pro Display', fontWeight: 500, fontSize: '15px', color: 'rgba(3,43,67,0.65)' }}
      >
        {description}
      </p>

      {/* Bottom accent line (reveals on hover) */}
      <div
        className="mt-8 h-[2px] rounded-full"
        style={{
          background: accent,
          width: hovered ? '48px' : '24px',
          opacity: hovered ? 1 : 0.35,
          transition: 'width 0.3s ease, opacity 0.3s ease',
        }}
      />
    </div>
  );
};

const FeaturesSection = () => {
  const [headRef, headVisible]   = useScrollReveal(0.15);
  const [cardsRef, cardsVisible] = useScrollReveal(0.08);

  return (
    <section
      id="servicos"
      className="relative bg-white overflow-hidden"
      style={{ paddingTop: '100px', paddingBottom: '100px' }}
    >
      {/* Paw decorations */}
      <img src={PAW_TL} alt="" className="absolute pointer-events-none select-none" style={{ left: '0', top: '40px', width: '110px', opacity: 0.3, transform: 'rotate(-20deg)' }} />
      <img src={PAW_BR} alt="" className="absolute pointer-events-none select-none" style={{ right: '0', bottom: '40px', width: '130px', opacity: 0.25, transform: 'rotate(15deg)' }} />

      {/* ── Section header ───────────────────────────────────────────────── */}
      <div
        ref={headRef}
        className="text-center mb-16 px-8"
        style={{ opacity: headVisible ? 1 : 0, transform: headVisible ? 'translateY(0)' : 'translateY(28px)', transition: 'opacity 0.7s ease, transform 0.75s cubic-bezier(0.16,1,0.3,1)' }}
      >
        <p
          className="font-semibold uppercase tracking-widest mb-3"
          style={{fontFamily: 'SF Pro Display', fontSize: '12px', color: '#80c3e8', letterSpacing: '0.2em' }}
        >
          Funcionalidades
        </p>
        <h2
          className="text-brand-dark font-bold leading-tight mb-4"
          style={{fontFamily: 'SF Pro Display', fontSize: 'clamp(28px, 2.1vw, 40px)' }}
        >
          Tudo que você precisa,{' '}
          <span style={{ color: '#80c3e8' }}>em um só lugar</span>
        </h2>
        <p
          className="mx-auto"
          style={{fontFamily: 'SF Pro Display', fontWeight: 500, fontSize: 'clamp(14px, 0.9vw, 17px)', color: 'rgba(3,43,67,0.6)', maxWidth: '600px', lineHeight: 1.7 }}
        >
          Uma plataforma completa para cuidar da saúde do seu pet com praticidade,
          segurança e total tranquilidade.
        </p>
      </div>

      {/* ── Feature cards ────────────────────────────────────────────────── */}
      <div
        ref={cardsRef}
        className="flex justify-between"
        style={{ paddingLeft: '30px', paddingRight: '30px' }}
      >
        {FEATURES.map((feat, i) => (
          <FeatureCard
            key={feat.title}
            {...feat}
            delay={i * 130}
            visible={cardsVisible}
          />
        ))}
      </div>
    </section>
  );
};

export default FeaturesSection;
