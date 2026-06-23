import React, { useState } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { Eye, EyeOff, ArrowLeft, CheckCircle } from 'lucide-react';
import LogoBlack from '../../../assets/logos/logo_black';
import AuthBackground from './assets/auth_background.svg';
import { resetPassword } from '../../../services/firebase/authService';

const Spinner = () => (
  <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24" fill="none">
    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
  </svg>
);

const ResetPassword = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const oobCode = searchParams.get('oobCode');

  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [done, setDone] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (password !== confirmPassword) {
      setError('As senhas não coincidem.');
      return;
    }

    if (!oobCode) {
      setError('Link inválido. Solicite a recuperação de senha novamente.');
      return;
    }

    setLoading(true);
    const { error: err } = await resetPassword(oobCode, password);
    setLoading(false);

    if (err) { setError(err); return; }

    setDone(true);
    setTimeout(() => navigate('/auth'), 3000);
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

        {!done ? (
          <>
            <div className="mb-8">
              <h1 className="text-2xl md:text-3xl font-bold text-brand-dark font-montserrat">
                Nova senha
              </h1>
              <p className="text-gray-500 mt-2 text-sm">
                Escolha uma senha segura para sua conta.
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
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nova senha
                </label>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    minLength={6}
                    placeholder="••••••••"
                    className="w-full px-4 py-2.5 pr-11 border border-gray-200 rounded-lg bg-white
                      focus:outline-none focus:ring-2 focus:ring-brand-blue/50 focus:border-brand-blue
                      transition placeholder:text-gray-400 text-sm"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    aria-label={showPassword ? 'Ocultar senha' : 'Mostrar senha'}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition"
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Confirmar senha
                </label>
                <div className="relative">
                  <input
                    type={showConfirm ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                    placeholder="••••••••"
                    className="w-full px-4 py-2.5 pr-11 border border-gray-200 rounded-lg bg-white
                      focus:outline-none focus:ring-2 focus:ring-brand-blue/50 focus:border-brand-blue
                      transition placeholder:text-gray-400 text-sm"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirm(!showConfirm)}
                    aria-label={showConfirm ? 'Ocultar senha' : 'Mostrar senha'}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition"
                  >
                    {showConfirm ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-brand-dark text-white py-2.5 rounded-lg
                  hover:bg-brand-dark/90 focus:outline-none focus:ring-2 focus:ring-brand-dark/30
                  transition flex items-center justify-center gap-2 font-medium text-sm
                  disabled:opacity-60 disabled:cursor-not-allowed mt-2"
              >
                {loading ? (
                  <><Spinner /> Redefinindo...</>
                ) : (
                  'Redefinir senha'
                )}
              </button>
            </form>
          </>
        ) : (
          <div className="py-8">
            <div className="w-14 h-14 bg-green-50 rounded-full flex items-center justify-center mb-6">
              <CheckCircle size={24} className="text-green-500" />
            </div>
            <h2 className="text-xl font-bold text-brand-dark mb-2">Senha redefinida!</h2>
            <p className="text-gray-500 text-sm">
              Sua senha foi alterada com sucesso. Redirecionando para o login...
            </p>
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

export default ResetPassword;
