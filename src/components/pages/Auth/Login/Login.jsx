import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '../../../../config/firebase';
import { FaGoogle, FaEye, FaEyeSlash } from 'react-icons/fa';
import LogoWhite from '../assets/logo_white';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordVisible, setPasswordVisible] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await signInWithEmailAndPassword(auth, email, password);
      navigate('/dashboard'); // Assuming the dashboard is the next page
    } catch (error) {
      setError('Invalid email or password. Please try again.');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white flex justify-end items-center relative">
      {/* Image on the left side */}
      <div className="absolute left-16 top-0 h-full">
        <img 
          src={require('../../Auth/assets/auth_background.png')} 
          alt="Login Illustration"
          className="h-full object-cover"
        />
      </div>

      <div 
        className="relative bg-[#212121] p-8 space-y-6 rounded-[39px] shadow-xl overflow-auto transform-gpu transition-transform duration-500 ease-in-out hover:scale-105 hover:shadow-2xl"
        style={{
          width: '30vw',  // Adjusted width (30% of the viewport width)
          height: '92vh', // Adjusted height (92% of the viewport height)
          marginRight: '2vw', // Closer to the right edge
          marginTop: '1vh', // Closer to the top
          marginBottom: '1vh', // Closer to the bottom
          maxHeight: 'calc(100vh - 2vh)', // Max height ensures no overflow
          maxWidth: 'calc(100vw - 2vw)',   // Max width ensures no overflow
          boxShadow: '0 12px 24px rgba(0, 0, 0, 0.25)', // Subtle shadow
          animation: 'float 3s ease-in-out infinite', // Floating animation
        }}
      >
      <div className="flex justify-center items-center"><LogoWhite /></div>

        <h1 className="text-2xl text-white font-bold text-center">Bem vindo(a) de volta!</h1>
        <p className="text-center text-white text-gray-500">
          Por favor, insira seus dados.
        </p>

        {error && (
          <div className="bg-red-500 text-white p-2 rounded-md">
            {error}
          </div>
        )}

        <form className="space-y-4" onSubmit={handleLogin}>
          <div>
            <label className="block text-white">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-3 py-1 bg-transparent border-0 border-b-2 border-gray-300 focus:outline-none focus:border-b-2 focus:border-gray-500"
              required
            />
          </div>
          <div>
            <label className="block text-white">Senha</label>
            <div className="relative">
              <input
                type={passwordVisible ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-3 py-1 bg-transparent border-0 border-b-2 border-gray-300 focus:outline-none focus:border-b-2 focus:border-gray-500"
                required
              />
              <button
                type="button"
                onClick={() => setPasswordVisible(!passwordVisible)}
                className="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
              >
                {passwordVisible ? <FaEyeSlash /> : <FaEye />}
              </button>
            </div>
          </div>

          <div className="flex justify-between">
            <a href="/reset-password" className="text-white hover:underline">
              Esqueceu a senha?
            </a>
          </div>

          <button
            type="submit"
            disabled={loading}
            className={`w-full bg-[#F0BE4D] hover:bg-indigo-700 text-white font-bold py-2 px-4 rounded-3xl transition-all duration-300 ${
              loading ? 'opacity-50 cursor-not-allowed' : ''
            }`}
          >
            {loading ? 'Logging in...' : 'Log in'}
          </button>
        </form>

        <button className="w-full bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded mt-4 flex items-center justify-center transition-all duration-300">
          <FaGoogle className="mr-2" /> Log in with Google
        </button>

        <p className="text-center text-gray-500">
          Não tem uma conta?{' '}
          <a href="/register" className="text-indigo-500 hover:underline">
            Crie uma
          </a>
        </p>
      </div>

      <style jsx>{`
        @keyframes float {
          0% {
            transform: translateY(0px);
          }
          50% {
            transform: translateY(-1px);
          }
          100% {
            transform: translateY(0px);
          }
        }
      `}</style>
    </div>
  );
};

export default Login;
