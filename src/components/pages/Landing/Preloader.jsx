import React, { useEffect, useRef, useState } from 'react';

const Preloader = ({ onComplete }) => {
  const [progress, setProgress] = useState(0);
  const [opacity, setOpacity] = useState(1);
  const rafRef = useRef(null);
  const startRef = useRef(null);

  useEffect(() => {
    const DURATION = 2400;

    const animate = (timestamp) => {
      if (!startRef.current) startRef.current = timestamp;
      const elapsed = timestamp - startRef.current;
      const raw = Math.min(elapsed / DURATION, 1);

      // Cubic ease-out: fast start, smooth deceleration near 100%
      const eased = 1 - Math.pow(1 - raw, 3);
      setProgress(eased * 100);

      if (raw < 1) {
        rafRef.current = requestAnimationFrame(animate);
      } else {
        setTimeout(() => {
          setOpacity(0);
          setTimeout(onComplete, 600);
        }, 350);
      }
    };

    rafRef.current = requestAnimationFrame(animate);
    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
    };
  }, [onComplete]);

  return (
    <div
      className="fixed inset-0 z-50 flex flex-col items-center justify-center bg-white"
      style={{ opacity, transition: 'opacity 600ms ease' }}
    >
      {/* ── Logo placeholder ──────────────────────────────────────────────────
          Replace the inner content with your actual logo image.
          Example: <img src={logo} alt="Logo" className="w-20 h-20 object-contain" />
      ───────────────────────────────────────────────────────────────────────── */}
      <div className="mb-10 flex flex-col items-center gap-4">
        <div className="relative flex items-center justify-center">
          {/* Outer ring pulse */}
          <div
            className="absolute w-24 h-24 rounded-2xl bg-brand-dark/10"
            style={{ animation: 'pulse 2s cubic-bezier(0.4,0,0.6,1) infinite' }}
          />
          {/* Logo box */}
          <div className="relative w-20 h-20 rounded-2xl bg-brand-dark flex items-center justify-center shadow-lg">
            {/* ↓ Replace this placeholder with your logo */}
            <div className="w-9 h-9 border-2 border-brand-light/40 rounded-xl" />
          </div>
        </div>

        <span
          className="text-brand-dark/30 text-xs tracking-[0.3em] uppercase select-none"
          style={{ fontFamily: 'SF Pro Display' }}
        >
          carregando
        </span>
      </div>

      {/* ── Progress bar ─────────────────────────────────────────────────── */}
      <div className="flex flex-col items-center gap-2 w-64">
        <div className="w-full h-[2px] bg-brand-dark/8 rounded-full overflow-hidden">
          <div
            className="h-full bg-brand-dark rounded-full"
            style={{
              width: `${progress}%`,
              transition: 'width 60ms linear',
            }}
          />
        </div>
        <span
          className="text-brand-dark/25 text-[11px] tabular-nums select-none"
          style={{ fontFamily: 'SF Pro Display' }}
        >
          {Math.round(progress)}%
        </span>
      </div>
    </div>
  );
};

export default Preloader;
