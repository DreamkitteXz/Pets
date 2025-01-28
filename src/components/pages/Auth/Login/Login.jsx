/*import React, { useState } from 'react';
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
*/
import React, { useState } from "react";
import { useForm } from "react-hook-form";
import { Eye, EyeOff } from "lucide-react";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { getFirestore, collection, query, where, getDocs, addDoc } from "firebase/firestore";

const RegistrationPage = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [showPassword, setShowPassword] = useState(false);
  const [passwordStrength, setPasswordStrength] = useState(0);
  const {
    register,
    handleSubmit,
    watch,
    setError,
    clearErrors,
    formState: { errors },
  } = useForm();

  const validatePassword = (password) => {
    const strength =
      /(?=.*[A-Z])/.test(password) +
      /(?=.*[a-z])/.test(password) +
      /(?=.*\d)/.test(password) +
      /(?=.*[!@#$%^&*])/.test(password);
    setPasswordStrength(strength);
    return strength === 4;
  };

  const isEmailRegistered = async (email) => {
    try {
      const db = getFirestore();
      const veterinariansRef = collection(db, "Veterinarians");
      const q = query(veterinariansRef, where("email", "==", email));
      const querySnapshot = await getDocs(q);

      return !querySnapshot.empty;
    } catch (error) {
      console.error("Error checking email registration: ", error);
      throw new Error("Could not verify email registration.");
    }
  };

  const onSubmit = async (data) => {
    try {
      if (!data.agreeToTerms) {
        setError("agreeToTerms", { message: "You must agree to the terms of service." });
        return;
      }

      // Check if email is already registered
      const emailExists = await isEmailRegistered(data.email);
      if (emailExists) {
        setError("email", { message: "Email is already registered." });
        return;
      }

      // Create the user with Firebase Auth
      const auth = getAuth();
      const { user } = await createUserWithEmailAndPassword(auth, data.email, data.password);

      // Save the user details in the Firestore "Veterinarians" collection
      const db = getFirestore();
      const veterinariansRef = collection(db, "Veterinarians");
      await addDoc(veterinariansRef, {
        uid: user.uid,
        name: data.name,
        phone: data.phone,
        cpf_crmv: data.cpf_crmv,
        email: data.email,
        createdAt: new Date(),
      });

      alert("Account created successfully! Please verify your email.");
    } catch (error) {
      console.error("Error creating account:", error);
      alert("An error occurred. Please try again.");
    }
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-50">
      <div className="bg-white p-8 rounded-2xl shadow-md w-full max-w-md">
        <h2 className="text-2xl font-bold text-center mb-6">
          {isLogin ? "Login to your account" : "Create an account"}
        </h2>

        {!isLogin && (
          <div className="w-full bg-gray-200 rounded-full h-2 mb-4">
            <div
              className={`h-2 rounded-full ${passwordStrength === 4
                ? "bg-green-500"
                : passwordStrength === 3
                ? "bg-yellow-500"
                : "bg-red-500"}`}
              style={{ width: `${passwordStrength * 25}%` }}
            ></div>
          </div>
        )}

        <form
          onSubmit={handleSubmit(onSubmit)}
          className="space-y-4"
          noValidate
        >
          {!isLogin && (
            <>
              <div>
                <label className="block text-sm font-medium mb-1">Name</label>
                <input
                  type="text"
                  className="w-full p-2 border rounded"
                  {...register("name", {
                    required: "Name is required.",
                    pattern: {
                      value: /^[a-zA-Z\s]+$/,
                      message: "Name contains invalid characters.",
                    },
                  })}
                />
                {errors.name && <p className="text-red-500 text-sm">{errors.name.message}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Phone</label>
                <input
                  type="tel"
                  className="w-full p-2 border rounded"
                  {...register("phone", {
                    required: "Phone is required.",
                    pattern: {
                      value: /^\+?\d{10,14}$/,
                      message: "Invalid phone number format.",
                    },
                  })}
                />
                {errors.phone && <p className="text-red-500 text-sm">{errors.phone.message}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">CPF/CRMV</label>
                <input
                  type="text"
                  className="w-full p-2 border rounded"
                  {...register("cpf_crmv", {
                    required: "CPF/CRMV is required.",
                    pattern: {
                      value: /^\d{11}$/,
                      message: "Invalid CPF/CRMV format.",
                    },
                  })}
                />
                {errors.cpf_crmv && <p className="text-red-500 text-sm">{errors.cpf_crmv.message}</p>}
              </div>
            </>
          )}
          <div>
            <label className="block text-sm font-medium mb-1">Email</label>
            <input
              type="email"
              className="w-full p-2 border rounded"
              {...register("email", {
                required: "Email is required.",
                pattern: {
                  value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
                  message: "Invalid email format.",
                },
              })}
            />
            {errors.email && <p className="text-red-500 text-sm">{errors.email.message}</p>}
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Password</label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                className="w-full p-2 border rounded"
                {...register("password", {
                  required: "Password is required.",
                  validate: validatePassword,
                })}
              />
              <button
                type="button"
                className="absolute right-3 top-2 text-gray-500"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
              </button>
            </div>
            {errors.password && <p className="text-red-500 text-sm">{errors.password.message}</p>}
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Confirm Password</label>
            <input
              type="password"
              className="w-full p-2 border rounded"
              {...register("confirmPassword", {
                required: "Please confirm your password.",
                validate: (value) => value === watch("password") || "Passwords do not match.",
              })}
            />
            {errors.confirmPassword && <p className="text-red-500 text-sm">{errors.confirmPassword.message}</p>}
          </div>
          {!isLogin && (
            <div className="flex items-center">
              <input
                type="checkbox"
                {...register("agreeToTerms")}
                className="mr-2"
              />
              <label className="text-sm">I agree to the <a href="#" className="text-blue-500">terms of service</a>.</label>
            </div>
          )}
          {errors.agreeToTerms && <p className="text-red-500 text-sm">{errors.agreeToTerms.message}</p>}

          <button
            type="submit"
            className="w-full py-2 px-4 bg-blue-600 text-white rounded hover:bg-green-500"
          >
            {isLogin ? "Login" : "Sign Up"}
          </button>
        </form>

        <button
          className="mt-4 text-blue-500 hover:underline text-sm"
          onClick={() => setIsLogin(!isLogin)}
        >
          {isLogin ? "Create an account" : "Sign in instead"}
        </button>

        {isLogin && (
          <a href="#" className="block mt-2 text-blue-500 text-sm hover:underline">
            Forgot Password?
          </a>
        )}
      </div>
    </div>
  );
};

export default RegistrationPage;
