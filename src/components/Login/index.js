import React, { useState, useEffect } from 'react';

const Login = async () => {
  const [loginEmail,setloginEmail] = useState('');
  const [loginPassword,setloginPassword] = useState('');
  return(
    <div>
        <h3> Login </h3>
        <input placeholder="Email..."/>
        <input placeholder="Password..."/>

        <button> Login</button>
      </div>

  );
}
export default Login