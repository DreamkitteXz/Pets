import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';
import useScrollReveal from '../../../hooks/useScrollReveal';

const PAW_L = 'https://www.figma.com/api/mcp/asset/5062962d-cbe4-4184-91f0-55740a778739';
const PAW_R = 'https://www.figma.com/api/mcp/asset/9bc40011-2b3e-42c3-911e-fa7ee856a498';

const STATS = [
  { value: '10k+',  label: 'Tutores ativos'      },
  { value: '98%',   label: 'Satisfação'           },
  { value: '50k+',  label: 'Consultas registradas'},
  { value: '24/7',  label: 'Suporte disponível'   },
];

const revealStyle = (visible, delay = 0) => ({
  opacity: visible ? 1 : 0,
  transform: visible ? 'translateY(0)' : 'translateY(28px)',
  transition: `opacity 0.7s ease ${delay}ms, transform 0.75s cubic-bezier(0.16, 1, 0.3, 1) ${delay}ms`,
});

const CTASection = () => {
  const [sectionRef, sectionVisible] = useScrollReveal(0.1);
  const [statsRef, statsVisible]     = useScrollReveal(0.12);
  const [btnHovered, setBtnHovered]  = useState(false);

  return (
    <section
      id="contato"
      className="relative overflow-hidden"
      style={{ backgroundColor: '#f0f4f3', paddingTop: '100px', paddingBottom: '100px' }}
    >
      {/* Paw decorations */}
      <img src={PAW_L} alt="" className="absolute pointer-events-none select-none" style={{ left: '0', top: '50%', transform: 'translateY(-50%) rotate(-30deg)', width: '130px', opacity: 0.3 }} />
      <img src={PAW_R} alt="" className="absolute pointer-events-none select-none" style={{ right: '0', bottom: '60px', width: '110px', opacity: 0.25, transform: 'rotate(20deg)' }} />

      {/* Light gradient overlay */}
      <div className="absolute inset-0 pointer-events-none"
        style={{ background: 'radial-gradient(ellipse 70% 60% at 50% 50%, rgba(128,195,232,0.08) 0%, transparent 70%)' }}
      />

      {/* ── Main CTA content ─────────────────────────────────────────────── */}
      <div ref={sectionRef} className="flex flex-col items-center text-center px-8">

        <p
          className="font-semibold uppercase tracking-widest mb-4"
          style={{ fontFamily: 'SF Pro Display', fontSize: '12px', color: '#80c3e8', letterSpacing: '0.2em', ...revealStyle(sectionVisible) }}
        >
          Comece agora
        </p>

        <h2
          className="font-bold leading-tight mb-5"
          style={{ fontFamily: 'SF Pro Display', fontSize: 'clamp(30px, 2.5vw, 48px)', color: '#032b43', maxWidth: '780px', ...revealStyle(sectionVisible, 80) }}
        >
          Cuide do seu pet com{' '}
          <span style={{ color: '#cb8657' }}>inteligência</span>{' '}
          e carinho
        </h2>

        <p
          className="mb-10"
          style={{ fontFamily: 'SF Pro Display', fontWeight: 500, fontSize: 'clamp(14px, 0.9vw, 17px)', color: 'rgba(3,43,67,0.62)', maxWidth: '560px', lineHeight: 1.7, ...revealStyle(sectionVisible, 160) }}
        >
          Junte-se a milhares de tutores que já escolheram a plataforma de saúde
          digital para seus pets. Comece gratuitamente hoje mesmo.
        </p>

        {/* CTA button */}
        <div style={revealStyle(sectionVisible, 240)}>
          <Link to="/auth">
            <button
              className="flex items-center gap-3 font-semibold rounded-[8px] cursor-pointer"
              style={{
                fontFamily: 'SF Pro Display',
                fontSize: '16px',
                height: '56px',
                paddingLeft: '32px',
                paddingRight: '32px',
                backgroundColor: btnHovered ? '#043d5c' : '#032b43',
                color: '#f0f4f3',
                boxShadow: btnHovered
                  ? '0 12px 40px rgba(3,43,67,0.28)'
                  : '0 4px 16px rgba(3,43,67,0.18)',
                transform: btnHovered ? 'translateY(-2px)' : 'translateY(0)',
                transition: 'background-color 0.2s ease, box-shadow 0.25s ease, transform 0.2s ease',
              }}
              onMouseEnter={() => setBtnHovered(true)}
              onMouseLeave={() => setBtnHovered(false)}
            >
              Criar conta gratuita
              <ArrowRight
                size={18}
                strokeWidth={2}
                style={{ transform: btnHovered ? 'translateX(4px)' : 'translateX(0)', transition: 'transform 0.2s ease' }}
              />
            </button>
          </Link>
        </div>

        <p
          className="mt-4"
          style={{fontFamily: 'SF Pro Display', fontSize: '13px', color: 'rgba(3,43,67,0.4)', ...revealStyle(sectionVisible, 320) }}
        >
          Sem cartão de crédito · Grátis para começar · Cancele quando quiser
        </p>
      </div>

      {/* ── Stats strip ──────────────────────────────────────────────────── */}
      <div
        ref={statsRef}
        className="flex justify-center gap-16 mt-20 flex-wrap"
        style={{ paddingLeft: '60px', paddingRight: '60px' }}
      >
        {STATS.map((stat, i) => (
          <div
            key={stat.label}
            className="flex flex-col items-center"
            style={revealStyle(statsVisible, i * 90)}
          >
            <span
              className="font-bold"
              style={{ fontFamily: 'SF Pro Display', fontSize: 'clamp(28px, 2vw, 40px)', color: '#032b43', lineHeight: 1.1 }}
            >
              {stat.value}
            </span>
            <span
              style={{ fontFamily: 'SF Pro Display', fontWeight: 500, fontSize: '14px', color: 'rgba(3,43,67,0.5)', marginTop: '6px' }}
            >
              {stat.label}
            </span>
          </div>
        ))}
      </div>
    </section>
  );
};

export default CTASection;
