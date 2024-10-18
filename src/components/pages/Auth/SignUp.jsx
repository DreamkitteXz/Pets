import React, { useState } from 'react';
import { auth, db } from '../../../config/firebase';
import { createUserWithEmailAndPassword } from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';
import { useNavigate } from 'react-router-dom';
import LogoBlack from './assets/logo_black';

const Register = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [cpf, setCpf] = useState('');
  const [crmv, setCrmv] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const navigate = useNavigate();

  const handleRegister = async (e) => {
    e.preventDefault();
    if (password !== confirmPassword) {
      alert('Passwords do not match!');
      return;
    }
    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      await setDoc(doc(db, 'veterinarians', user.uid), { name, email, phone, cpf, crmv });
      navigate('/login');
    } catch (error) {
      console.error('Error during registration:', error.message);
    }
  };

  return (
    <div className="min-h-screen bg-white flex justify-end items-center">
      {/* Image on the left side */}
      <div className="absolute left-16 top-0 h-full">
        <img 
          src={require('./assets/auth_background.png')} 
          alt="Login Illustration"
          className="h-full object-cover"
        />
      </div>

      {/* Form Card */}
      <div 
  className="relative bg-white p-8 space-y-6 rounded-[39px] shadow-xl overflow-auto"
  style={{
    width: '38vw',  // Slightly increased width to bring the card closer to the right edge
    height: '90vh', // Slightly increased height to bring it closer to the top/bottom edges
    margin: '2vh 2vw', // Reduced margins (2% of viewport height & width) to bring it closer to edges
    maxHeight: 'calc(100vh - 4vh)', // Keeps the card from overflowing vertically
    maxWidth: 'calc(100vw - 4vw)'   // Keeps the card from overflowing horizontally
  }}
>   
        {/* Logo at the top */}
        <div className="flex justify-center items-center"><LogoBlack /></div>

        <h1 className="text-3xl font-inter font-bold text-center">Crie sua conta</h1>
        <p className="text-[#47484B] text-sm font-inter font-medium text-center px-6">Por favor, preencha os campos. Iremos analizar sua documentação.</p>
        
        <form className="space-y-4" onSubmit={handleRegister}>
          <div>
            <label className="block text-gray-700">Nome</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full px-3 py-1 bg-transparent border-0 border-b-2 border-gray-300 focus:outline-none focus:border-gray-500 text-gray-700"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-3 py-1 bg-transparent border-0 border-b-2 border-gray-300 focus:outline-none focus:border-gray-500 text-gray-700"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700">Telefone</label>
            <input
              type="text"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="w-full px-3 py-1 bg-transparent border-0 border-b-2 border-gray-300 focus:outline-none focus:border-gray-500 text-gray-700"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700">CPF</label>
            <input
              type="text"
              value={cpf}
              onChange={(e) => setCpf(e.target.value)}
              className="w-full px-3 py-1 bg-transparent border-0 border-b-2 border-gray-300 focus:outline-none focus:border-gray-500 text-gray-700"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700">CRMV</label>
            <input
              type="text"
              value={crmv}
              onChange={(e) => setCrmv(e.target.value)}
              className="w-full px-3 py-1 bg-transparent border-0 border-b-2 border-gray-300 focus:outline-none focus:border-gray-500 text-gray-700"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700">Senha</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-3 py-1 bg-transparent border-0 border-b-2 border-gray-300 focus:outline-none focus:border-gray-500 text-gray-700"
              required
            />
          </div>
          <div>
            <label className="block text-gray-700">Confirme a senha</label>
            <input
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className="w-full px-3 py-1 bg-transparent border-0 border-b-2 border-gray-300 focus:outline-none focus:border-gray-500 text-gray-700"
              required
            />
          </div>

          <button
            type="submit"
            className="w-full bg-indigo-500 hover:bg-indigo-700 text-white font-bold py-2 px-4 rounded"
          >
            Criar conta
          </button>
        </form>
        
        <p className="text-center text-gray-500">
          Já tem uma conta? <a href="/login" className="text-indigo-500 hover:underline">Login</a>
        </p>
      </div>
    </div>
  );
};

export default Register;
