import React, { useState } from 'react';

const LoginCard = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    // Lógica de login vai aqui
    console.log('Email:', email, 'Password:', password);
  };

  return (
    <div className="bg-[#212121] h-full w-full rounded-lg flex-col items-center justify-center">
    
    <img src={require('./pets_logo.png')} alt="Logo" className='items-center justify-center w-3/12 h-auto'/>
    <h2 style={{ fontSize: "24px", color: "white"}}>
          <b>Bem vindo(a) de volta!</b>
    </h2>
    <h3 style={{ fontSize: "12px", color: "white"}}>
          Por favor, insira seus dados.
    </h3>
    <form>
      
    </form>
  </div>
  );
};

export default LoginCard;
