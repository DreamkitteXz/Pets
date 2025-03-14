import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../../context/AuthContext';
import { sendEmailVerification } from 'firebase/auth';

const EmailVerificationForm = () => {
  const { user } = useAuth();
  const navigate = useNavigate();

  const handleResendEmail = async () => {
    try {
      if (user && !user.emailVerified) {
        await sendEmailVerification(user);
        alert('Verification email sent! Please check your inbox.');
      }
    } catch (error) {
      console.error('Error sending verification email:', error);
      alert('Error sending verification email. Please try again.');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="max-w-md w-full bg-white rounded-lg shadow-md p-8">
        <h2 className="text-2xl font-bold text-center mb-4">Verify Your Email</h2>
        <p className="text-gray-600 text-center mb-6">
          We've sent a verification email to your inbox. Please verify your email address to continue.
        </p>
        <div className="space-y-4">
          <button
            onClick={handleResendEmail}
            className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700"
          >
            Resend Verification Email
          </button>
          <button
            onClick={() => navigate('/auth')}
            className="w-full border border-gray-300 text-gray-700 py-2 px-4 rounded-md hover:bg-gray-50"
          >
            Back to Login
          </button>
        </div>
      </div>
    </div>
  );
};

export default EmailVerificationForm;
