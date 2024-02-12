import React, { useState, useEffect } from 'react';

const Register = async () => {
  const [registerEmail,setRegisterEmail] = useState('');
  const [registerPassword,setRegisterPassword] = useState('');
  return(
    <div>
    <h3> Register User </h3>
    <input placeholder="Email..." onChange={(event) => {
      setRegisterEmail(event.target.value);
    }}/>
    <input placeholder="Password..."/>

    <button> Create User</button>
  </div>
  );
}
export default Register