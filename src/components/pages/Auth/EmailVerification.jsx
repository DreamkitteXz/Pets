import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { CheckCircle, Mail, RefreshCw } from 'lucide-react';
import { auth } from '../../../config/firebase';
import { verifyOtp, sendOtp, classifyOtpError } from '../../../services/firebase/otpService';
import LogoBlack from '../../../assets/logos/logo_black';

const DASHED_TOP    = '/assets/auth/dashed-curve-top.svg';
const DASHED_BOTTOM = '/assets/auth/dashed-curve-bottom.svg';
const RESEND_COOLDOWN = 60;

/* ── Spinner ─────────────────────────────────────────────────────────────── */
const Spinner = ({ size = 16 }) => (
  <svg
    width={size} height={size}
    className="animate-spin"
    viewBox="0 0 24 24" fill="none" aria-hidden="true"
  >
    <circle className="opacity-20" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
    <path className="opacity-80" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
  </svg>
);

/* ── Single OTP digit ────────────────────────────────────────────────────── */
const OtpDigit = React.memo(({ value, index, inputRef, disabled, hasError, onChange, onKeyDown, onPaste, onFocus }) => (
  <input
    ref={(el) => { inputRef.current[index] = el; }}
    type="text"
    inputMode="numeric"
    maxLength={1}
    value={value}
    disabled={disabled}
    onChange={(e) => onChange(index, e.target.value)}
    onKeyDown={(e) => onKeyDown(index, e)}
    onPaste={onPaste}
    onFocus={(e) => { e.target.select(); onFocus?.(index); }}
    aria-label={`Dígito ${index + 1} do código de verificação`}
    className={[
      'w-[44px] sm:w-[48px] lg:w-[52px]',
      'h-[52px] sm:h-[54px] lg:h-[56px]',
      'text-center text-[20px] lg:text-[22px] font-bold',
      'rounded-[12px] border-2 bg-white',
      'focus:outline-none focus:ring-0',
      'transition-all duration-150',
      'select-none caret-transparent',
      'disabled:opacity-40 disabled:cursor-not-allowed',
      hasError
        ? 'border-red-400 text-red-600 bg-red-50'
        : value
          ? 'border-[#023047] text-[#023047] bg-[#023047]/[0.04] shadow-[0_0_0_3px_rgba(2,48,71,0.08)]'
          : 'border-[#cfd4da] text-[#111827] hover:border-[#aab2bb]',
    ].join(' ')}
  />
));

/* ────────────────────────────────────────────────────────────────────────── */
const EmailVerification = () => {
  const navigate    = useNavigate();
  const inputRefs   = useRef([]);
  const pollingRef  = useRef(null);
  const cooldownRef = useRef(null);
  const redirectRef = useRef(null);

  // OTP state
  const [otp,       setOtp]       = useState(['', '', '', '', '', '']);
  const [stage,     setStage]     = useState('idle'); // idle | verifying | success | error
  const [errorMsg,  setErrorMsg]  = useState('');
  const [errorType, setErrorType] = useState('invalid'); // invalid | expired | rate_limited | not_found
  const [shaking,   setShaking]   = useState(false);

  // Resend state
  const [resendState, setResendState] = useState('idle'); // idle | sending | sent | error
  const [resendError, setResendError] = useState('');
  const [cooldown,    setCooldown]    = useState(0);

  const userEmail = auth.currentUser?.email;
  const isDisabled = stage === 'verifying' || stage === 'success';

  /* Cleanup on unmount */
  useEffect(() => {
    return () => {
      clearInterval(pollingRef.current);
      clearInterval(cooldownRef.current);
      clearTimeout(redirectRef.current);
    };
  }, []);

  /* Lightweight poll — detects email-link fallback verification */
  useEffect(() => {
    pollingRef.current = setInterval(async () => {
      const user = auth.currentUser;
      if (!user) { navigate('/auth'); return; }
      await user.reload().catch(() => {});
      if (auth.currentUser?.emailVerified) {
        clearInterval(pollingRef.current);
        handleSuccess();
      }
    }, 5000);

    const unsub = auth.onAuthStateChanged((u) => {
      if (!u) navigate('/auth');
    });

    return () => { clearInterval(pollingRef.current); unsub(); };
  }, [navigate]); // eslint-disable-line react-hooks/exhaustive-deps

  /* Auto-submit when all 6 digits filled */
  useEffect(() => {
    if (otp.every(d => d !== '') && stage === 'idle') {
      handleVerify(otp.join(''));
    }
  }, [otp]); // eslint-disable-line react-hooks/exhaustive-deps

  /* ── Handlers ──────────────────────────────────────────────────────────── */

  const handleSuccess = useCallback(() => {
    clearInterval(pollingRef.current);
    setStage('success');
    redirectRef.current = setTimeout(() => navigate('/app'), 1800);
  }, [navigate]);

  const handleVerify = useCallback(async (code) => {
    const codeToVerify = code || otp.join('');
    if (codeToVerify.length !== 6) return;

    setStage('verifying');
    setErrorMsg('');

    const { success, error, raw } = await verifyOtp(codeToVerify);

    if (success) {
      handleSuccess();
      return;
    }

    const type = classifyOtpError(raw);
    setErrorType(type);
    setErrorMsg(error);
    setStage('error');

    // Shake and clear on wrong code (not for expired/rate_limited — user needs to resend)
    if (type === 'invalid' || type === 'already_used') {
      setShaking(true);
      setTimeout(() => {
        setShaking(false);
        setOtp(['', '', '', '', '', '']);
        setStage('idle');
        inputRefs.current[0]?.focus();
      }, 600);
    }
    // For expired/rate_limited: keep error visible, user must resend
    if (type === 'expired' || type === 'rate_limited' || type === 'not_found') {
      setStage('idle');
    }
  }, [otp, handleSuccess]);

  const handleChange = useCallback((index, val) => {
    const digit = val.replace(/\D/g, '').slice(-1);
    setOtp(prev => {
      const next = [...prev];
      next[index] = digit;
      return next;
    });
    if (digit && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  }, []);

  const handleKeyDown = useCallback((index, e) => {
    if (e.key === 'Backspace') {
      if (otp[index]) {
        setOtp(prev => { const n = [...prev]; n[index] = ''; return n; });
      } else if (index > 0) {
        inputRefs.current[index - 1]?.focus();
        setOtp(prev => { const n = [...prev]; n[index - 1] = ''; return n; });
      }
    } else if (e.key === 'ArrowLeft'  && index > 0) inputRefs.current[index - 1]?.focus();
      else if (e.key === 'ArrowRight' && index < 5) inputRefs.current[index + 1]?.focus();
      else if (e.key === 'Enter') handleVerify(otp.join(''));
  }, [otp, handleVerify]);

  const handlePaste = useCallback((e) => {
    e.preventDefault();
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
    if (!pasted) return;
    const next = ['', '', '', '', '', ''];
    pasted.split('').forEach((ch, i) => { next[i] = ch; });
    setOtp(next);
    const focusIdx = Math.min(pasted.length, 5);
    inputRefs.current[focusIdx]?.focus();
  }, []);

  const startCooldown = useCallback(() => {
    setCooldown(RESEND_COOLDOWN);
    cooldownRef.current = setInterval(() => {
      setCooldown(p => {
        if (p <= 1) { clearInterval(cooldownRef.current); return 0; }
        return p - 1;
      });
    }, 1000);
  }, []);

  const handleResend = useCallback(async () => {
    if (cooldown > 0 || resendState === 'sending') return;
    setResendState('sending');
    setResendError('');
    setErrorMsg('');
    setErrorType('invalid');

    const { error } = await sendOtp();
    if (error) {
      setResendState('error');
      setResendError(error);
    } else {
      setResendState('sent');
      setOtp(['', '', '', '', '', '']);
      setStage('idle');
      startCooldown();
      inputRefs.current[0]?.focus();
      setTimeout(() => setResendState('idle'), 4000);
    }
  }, [cooldown, resendState, startCooldown]);

  const handleSignOut = useCallback(async () => {
    clearInterval(pollingRef.current);
    clearInterval(cooldownRef.current);
    clearTimeout(redirectRef.current);
    await auth.signOut();
    navigate('/auth');
  }, [navigate]);

  /* ── Render ────────────────────────────────────────────────────────────── */

  const otpHasError = stage === 'error' && (errorType === 'invalid' || errorType === 'already_used');

  return (
    <div className="verify-page-in font-sf relative min-h-screen w-full bg-white overflow-x-hidden">
      <div className="relative mx-auto flex min-h-screen flex-col max-w-[1920px]">

        {/* Decorative dashed curves */}
        <img src={DASHED_TOP} alt="" aria-hidden="true"
          className="hidden lg:block absolute z-0 pointer-events-none select-none opacity-90"
          style={{ top: -10, right: -24, width: 280, height: 233 }} />
        <img src={DASHED_BOTTOM} alt="" aria-hidden="true"
          className="hidden lg:block absolute z-0 pointer-events-none select-none opacity-90"
          style={{ bottom: 24, left: '5%', width: 270, height: 234 }} />

        <main className="flex-1 flex items-center justify-center px-5 py-14 sm:px-8 sm:py-16">
          <div
            className="verify-card-in relative z-10 w-full max-w-[480px] mx-auto
                       bg-white rounded-[24px] px-7 py-9 sm:px-9 sm:py-10 lg:px-10 lg:py-12"
            style={{
              border: '1px solid rgba(0,0,0,0.07)',
              boxShadow: '0 20px 60px -12px rgba(0,0,0,0.12), 0 4px 16px -4px rgba(0,0,0,0.06)',
            }}
          >
            <div className="verify-form-in flex flex-col items-center text-center">

              {/* ── Success state ───────────────────────────────────────── */}
              {stage === 'success' ? (
                <SuccessView />
              ) : (
                <>
                  {/* Logo */}
                  <div className="mb-6 overflow-hidden" style={{ width: 72, height: 43 }}>
                    <LogoBlack />
                  </div>

                  {/* Icon */}
                  <div
                    className="w-[52px] h-[52px] rounded-full flex items-center justify-center mb-5"
                    style={{ background: 'rgba(2,48,71,0.08)' }}
                  >
                    <Mail size={24} color="#023047" strokeWidth={1.75} />
                  </div>

                  {/* Title */}
                  <h1
                    className="font-bold text-[#0f172a] text-[22px] sm:text-[24px] lg:text-[26px] mb-2"
                    style={{ lineHeight: 1.2, letterSpacing: '-0.01em' }}
                  >
                    Verifique seu e-mail
                  </h1>

                  {/* Subtitle */}
                  <p className="text-[14px] sm:text-[15px] mb-6 max-w-[360px]"
                     style={{ color: '#5b6470', lineHeight: 1.55 }}>
                    Enviamos um código de 6 dígitos para{' '}
                    {userEmail && <span className="font-semibold text-[#023047] break-all">{userEmail}</span>}.
                    Insira o código abaixo para verificar sua conta.
                  </p>

                  {/* Resend feedback */}
                  {resendState === 'sent' && (
                    <div className="w-full flex items-center gap-2 mb-4 px-3 py-2.5 rounded-[10px]
                                    bg-green-50 border border-green-200 text-green-700 text-[13px]">
                      <CheckCircle size={14} className="shrink-0" />
                      <span>Novo código enviado! Verifique sua caixa de entrada.</span>
                    </div>
                  )}
                  {resendState === 'error' && resendError && (
                    <div role="alert"
                         className="w-full flex items-start gap-2 mb-4 px-3 py-2.5 rounded-[10px]
                                    bg-red-50 border border-red-200 text-red-700 text-[13px] text-left">
                      <span className="shrink-0 mt-0.5" aria-hidden="true">⚠</span>
                      <span>{resendError}</span>
                    </div>
                  )}

                  {/* Error message */}
                  {errorMsg && stage !== 'verifying' && (
                    <div role="alert"
                         className={`w-full flex items-start gap-2 mb-5 px-3 py-2.5 rounded-[10px]
                                     border text-[13px] text-left transition-all duration-300 ${
                           errorType === 'expired' || errorType === 'rate_limited'
                             ? 'bg-amber-50 border-amber-200 text-amber-800'
                             : 'bg-red-50 border-red-200 text-red-700'
                         }`}>
                      <span className="shrink-0 mt-0.5" aria-hidden="true">
                        {errorType === 'expired' || errorType === 'rate_limited' ? '⏱' : '⚠'}
                      </span>
                      <span>{errorMsg}</span>
                    </div>
                  )}

                  {/* OTP row */}
                  <div
                    role="group"
                    aria-label="Código de verificação"
                    className={`flex gap-1.5 sm:gap-2 lg:gap-2.5 justify-center mb-7 w-full
                                ${shaking ? 'otp-shake' : ''}`}
                  >
                    {otp.map((digit, i) => (
                      <OtpDigit
                        key={i}
                        index={i}
                        value={digit}
                        inputRef={inputRefs}
                        disabled={isDisabled}
                        hasError={otpHasError}
                        onChange={handleChange}
                        onKeyDown={handleKeyDown}
                        onPaste={handlePaste}
                      />
                    ))}
                  </div>

                  {/* Verify button (shows when OTP not yet auto-submitted) */}
                  {!otp.every(d => d !== '') && (
                    <button
                      type="button"
                      onClick={() => handleVerify(otp.join(''))}
                      disabled={otp.filter(Boolean).length < 6 || isDisabled}
                      className="w-full flex items-center justify-center gap-2 rounded-[12px]
                                 h-[50px] lg:h-[52px] text-white font-semibold text-[15px] lg:text-[16px]
                                 bg-[#023047] hover:bg-[#033c5c] hover:-translate-y-px active:scale-[0.99]
                                 transition-all duration-300
                                 shadow-[0_8px_20px_-6px_rgba(2,48,71,0.45)]
                                 hover:shadow-[0_12px_26px_-6px_rgba(2,48,71,0.5)]
                                 disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:translate-y-0
                                 mb-5"
                    >
                      {stage === 'verifying' ? (
                        <><Spinner size={18} />Verificando…</>
                      ) : 'Verificar código'}
                    </button>
                  )}

                  {/* Verifying overlay (when auto-submitting) */}
                  {stage === 'verifying' && otp.every(d => d !== '') && (
                    <div className="flex items-center gap-2 mb-5 text-[14px] text-[#5b6470]">
                      <Spinner size={16} />
                      <span>Verificando código…</span>
                    </div>
                  )}

                  {/* Divider */}
                  <div className="flex items-center gap-3 w-full mb-5">
                    <span className="flex-1 h-px bg-[#e3e6ea]" />
                    <span className="text-[12px]" style={{ color: '#b4b4b4' }}>não recebeu?</span>
                    <span className="flex-1 h-px bg-[#e3e6ea]" />
                  </div>

                  {/* Resend */}
                  <button
                    type="button"
                    onClick={handleResend}
                    disabled={cooldown > 0 || resendState === 'sending'}
                    className="inline-flex items-center gap-1.5 text-[13px] sm:text-[14px] font-medium
                               text-[#023047] hover:text-[#3bade6] transition-colors duration-200
                               disabled:text-[#9aa0a9] disabled:cursor-not-allowed mb-3"
                  >
                    {resendState === 'sending'
                      ? <><Spinner size={13} />Enviando…</>
                      : cooldown > 0
                        ? <><RefreshCw size={13} />Reenviar em {cooldown}s</>
                        : <><RefreshCw size={13} />Reenviar código</>}
                  </button>

                  {/* Sign out */}
                  <button
                    type="button"
                    onClick={handleSignOut}
                    className="text-[12px] text-[#b4b4b4] hover:text-[#5b6470] transition-colors duration-200"
                  >
                    Sair da conta
                  </button>
                </>
              )}

            </div>
          </div>
        </main>
      </div>
    </div>
  );
};

/* ── Success view ─────────────────────────────────────────────────────────── */
const SuccessView = () => (
  <div className="flex flex-col items-center text-center py-4">
    <div className="success-icon-in w-16 h-16 rounded-full bg-green-50 border-2 border-green-200
                    flex items-center justify-center mb-5">
      <CheckCircle size={30} className="text-green-600" strokeWidth={2} />
    </div>
    <h2 className="font-bold text-[#0f172a] text-[22px] lg:text-[24px] mb-2"
        style={{ lineHeight: 1.2, letterSpacing: '-0.01em' }}>
      E-mail verificado!
    </h2>
    <p className="text-[14px] lg:text-[15px]" style={{ color: '#5b6470', lineHeight: 1.55 }}>
      Sua conta foi confirmada com sucesso.<br />Redirecionando…
    </p>
    <div className="mt-6 flex items-center gap-2 text-[13px] text-[#9aa0a9]">
      <Spinner size={14} />
      <span>Carregando dashboard…</span>
    </div>
  </div>
);

export default EmailVerification;
