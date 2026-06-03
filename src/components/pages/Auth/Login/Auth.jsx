import React, { useState, useEffect, useRef } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { Eye, EyeOff, ChevronDown } from 'lucide-react';
import {
  signInWithEmail,
  signUpWithEmail,
  signInWithGoogle,
} from '../../../../services/firebase/authService';

/* ── Decorative / texture assets (served from /public) ───────────────────── */
const NOISE_TEXTURE = '/assets/auth/noise-texture.png';
const DASHED_TOP     = '/assets/auth/dashed-curve-top.svg';
const DASHED_BOTTOM  = '/assets/auth/dashed-curve-bottom.svg';

/* ── Palette tokens (AA-compliant secondary text) ────────────────────────── */
const TEXT_MUTED = '#5b6470'; // secondary text — passes WCAG AA on white
/* NOTE: input border (#cfd4da / hover #aab2bb) and placeholder (#9aa0a9) are written as
   literal arbitrary classes below — Tailwind's JIT only sees statically-written class strings. */

/* ── Google "G" logo (official 4-color mark) ─────────────────────────────── */
const GoogleLogo = ({ size = 20 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
  </svg>
);

/* ── Back chevron (recolours via currentColor) ───────────────────────────── */
const BackChevron = ({ className = '' }) => (
  <svg viewBox="0 0 25.125 45.25" fill="none" className={className} xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
    <path d="M22.625 42.75L2.5 22.625L22.625 2.5" stroke="currentColor" strokeWidth="5" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const Spinner = () => (
  <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
  </svg>
);

/* ── Password strength (sign-up only) ────────────────────────────────────── */
function getPasswordStrength(password) {
  if (password.length < 6) return { level: 0, label: '', color: '' };
  const score = [
    password.length >= 8,
    /[A-Z]/.test(password),
    /\d/.test(password),
    /[!@#$%^&*]/.test(password),
  ].filter(Boolean).length;
  if (score <= 1) return { level: 1, label: 'Fraca',   color: 'bg-red-500' };
  if (score === 2) return { level: 2, label: 'Regular', color: 'bg-yellow-500' };
  if (score === 3) return { level: 3, label: 'Boa',     color: 'bg-[#3bade6]' };
  return              { level: 4, label: 'Forte',   color: 'bg-green-500' };
}

/* ────────────────────────────────────────────────────────────────────────── */
const VetAuthPage = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const pageRef  = useRef(null);

  const [isLogin,             setIsLogin]             = useState(true);
  const [showPassword,        setShowPassword]        = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [email,               setEmail]               = useState('');
  const [password,            setPassword]            = useState('');
  const [confirmPassword,     setConfirmPassword]     = useState('');
  const [name,                setName]                = useState('');
  const [error,               setError]               = useState('');
  const [loading,             setLoading]             = useState(false);
  const [googleAccount,       setGoogleAccount]       = useState(null);

  const passwordStrength = !isLogin && password ? getPasswordStrength(password) : null;
  const redirectTo       = location.state?.from?.pathname || '/';

  /* Pick up a previously used Google account for the personalised button. */
  useEffect(() => {
    try {
      const s = sessionStorage.getItem('lastGoogleUser');
      if (s) setGoogleAccount(JSON.parse(s));
    } catch { /* ignore */ }
  }, []);

  const navigateWithExit = (path) => {
    pageRef.current?.classList.add('auth-page-out');
    setTimeout(() => navigate(path), 340);
  };

  const handleGoogleSignIn = async () => {
    setError('');
    setLoading(true);
    const { user, error: err } = await signInWithGoogle();
    setLoading(false);
    if (err) { setError(err); return; }
    if (user) {
      try {
        sessionStorage.setItem('lastGoogleUser', JSON.stringify({
          name:     user.displayName || '',
          photoURL: user.photoURL    || '',
        }));
      } catch { /* ignore */ }
      navigate(redirectTo);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    if (!isLogin && password !== confirmPassword) { setError('As senhas não coincidem.'); return; }
    setLoading(true);
    if (isLogin) {
      const { user, error: err } = await signInWithEmail(email, password);
      if (err) { setError(err); setLoading(false); return; }
      if (!user.emailVerified) { navigateWithExit('/verify-email'); return; }
      navigate(redirectTo);
    } else {
      const { error: err } = await signUpWithEmail(email, password, name);
      if (err) { setError(err); setLoading(false); return; }
      navigateWithExit('/verify-email');
    }
    setLoading(false);
  };

  const switchMode = () => {
    setIsLogin(!isLogin);
    setError('');
    setPassword('');
    setConfirmPassword('');
    setShowPassword(false);
    setShowConfirmPassword(false);
  };

  /* Shared field styles — compact, soft, premium. */
  const inputCls =
    'w-full h-[50px] lg:h-[52px] px-4 rounded-[12px] bg-white ' +
    'border border-[#cfd4da] text-[#111827] text-[15px] lg:text-[16px] ' +
    'placeholder:text-[#9aa0a9] hover:border-[#aab2bb] ' +
    'focus:outline-none focus:border-[#023047] focus:ring-4 focus:ring-[#023047]/10 ' +
    'transition-all duration-200';

  const labelCls = 'block font-semibold text-[#111827] text-[14px] lg:text-[15px] mb-1.5';

  const eyeBtnCls =
    'absolute right-3.5 top-1/2 -translate-y-1/2 text-[#9aa0a9] ' +
    'hover:text-[#023047] transition-colors duration-200';

  return (
    <div
      ref={pageRef}
      className="auth-page-in font-sf relative min-h-screen w-full bg-white overflow-x-hidden"
    >
      <div className="relative mx-auto flex min-h-screen w-full max-w-[1920px]">

        {/* ══ LEFT — dark aurora glass card ════════════════════════════════════ */}
        <aside
          className="auth-card-in hidden lg:flex lg:sticky lg:top-0 lg:h-screen lg:items-center lg:justify-center
                     flex-shrink-0 w-[44%] xl:w-[40%] 2xl:w-[38%] p-6 xl:p-8"
        >
          <div
            className="card-float relative w-full h-[calc(100vh-3rem)] xl:h-[calc(100vh-4rem)] max-h-[900px]
                       overflow-hidden rounded-[32px]"
            style={{
              border: '1px solid rgba(255,255,255,0.10)',
              boxShadow: '0 32px 64px -20px rgba(0,0,0,0.55), inset 0 1px 0 rgba(255,255,255,0.08)',
            }}
          >
            {/* Dark base */}
            <div className="absolute inset-0 bg-[#010d15]" />

            {/* Aurora mesh — additive radial glows */}
            <div className="absolute inset-0" style={{ mixBlendMode: 'plus-lighter', opacity: 0.85, background: 'radial-gradient(ellipse 78% 52% at 31% 45%, #ffb703 0%, rgba(255,183,3,0) 62%)' }} />
            <div className="absolute inset-0" style={{ mixBlendMode: 'plus-lighter', opacity: 0.4,  background: 'radial-gradient(ellipse 52% 40% at 10% 40%, #ffb703 0%, rgba(255,183,3,0) 60%)' }} />
            <div className="absolute inset-0" style={{ mixBlendMode: 'plus-lighter', opacity: 0.92, background: 'radial-gradient(ellipse 115% 62% at 60% -10%, #023047 0%, rgba(2,48,71,0) 62%)' }} />
            <div className="absolute inset-0" style={{ mixBlendMode: 'plus-lighter', opacity: 0.5,  background: 'radial-gradient(ellipse 72% 55% at 104% 32%, #3bade6 0%, rgba(59,173,230,0) 55%)' }} />
            <div className="absolute inset-0" style={{ mixBlendMode: 'plus-lighter', opacity: 0.6,  background: 'radial-gradient(ellipse 85% 48% at 52% 114%, #023047 0%, rgba(2,48,71,0) 58%)' }} />

            {/* Glass sheen — soft white overlay across the face */}
            <div className="absolute inset-0 bg-gradient-to-br from-white/[0.06] via-transparent to-transparent pointer-events-none" />

            {/* Top-edge highlight — the "lit glass rim" effect */}
            <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/50 to-transparent pointer-events-none" />

            {/* Right-edge subtle highlight for depth */}
            <div className="absolute inset-y-0 right-0 w-px bg-gradient-to-b from-transparent via-white/[0.07] to-transparent pointer-events-none" />

            {/* Grain / noise overlay */}
            <div
              className="absolute inset-0 pointer-events-none"
              style={{ backgroundImage: `url('${NOISE_TEXTURE}')`, backgroundSize: '400px 400px', opacity: 0.07 }}
            />

            {/* Back chevron (white, top-left of card) */}
            <button
              type="button"
              onClick={() => navigate(-1)}
              aria-label="Voltar"
              className="absolute z-10 left-8 top-8 text-white hover:opacity-70 hover:-translate-x-0.5
                         active:opacity-50 transition-all duration-200"
            >
              <BackChevron className="w-[17px] h-[31px]" />
            </button>

            {/* Bottom headline */}
            <div className="absolute inset-x-0 bottom-0 z-10 px-9 pb-10">
              <p className="text-[#c8c8c8] mb-2" style={{fontFamily: 'SF Pro Display', fontSize: 16, lineHeight: '22px', letterSpacing: '-0.073px' }}>
                Aqui você tem
              </p>
              <p
                className="text-white font-bold"
                style={{ fontFamily: 'SF Pro Display', fontSize: 30, lineHeight: '38px', letterSpacing: '0.1px', maxWidth: 460 }}
              >
                A próxima geração da documentação pet começa aqui.
              </p>
            </div>
          </div>
        </aside>

        {/* ══ RIGHT — form panel ════════════════════════════════════════════ */}
        <main className="auth-form-in relative flex-1 flex flex-col items-center justify-center
                         px-6 py-12 sm:px-10 lg:px-14 xl:px-16">

          {/* Decorative dashed curves (desktop only): top-right corner + card↔form junction */}
          <img
            src={DASHED_TOP}
            alt=""
            aria-hidden="true"
            className="hidden lg:block absolute z-0 pointer-events-none select-none opacity-90"
            style={{ top: -10, right: -24, width: 280, height: 233 }}
          />
          <img
            src={DASHED_BOTTOM}
            alt=""
            aria-hidden="true"
            className="hidden lg:block absolute z-0 pointer-events-none select-none opacity-90"
            style={{ bottom: 24, left: -20, width: 270, height: 234 }}
          />

          {/* Back chevron (dark) for mobile, where the card is hidden */}
          <button
            type="button"
            onClick={() => navigate(-1)}
            aria-label="Voltar"
            className="lg:hidden absolute left-5 top-5 z-10 text-[#023047] hover:opacity-60
                       active:opacity-40 transition-opacity duration-200"
          >
            <BackChevron className="w-[14px] h-[26px]" />
          </button>

          <div className="relative z-10 w-full max-w-[460px] mx-auto">

            {/* Title */}
            <h1 className="text-center font-bold text-[#0f172a] text-[26px] sm:text-[28px] lg:text-[30px]"
                style={{ lineHeight: 1.18, letterSpacing: '-0.01em' }}>
              {isLogin ? 'Entre na sua conta' : 'Crie sua conta'}
            </h1>

            {/* Subtitle */}
            <p
              className="text-center mx-auto mt-2.5 mb-7 lg:mb-8 max-w-[380px] text-[15px] lg:text-[16px]"
              style={{ color: TEXT_MUTED, lineHeight: 1.5 }}
            >
              {isLogin
                ? 'Acesse seu painel e gerencie a saúde dos seus pets, insira suas credenciais.'
                : 'Crie sua conta e tenha acesso a uma experiência moderna para o cuidado do seu pet.'}
            </p>

            {/* Error */}
            {error && (
              <div
                role="alert"
                className="flex items-start gap-2.5 mb-5 p-3.5 rounded-[12px] border border-red-200 bg-red-50 text-red-700 text-sm"
              >
                <span className="shrink-0 mt-0.5" aria-hidden="true">⚠</span>
                <span>{error}</span>
              </div>
            )}

            <form onSubmit={handleSubmit} noValidate>
              {/* Full name (sign-up) */}
              {!isLogin && (
                <div className="mb-4">
                  <label htmlFor="auth-name" className={labelCls}>Nome completo</label>
                  <input
                    id="auth-name"
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    required
                    autoComplete="name"
                    placeholder="Seu nome completo"
                    className={inputCls}
                  />
                </div>
              )}

              {/* Email */}
              <div className="mb-4">
                <label htmlFor="auth-email" className={labelCls}>Seu email</label>
                <input
                  id="auth-email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  autoComplete="email"
                  placeholder="seu_nome@email.com"
                  className={inputCls}
                />
              </div>

              {/* Password */}
              <div className={isLogin ? 'mb-2' : 'mb-4'}>
                <label htmlFor="auth-password" className={labelCls}>Senha</label>
                <div className="relative">
                  <input
                    id="auth-password"
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    autoComplete={isLogin ? 'current-password' : 'new-password'}
                    placeholder="••••••••"
                    className={`${inputCls} pr-12`}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((v) => !v)}
                    aria-label={showPassword ? 'Ocultar senha' : 'Mostrar senha'}
                    className={eyeBtnCls}
                  >
                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                  </button>
                </div>

                {/* Strength meter (sign-up) */}
                {passwordStrength?.level > 0 && (
                  <div className="mt-2.5">
                    <div className="flex gap-1.5 mb-1">
                      {[1, 2, 3, 4].map((i) => (
                        <span
                          key={i}
                          className={`h-1 flex-1 rounded-full transition-all duration-300 ${
                            passwordStrength.level >= i ? passwordStrength.color : 'bg-gray-200'
                          }`}
                        />
                      ))}
                    </div>
                    <p className="text-xs" style={{ color: TEXT_MUTED }}>
                      Força: <span className="font-medium">{passwordStrength.label}</span>
                    </p>
                  </div>
                )}
              </div>

              {/* Confirm password (sign-up) */}
              {!isLogin && (
                <div className="mb-0">
                  <label htmlFor="auth-confirm" className={labelCls}>Confirmar senha</label>
                  <div className="relative">
                    <input
                      id="auth-confirm"
                      type={showConfirmPassword ? 'text' : 'password'}
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      required
                      autoComplete="new-password"
                      placeholder="••••••••"
                      className={`${inputCls} pr-12`}
                    />
                    <button
                      type="button"
                      onClick={() => setShowConfirmPassword((v) => !v)}
                      aria-label={showConfirmPassword ? 'Ocultar senha' : 'Mostrar senha'}
                      className={eyeBtnCls}
                    >
                      {showConfirmPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                    </button>
                  </div>
                </div>
              )}

              {/* Forgot password (login) */}
              {isLogin && (
                <div className="flex justify-end mb-0">
                  <Link
                    to="/forgot-password"
                    className="text-[13px] font-medium text-[#023047] no-underline hover:no-underline
                               hover:text-[#3bade6] transition-colors duration-200"
                  >
                    Esqueceu a senha?
                  </Link>
                </div>
              )}

              {/* ── Action column — consistent gap before CTA in both modes ── */}
              <div className="mt-6 lg:mt-7 w-full">

                {/* Primary CTA — single soft shadow (no inset) */}
                <button
                  type="submit"
                  disabled={loading}
                  className="group w-full flex items-center justify-center gap-2.5 rounded-[12px]
                             h-[50px] lg:h-[52px] text-white font-semibold text-[15px] lg:text-[16px]
                             bg-[#023047] hover:bg-[#033c5c] active:scale-[0.99] hover:-translate-y-px
                             transition-all duration-300
                             shadow-[0_8px_20px_-6px_rgba(2,48,71,0.45)]
                             hover:shadow-[0_12px_26px_-6px_rgba(2,48,71,0.5)]
                             disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0"
                >
                  {loading
                    ? <><Spinner /> Processando…</>
                    : (isLogin ? 'Entrar' : 'Começar')}
                </button>

                {/* Divider */}
                <div className="flex items-center gap-3.5 my-5">
                  <span className="flex-1 h-px bg-[#e3e6ea]" />
                  <span className="shrink-0 text-[13px] lg:text-[14px]" style={{ color: TEXT_MUTED }}>
                    Ou continue com
                  </span>
                  <span className="flex-1 h-px bg-[#e3e6ea]" />
                </div>

                {/* Google — one button per session state, proportional pill */}
                {googleAccount ? (
                  /* Active session → expanded account button */
                  <button
                    type="button"
                    onClick={handleGoogleSignIn}
                    disabled={loading}
                    className="group w-full flex items-center gap-3 rounded-full bg-white
                               border border-[#dadce0] h-[56px] lg:h-[60px] px-4
                               hover:bg-gray-50 hover:border-[#c6c9ce] hover:shadow-md
                               active:scale-[0.99] transition-all duration-200
                               shadow-[0_1px_2px_rgba(0,0,0,0.12)]
                               disabled:opacity-60 disabled:cursor-not-allowed"
                  >
                    {googleAccount.photoURL ? (
                      <img
                        src={googleAccount.photoURL}
                        alt=""
                        className="shrink-0 rounded-full object-cover"
                        style={{ width: 30, height: 30 }}
                        referrerPolicy="no-referrer"
                      />
                    ) : (
                      <span
                        className="shrink-0 flex items-center justify-center rounded-full bg-[#023047] text-white font-bold"
                        style={{ width: 30, height: 30, fontSize: 13 }}
                      >
                        {(googleAccount.name || 'U')[0].toUpperCase()}
                      </span>
                    )}

                    <span className="flex flex-col items-start min-w-0 leading-tight"
                          style={{ fontFamily: 'SF Pro Display' }}>
                      <span className="text-[#3c4043] font-medium text-[14px]" style={{ letterSpacing: '0.25px' }}>
                        Entrar como {googleAccount.name?.split(' ')[0] || 'você'}
                      </span>
                      <span className="text-[#5f6368] text-[12px]" style={{ letterSpacing: '0.25px' }}>
                        Conta Google conectada
                      </span>
                    </span>

                    <span className="ml-auto flex items-center gap-2 shrink-0">
                      <ChevronDown size={16} className="text-[#5f6368]" />
                      <GoogleLogo size={20} />
                    </span>
                  </button>
                ) : (
                  /* No session → standard Google button */
                  <button
                    type="button"
                    onClick={handleGoogleSignIn}
                    disabled={loading}
                    className="group relative w-full flex items-center justify-center rounded-full bg-white
                               border border-[#dadce0] h-[50px] lg:h-[52px]
                               hover:bg-gray-50 hover:border-[#c6c9ce] hover:shadow-md
                               active:scale-[0.99] transition-all duration-200
                               shadow-[0_1px_2px_rgba(0,0,0,0.12)]
                               disabled:opacity-60 disabled:cursor-not-allowed"
                  >
                    <span className="absolute left-5 flex items-center">
                      <GoogleLogo size={20} />
                    </span>
                    <span className="text-[#3c4043] font-medium text-[14px] lg:text-[15px]"
                          style={{ fontFamily: 'SF Pro Display', letterSpacing: '0.25px' }}>
                      Entrar com Google
                    </span>
                  </button>
                )}
              </div>
            </form>

            {/* Login / sign-up toggle */}
            <p className="text-center text-sm mt-7" style={{ color: TEXT_MUTED }}>
              {isLogin ? 'Não tem uma conta? ' : 'Já tem uma conta? '}
              <button
                type="button"
                onClick={switchMode}
                className="font-semibold text-[#023047] hover:text-[#3bade6] transition-colors duration-200"
              >
                {isLogin ? 'Cadastre-se' : 'Faça login'}
              </button>
            </p>
          </div>
        </main>
      </div>
    </div>
  );
};

export default VetAuthPage;
