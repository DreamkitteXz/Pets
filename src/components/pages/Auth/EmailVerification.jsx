import React, { useEffect, useState } from 'react';
import { auth } from '../../../config/firebase';
import { sendEmailVerification } from 'firebase/auth';
import { useNavigate } from 'react-router-dom';

const EmailVerification = () => {
  const [isVerified, setIsVerified] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    const checkVerification = () => {
      const user = auth.currentUser;
      if (user) {
        if (user.emailVerified) {
          setIsVerified(true);
          navigate('/complete-profile');
        } else {
          setIsVerified(false);
        }
      }
      setLoading(false);
    };

    const unsubscribe = auth.onAuthStateChanged((user) => {
      if (user) {
        checkVerification();
      } else {
        navigate('/');
      }
    });

    return () => unsubscribe();
  }, [navigate]);

  const handleResendEmail = async () => {
    try {
      const user = auth.currentUser;
      await sendEmailVerification(user);
      setError('E-mail de verificação enviado! Por favor, verifique sua caixa de entrada.');
    } catch (error) {
      setError('Erro ao enviar e-mail de verificação: ' + error.message);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-teal-500"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-r from-blue-100 to-teal-50">
      <div className="bg-white p-8 rounded-lg shadow-xl max-w-md w-full">
        <div className="text-center">
          <h2 className="text-3xl font-bold text-teal-600 mb-4">Verificação de E-mail</h2>
          <div className="mb-6">
            {!isVerified ? (
              <>
                <p className="text-gray-600 mb-4">
                  Por favor, verifique seu endereço de e-mail para continuar. Verifique sua caixa de entrada para o link de verificação.
                </p>
                <button
                  onClick={handleResendEmail}
                  className="bg-teal-500 text-white px-6 py-2 rounded-md hover:bg-teal-600 transition duration-150"
                >
                  Reenviar E-mail de Verificação
                </button>
              </>
            ) : (
              <p className="text-green-600">E-mail verificado! Redirecionando...</p>
            )}
            {error && (
              <p className={`mt-4 text-sm ${error.includes('enviado') ? 'text-green-600' : 'text-red-600'}`}>
                {error}
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default EmailVerification;
