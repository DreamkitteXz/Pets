import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, Mail } from 'lucide-react';
import LogoBlack from '../../../assets/logo_black';
import AuthBackground from './assets/auth_background.svg';
import { sendPasswordReset } from '../../../services/firebase/authService';

const Spinner = () => (
  <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24" fill="none">
    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
  </svg>
);

const ForgotPassword = () => {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    const { error: err } = await sendPasswordReset(email);
    setLoading(false);
    if (err) { setError(err); return; }
    setSent(true);
  };

  return (
    <div className="flex min-h-screen bg-brand-light">
      {/* Form Panel */}
      <div className="w-full md:w-1/2 flex flex-col p-8 md:p-16 justify-center">
        <div className="mb-10">
          <LogoBlack className="w-10 h-10" />
        </div>

        <Link
          to="/auth"
          className="flex items-center gap-1.5 text-sm text-gray-500 hover:text-brand-dark transition mb-8 w-fit"
        >
          <ArrowLeft size={14} /> Voltar ao login
        </Link>

        {!sent ? (
          <>
            <div className="mb-8">
              <h1 className="text-2xl md:text-3xl font-bold text-brand-dark font-montserrat">
                Recuperar senha
              </h1>
              <p className="text-gray-500 mt-2 text-sm">
                Insira seu e-mail e enviaremos um link para redefinir sua senha.
              </p>
            </div>

            {error && (
              <div className="mb-5 flex items-start gap-2 p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm">
                <span className="mt-0.5 shrink-0">⚠</span>
                <span>{error}</span>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">E-mail</label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  placeholder="seu@email.com"
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-lg bg-white
                    focus:outline-none focus:ring-2 focus:ring-brand-blue/50 focus:border-brand-blue
                    transition placeholder:text-gray-400 text-sm"
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-brand-dark text-white py-2.5 rounded-lg
                  hover:bg-brand-dark/90 focus:outline-none focus:ring-2 focus:ring-brand-dark/30
                  transition flex items-center justify-center gap-2 font-medium text-sm
                  disabled:opacity-60 disabled:cursor-not-allowed"
              >
                {loading ? (
                  <><Spinner /> Enviando...</>
                ) : (
                  'Enviar link de recuperação'
                )}
              </button>
            </form>
          </>
        ) : (
          <div className="py-8">
            <div className="w-14 h-14 bg-brand-blue/10 rounded-full flex items-center justify-center mb-6">
              <Mail size={24} className="text-brand-blue" />
            </div>
            <h2 className="text-xl font-bold text-brand-dark mb-2">E-mail enviado!</h2>
            <p className="text-gray-500 text-sm mb-1">
              Enviamos um link de recuperação para:
            </p>
            <p className="font-medium text-brand-dark text-sm mb-6">{email}</p>
            <p className="text-gray-400 text-xs mb-8">
              Não recebeu? Verifique sua pasta de spam ou solicite outro link.
            </p>
            <div className="flex flex-col gap-3">
              <button
                onClick={() => { setSent(false); setEmail(''); }}
                className="text-sm font-medium text-brand-dark hover:text-brand-blue transition w-fit"
              >
                Tentar com outro e-mail
              </button>
              <Link
                to="/auth"
                className="flex items-center gap-1.5 text-sm text-gray-500 hover:text-brand-dark transition w-fit"
              >
                <ArrowLeft size={14} /> Voltar ao login
              </Link>
            </div>
          </div>
        )}
      </div>

      {/* Image Panel */}
      <div className="hidden md:block md:w-1/2 fixed right-0 h-screen">
        <img src={AuthBackground} alt="" className="w-full h-full object-cover" />
      </div>
      <div className="hidden md:block md:w-1/2" />
    </div>
  );
};

export default ForgotPassword;
