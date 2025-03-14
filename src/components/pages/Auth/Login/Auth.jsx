import React, { useState } from 'react';
import { auth } from '../../../../config/firebase';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  GoogleAuthProvider,
  signInWithPopup,
  sendEmailVerification
} from 'firebase/auth';
import { getFirestore, doc, setDoc, getDoc } from 'firebase/firestore';
// import { useAuth } from '../../../../context/AuthContext'; // Temporarily commented out

const db = getFirestore();

const VetAuthPage = () => {
  // const { user } = useAuth(); // Temporarily commented out
  const navigate = useNavigate();
  const location = useLocation();
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [name, setName] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  // Removed useEffect with auth check temporarily

  const handleGoogleSignIn = async () => {
    try {
      setError('');
      setLoading(true);
      const provider = new GoogleAuthProvider();
      await signInWithPopup(auth, provider);
      navigate('/');
    } catch (error) {
      setError('Failed to sign in with Google: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const checkUserProfile = async (uid) => {
    try {
      const userDoc = await getDoc(doc(db, "users", uid));
      if (userDoc.exists()) {
        const userData = userDoc.data();
        if (!userData.profileCompleted) {
          return false;
        }
        return true;
      }
      return false;
    } catch (error) {
      console.error("Error checking user profile:", error);
      return false;
    }
  };

  const handleLoginSuccess = () => {
    const from = location.state?.from?.pathname || '/';
    navigate(from, { replace: true });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (isLogin) {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        if (!user.emailVerified) {
          navigate('/verify-email');
          return;
        }

        const isProfileComplete = await checkUserProfile(user.uid);
        if (!isProfileComplete) {
          navigate('/complete-profile');
          return;
        }

        handleLoginSuccess();
      } else {
        if (password !== confirmPassword) {
          throw new Error('Passwords do not match!');
        }

        const userCredential = await createUserWithEmailAndPassword(auth, email, password);
        await sendEmailVerification(userCredential.user);
        
        // Create initial user document
        await setDoc(doc(db, "users", userCredential.user.uid), {
          email,
          name,
          createdAt: new Date().toISOString(),
          status: 'pending',
          emailVerified: false
        });

        navigate('/verify-email');
      }
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-r from-blue-100 to-teal-50">
      <div className="absolute top-0 left-0 w-full h-full overflow-hidden z-0 opacity-10">
        <div className="absolute top-10 left-10 transform rotate-12">
          <svg width="80" height="80" viewBox="0 0 24 24" fill="#3B82F6">
            <path d="M4.5,10.5 C5.88071187,10.5 7,11.6192881 7,13 C7,14.3807119 5.88071187,15.5 4.5,15.5 C3.11928813,15.5 2,14.3807119 2,13 C2,11.6192881 3.11928813,10.5 4.5,10.5 Z M8.5,7 C9.88071187,7 11,8.11928813 11,9.5 C11,10.8807119 9.88071187,12 8.5,12 C7.11928813,12 6,10.8807119 6,9.5 C6,8.11928813 7.11928813,7 8.5,7 Z M12.5,7 C13.8807119,7 15,8.11928813 15,9.5 C15,10.8807119 13.8807119,12 12.5,12 C11.1192881,12 10,10.8807119 10,9.5 C10,8.11928813 11.1192881,7 12.5,7 Z M16.5,10.5 C17.8807119,10.5 19,11.6192881 19,13 C19,14.3807119 17.8807119,15.5 16.5,15.5 C15.1192881,15.5 14,14.3807119 14,13 C14,11.6192881 15.1192881,10.5 16.5,10.5 Z M10.5,14 C11.8807119,14 13,15.1192881 13,16.5 C13,17.8807119 11.8807119,19 10.5,19 C9.11928813,19 8,17.8807119 8,16.5 C8,15.1192881 9.11928813,14 10.5,14 Z" />
          </svg>
        </div>
        <div className="absolute bottom-20 right-20 transform -rotate-12">
          <svg width="100" height="100" viewBox="0 0 24 24" fill="#34D399">
            <path d="M12,2 C15.9,2 19,5.1 19,9 C19,11.4 17.8,13.5 16,14.7 L16,21 L10,17.6 L8,21 L8,14.7 C6.2,13.5 5,11.4 5,9 C5,5.1 8.1,2 12,2 Z M11,6 C10.4,6 10,6.4 10,7 C10,7.6 10.4,8 11,8 C11.6,8 12,7.6 12,7 C12,6.4 11.6,6 11,6 Z M13,6 C12.4,6 12,6.4 12,7 C12,7.6 12.4,8 13,8 C13.6,8 14,7.6 14,7 C14,6.4 13.6,6 13,6 Z" />
          </svg>
        </div>
        <div className="absolute top-40 right-10">
          <svg width="70" height="70" viewBox="0 0 24 24" fill="#EC4899">
            <path d="M5.5,6 C4.11928813,6 3,4.88071187 3,3.5 C3,2.11928813 4.11928813,1 5.5,1 C6.88071187,1 8,2.11928813 8,3.5 C8,4.88071187 6.88071187,6 5.5,6 Z M18.5,6 C17.1192881,6 16,4.88071187 16,3.5 C16,2.11928813 17.1192881,1 18.5,1 C19.8807119,1 21,2.11928813 21,3.5 C21,4.88071187 19.8807119,6 18.5,6 Z M16.7823365,12.1976409 C17.4185207,13.6093037 18.5,16.1428571 18.5,18 C18.5,21.3137085 16.7622088,23 14.5,23 C12.2377912,23 10.5,21.3137085 10.5,18 C10.5,16.1465313 11.5756144,13.6167404 12.2111584,12.2037553 C12.2784879,12.0663666 12.4112195,12.0137926 12.5,12 L16.5,12 C16.5880866,12.013566 16.7172299,12.0644546 16.7823365,12.1976409 Z M3,15.9986859 C3,20.970583 4.790861,21.9984859 6.5,21.9984859 C8.209139,21.9984859 10,20.970583 10,15.9986859 C10,13.9942387 9.375,11.6116002 9,10.9986859 C8.82561292,10.7110758 8.66394951,10.4942387 8.5,10.5010109 L4.5,10.5010109 C4.33139085,10.5010109 4.18586869,10.7110758 4,10.9986859 C3.625,11.6116002 3,13.9942387 3,15.9986859 Z" />
          </svg>
        </div>
        <div className="absolute bottom-40 left-1/4">
          <svg width="90" height="90" viewBox="0 0 24 24" fill="#8B5CF6">
            <path d="M9,18.9981014 C9,19.5503862 7.6568542,20 6,20 C4.3431458,20 3,19.5503862 3,18.9981014 C3,18.4458167 4.3431458,18 6,18 C7.6568542,18 9,18.4458167 9,18.9981014 Z M21,18.9981014 C21,19.5503862 19.6568542,20 18,20 C16.3431458,20 15,19.5503862 15,18.9981014 C15,18.4458167 16.3431458,18 18,18 C19.6568542,18 21,18.4458167 21,18.9981014 Z M15,8 C15,11.3137085 12.3137085,14 9,14 C5.6862915,14 3,11.3137085 3,8 C3,4.6862915 5.6862915,2 9,2 C12.3137085,2 15,4.6862915 15,8 Z M7.5,7 C6.67157288,7 6,7.67157288 6,8.5 C6,9.32842712 6.67157288,10 7.5,10 C8.32842712,10 9,9.32842712 9,8.5 C9,7.67157288 8.32842712,7 7.5,7 Z M10.5,7 C9.67157288,7 9,7.67157288 9,8.5 C9,9.32842712 9.67157288,10 10.5,10 C11.3284271,10 12,9.32842712 12,8.5 C12,7.67157288 11.3284271,7 10.5,7 Z M19.5,9 L19.5,15 L15,15 L15,13.5 C15,13.2238576 15.2238576,13 15.5,13 L17.5,13 C17.7761424,13 18,12.7761424 18,12.5 L18,11.5 C18,11.2238576 17.7761424,11 17.5,11 L15.5,11 C15.2238576,11 15,10.7761424 15,10.5 L15,9 L19.5,9 Z" />
          </svg>
        </div>
      </div>
      
      <div className="bg-white p-8 rounded-lg shadow-xl w-full max-w-md relative z-10 border-2 border-teal-400">
        <div className="flex justify-center mb-6">
          <svg width="107" height="64" viewBox="0 0 107 64" fill="none" xmlns="http://www.w3.org/2000/svg">
               <path d="M43.8 49.7C41.3333 49.7 39.15 49.1833 37.25 48.15C35.3833 47.0833 33.9167 45.6 32.85 43.7C31.8167 41.7667 31.3 39.5 31.3 36.9V36.3C31.3 33.7 31.8167 31.45 32.85 29.55C33.8833 27.6167 35.3333 26.1333 37.2 25.1C39.0667 24.0333 41.2333 23.5 43.7 23.5C46.1333 23.5 48.25 24.05 50.05 25.15C51.85 26.2167 53.25 27.7167 54.25 29.65C55.25 31.55 55.75 33.7667 55.75 36.3V38.45H37.7C37.7667 40.15 38.4 41.5333 39.6 42.6C40.8 43.6667 42.2667 44.2 44 44.2C45.7667 44.2 47.0667 43.8167 47.9 43.05C48.7333 42.2833 49.3667 41.4333 49.8 40.5L54.95 43.2C54.4833 44.0667 53.8 45.0167 52.9 46.05C52.0333 47.05 50.8667 47.9167 49.4 48.65C47.9333 49.35 46.0667 49.7 43.8 49.7ZM37.75 33.75H49.35C49.2167 32.3167 48.6333 31.1667 47.6 30.3C46.6 29.4333 45.2833 29 43.65 29C41.95 29 40.6 29.4333 39.6 30.3C38.6 31.1667 37.9833 32.3167 37.75 33.75ZM70.0273 49C68.394 49 67.0607 48.5 66.0273 47.5C65.0273 46.4667 64.5273 45.1 64.5273 43.4V29.4H58.3273V24.2H64.5273V16.5H70.8273V24.2H77.6273V29.4H70.8273V42.3C70.8273 43.3 71.294 43.8 72.2273 43.8H77.0273V49H70.0273ZM93.6301 49.7C90.3967 49.7 87.7467 49 85.6801 47.6C83.6134 46.2 82.3634 44.2 81.9301 41.6L87.7301 40.1C87.9634 41.2667 88.3467 42.1833 88.8801 42.85C89.4467 43.5167 90.1301 44 90.9301 44.3C91.7634 44.5667 92.6634 44.7 93.6301 44.7C95.0967 44.7 96.1801 44.45 96.8801 43.95C97.5801 43.4167 97.9301 42.7667 97.9301 42C97.9301 41.2333 97.5967 40.65 96.9301 40.25C96.2634 39.8167 95.1967 39.4667 93.7301 39.2L92.3301 38.95C90.5967 38.6167 89.0134 38.1667 87.5801 37.6C86.1467 37 84.9967 36.1833 84.1301 35.15C83.2634 34.1167 82.8301 32.7833 82.8301 31.15C82.8301 28.6833 83.7301 26.8 85.5301 25.5C87.3301 24.1667 89.6967 23.5 92.6301 23.5C95.3967 23.5 97.6967 24.1167 99.5301 25.35C101.363 26.5833 102.563 28.2 103.13 30.2L97.2801 32C97.0134 30.7333 96.4634 29.8333 95.6301 29.3C94.8301 28.7667 93.8301 28.5 92.6301 28.5C91.4301 28.5 90.5134 28.7167 89.8801 29.15C89.2467 29.55 88.9301 30.1167 88.9301 30.85C88.9301 31.65 89.2634 32.25 89.9301 32.65C90.5967 33.0167 91.4967 33.3 92.6301 33.5L94.0301 33.75C95.8967 34.0833 97.5801 34.5333 99.0801 35.1C100.613 35.6333 101.813 36.4167 102.68 37.45C103.58 38.45 104.03 39.8167 104.03 41.55C104.03 44.15 103.08 46.1667 101.18 47.6C99.3134 49 96.7967 49.7 93.6301 49.7Z" fill="black"/>
               <path d="M2.288 17.2199C2.288 17.3959 2.2152 17.4399 1.9344 17.4399C1.2896 17.4399 0.936 17.5608 0.936 17.7808C0.936 17.9127 0.8632 17.9897 0.7384 17.9897C0.572 17.9897 0.52 18.0887 0.4576 18.4845C0.4056 18.8694 0.3536 18.9794 0.1976 18.9794C0 18.9794 0 19.3533 0 33.9897V49H1.144C2.2152 49 2.288 48.989 2.288 48.7801C2.288 48.5931 2.3608 48.5601 2.7664 48.5601C3.1616 48.5601 3.2552 48.5162 3.2968 48.3402C3.3384 48.1863 3.4736 48.0983 3.7544 48.0543C4.056 47.9993 4.16 47.9333 4.16 47.7794C4.16 47.6474 4.2328 47.5704 4.3576 47.5704C4.4928 47.5704 4.576 47.4825 4.5968 47.3175C4.6176 47.1636 4.7112 47.0646 4.8672 47.0426C5.0648 47.0096 5.096 46.9436 5.096 46.5148C5.096 46.1079 5.1272 46.0309 5.304 46.0309C5.46 46.0309 5.512 45.954 5.512 45.723C5.512 45.0302 5.6368 44.6014 5.8344 44.6014C6.0216 44.6014 6.032 44.4144 6.032 39.6529C6.032 34.7814 6.032 34.7045 6.24 34.7045C6.3752 34.7045 6.448 34.6275 6.448 34.4845C6.448 34.2976 6.5208 34.2646 6.8536 34.2646C7.5504 34.2646 7.904 34.1436 7.904 33.9237C7.904 33.7478 7.9872 33.7148 8.372 33.7148C8.7672 33.7148 8.84 33.6818 8.84 33.4948C8.84 33.3519 8.9128 33.2749 9.048 33.2749C9.204 33.2749 9.256 33.1979 9.256 33C9.256 32.7801 9.308 32.7251 9.516 32.7251C9.7656 32.7251 9.776 32.7031 9.776 32.0103C9.776 31.3725 9.7968 31.2955 9.984 31.2955C10.1816 31.2955 10.192 31.2186 10.192 28.8213C10.192 26.4241 10.1816 26.3471 9.984 26.3471C9.8488 26.3471 9.776 26.2701 9.776 26.1271C9.776 25.9622 9.7032 25.9072 9.516 25.9072C9.3288 25.9072 9.256 25.9622 9.256 26.1271C9.256 26.2701 9.1832 26.3471 9.048 26.3471C8.8504 26.3471 8.84 26.4241 8.84 29.0082C8.84 30.4818 8.8088 31.7904 8.7776 31.9223C8.7464 32.0433 8.632 32.1753 8.5176 32.2082C8.4032 32.2412 8.32 32.3622 8.32 32.4832C8.32 32.6701 8.2472 32.7141 7.8832 32.7471C7.5088 32.7691 7.4256 32.8241 7.4048 33.022C7.3736 33.2639 7.332 33.2749 6.2296 33.2749H5.096V29.811C5.096 26.4241 5.096 26.3471 5.304 26.3471C5.4704 26.3471 5.512 26.2701 5.512 25.9842C5.512 25.2364 5.6368 24.8076 5.8344 24.8076C5.9904 24.8076 6.032 24.7196 6.032 24.3677C6.032 24.0048 6.0632 23.9278 6.24 23.9278C6.396 23.9278 6.448 23.8509 6.448 23.6529C6.448 23.433 6.5 23.378 6.708 23.378C6.8952 23.378 6.968 23.323 6.968 23.1581C6.968 23.0151 7.0408 22.9381 7.1656 22.9381C7.3008 22.9381 7.384 22.8502 7.4048 22.6852C7.436 22.4763 7.5088 22.4433 7.9352 22.4103C8.3408 22.3773 8.424 22.3443 8.424 22.1574C8.424 21.9594 8.5176 21.9485 10.712 21.9485C12.9168 21.9485 13 21.9595 13 22.1684C13 22.3553 13.0832 22.3773 13.7072 22.4103C14.3416 22.4433 14.404 22.4653 14.4352 22.6852C14.456 22.8502 14.5392 22.9381 14.6744 22.9381C14.7992 22.9381 14.872 23.0151 14.872 23.1581C14.872 23.323 14.9448 23.378 15.132 23.378C15.3192 23.378 15.392 23.433 15.392 23.5869C15.392 23.8289 15.756 23.9278 16.6504 23.9278C17.1912 23.9278 17.264 23.9498 17.264 24.1478C17.264 24.3567 17.3368 24.3677 18.6056 24.3677C19.9264 24.3677 19.9576 24.3677 19.9888 24.6096C20.0096 24.7746 20.1032 24.8735 20.2592 24.8955C20.5608 24.9395 20.5816 25.3574 20.28 25.3574C20.1448 25.3574 20.072 25.4344 20.072 25.5773C20.072 25.7203 20.1448 25.7973 20.28 25.7973C20.436 25.7973 20.488 25.8742 20.488 26.0722C20.488 26.2701 20.54 26.3471 20.6856 26.3471C20.9456 26.3471 21.008 26.732 21.008 28.2605C21.008 29.866 20.9352 30.3058 20.6856 30.3058C20.54 30.3058 20.488 30.3828 20.488 30.5808C20.488 30.7787 20.436 30.8557 20.28 30.8557C20.1448 30.8557 20.072 30.9326 20.072 31.0756C20.072 31.2406 19.9992 31.2955 19.812 31.2955C19.6248 31.2955 19.552 31.3505 19.552 31.5155C19.552 31.6584 19.4792 31.7354 19.3544 31.7354C19.2192 31.7354 19.136 31.8234 19.1152 31.9773C19.084 32.1973 19.0112 32.2302 18.5952 32.2632C18.1792 32.2962 18.096 32.3292 18.096 32.5162C18.096 32.7141 18.0128 32.7251 16.952 32.7251H15.808V33C15.808 33.2529 15.7664 33.2749 15.34 33.2749C14.9448 33.2749 14.872 33.3079 14.872 33.4948C14.872 33.6378 14.7992 33.7148 14.6744 33.7148C14.5184 33.7148 14.4664 33.8247 14.4144 34.2096C14.352 34.6055 14.3 34.7045 14.1336 34.7045C13.9672 34.7045 13.936 34.7814 13.936 35.1993C13.936 35.6172 13.9048 35.6942 13.728 35.6942C13.5304 35.6942 13.52 35.7711 13.52 36.6838C13.52 37.5966 13.53 37.6735 13.728 37.6735C13.9048 37.6735 13.936 37.7505 13.936 38.1684C13.936 38.6192 13.9568 38.6632 14.196 38.6632C14.3832 38.6632 14.456 38.7182 14.456 38.8722C14.456 39.0481 14.5496 39.1031 14.924 39.1691C15.288 39.2241 15.392 39.279 15.392 39.444C15.392 39.6419 15.496 39.6529 17.004 39.6529C18.512 39.6529 18.616 39.6419 18.616 39.444C18.616 39.2351 19.0216 39.1031 19.6872 39.1031C19.8952 39.1031 19.968 39.0481 19.968 38.8832C19.968 38.6962 20.0408 38.6632 20.436 38.6632C20.8312 38.6632 20.904 38.6302 20.904 38.4543C20.904 38.2784 20.9976 38.2234 21.372 38.1574C21.736 38.1024 21.84 38.0474 21.84 37.8825C21.84 37.7285 21.9128 37.6735 22.1 37.6735C22.2872 37.6735 22.36 37.6186 22.36 37.4536C22.36 37.3107 22.4328 37.2337 22.568 37.2337C22.724 37.2337 22.776 37.1567 22.776 36.9588C22.776 36.7388 22.828 36.6838 23.036 36.6838C23.244 36.6838 23.296 36.6289 23.296 36.4089C23.296 36.211 23.348 36.134 23.4936 36.134C23.6496 36.134 23.712 36.0241 23.764 35.6942C23.816 35.3643 23.8784 35.2543 24.0344 35.2543C24.18 35.2543 24.232 35.1773 24.232 34.9794C24.232 34.7814 24.284 34.7045 24.4296 34.7045C24.596 34.7045 24.6376 34.6165 24.6688 34.2316C24.6896 33.8467 24.7416 33.7588 24.9392 33.7368C25.1472 33.7038 25.168 33.6378 25.168 32.989C25.168 32.3622 25.1888 32.2852 25.376 32.2852C25.5632 32.2852 25.584 32.2082 25.584 31.4275C25.584 30.3168 25.6776 29.756 25.8544 29.756C25.9688 29.756 26 29.4921 26 28.5464C26 27.6007 25.9688 27.3368 25.8544 27.3368C25.6672 27.3368 25.584 26.7649 25.584 25.4344C25.584 24.4447 25.5736 24.3677 25.376 24.3677C25.2096 24.3677 25.168 24.2907 25.168 23.9938C25.168 23.356 25.0536 22.9601 24.8456 22.9052C24.6896 22.8612 24.648 22.7512 24.648 22.3993C24.648 22.0254 24.6168 21.9485 24.44 21.9485C24.284 21.9485 24.232 21.8715 24.232 21.6735C24.232 21.4536 24.18 21.3986 23.972 21.3986C23.764 21.3986 23.712 21.3436 23.712 21.1237C23.712 20.9258 23.66 20.8488 23.504 20.8488C23.3688 20.8488 23.296 20.7718 23.296 20.6289C23.296 20.4859 23.2232 20.4089 23.0984 20.4089C22.9632 20.4089 22.88 20.321 22.8592 20.156C22.8384 20.0021 22.7448 19.9031 22.5992 19.8811C22.4432 19.8591 22.36 19.7711 22.36 19.6282C22.36 19.4742 22.2872 19.4192 22.1 19.4192C21.9128 19.4192 21.84 19.3643 21.84 19.1993C21.84 19.0564 21.7672 18.9794 21.6424 18.9794C21.5072 18.9794 21.424 18.8914 21.4032 18.7265C21.3824 18.5285 21.2992 18.4735 20.9352 18.4515C20.5712 18.4186 20.488 18.3746 20.488 18.1986C20.488 18.0227 20.4152 17.9897 20.02 17.9897C19.6352 17.9897 19.552 17.9567 19.552 17.7808C19.552 17.5278 19.136 17.4399 17.7632 17.4399C16.8168 17.4399 16.744 17.4289 16.744 17.2199C16.744 17 16.6712 17 9.516 17C2.3608 17 2.288 17 2.288 17.2199Z" fill="black"/>
             </svg>
        </div>
        
        <h2 className="text-3xl font-bold text-center mb-2 text-teal-600">
          {isLogin ? 'Bem vindo(a) de volta!' : 'Create Account'}
        </h2>
        <p className="text-center text-gray-600 mb-6">
          {isLogin 
            ? 'Sign in to access your veterinary dashboard' 
            : 'Join our pet care community'}
        </p>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          {!isLogin && (
            <div>
              <label className="block text-gray-700 text-sm font-medium mb-1" htmlFor="name">
                Full Name
              </label>
              <input
                id="name"
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-teal-500"
                required={!isLogin}
                placeholder="Dr. João Silva"
              />
            </div>
          )}
          
          <div>
            <label className="block text-gray-700 text-sm font-medium mb-1" htmlFor="email">
              Email Address
            </label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-teal-500"
              required
              placeholder="joao.silva@example.com"
            />
          </div>
          
          <div>
            <label className="block text-gray-700 text-sm font-medium mb-1" htmlFor="password">
              Password
            </label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-teal-500"
              required
            />
          </div>
          
          {!isLogin && (
            <div>
              <label className="block text-gray-700 text-sm font-medium mb-1" htmlFor="confirmPassword">
                Confirm Password
              </label>
              <input
                id="confirmPassword"
                type="password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-teal-500"
                required={!isLogin}
              />
            </div>
          )}
          
          {isLogin && (
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <input
                  id="remember-me"
                  type="checkbox"
                  className="h-4 w-4 text-teal-500 focus:ring-teal-500 border-gray-300 rounded"
                />
                <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-700">
                  Remember me
                </label>
              </div>
              <div className="text-sm">
                <a href="#" className="font-medium text-teal-600 hover:text-teal-500">
                  Forgot password?
                </a>
              </div>
            </div>
          )}
          
          <button
            type="submit"
            disabled={loading}
            className={`w-full bg-teal-500 text-white py-2 px-4 rounded-md hover:bg-teal-600 
              focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2 
              transition duration-150 ${loading ? 'opacity-70 cursor-not-allowed' : ''}`}
          >
            {loading ? 'Processing...' : (isLogin ? 'Sign In' : 'Create Account')}
          </button>
        </form>
        
        {error && (
          <div className="mt-4 text-center text-red-600 text-sm">
            {error}
          </div>
        )}

        <div className="mt-6 text-center">
          <p className="text-sm text-gray-600">
            {isLogin ? "Don't have an account? " : "Already have an account? "}
            <button
              type="button"
              onClick={() => setIsLogin(!isLogin)}
              className="font-medium text-teal-600 hover:text-teal-500"
            >
              {isLogin ? 'Sign up' : 'Sign in'}
            </button>
          </p>
        </div>
        
        <div className="mt-6">
          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-300"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-white text-gray-500">Or continue with</span>
            </div>
          </div>
          
          <div className="mt-6 grid grid-cols-2 gap-3">
            <button
              type="button"
              onClick={handleGoogleSignIn}
              disabled={loading}
              className="w-full inline-flex justify-center py-2 px-4 border border-gray-300 
                rounded-md shadow-sm bg-white text-sm font-medium text-gray-700 
                hover:bg-gray-50 disabled:opacity-70 disabled:cursor-not-allowed"
            >
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
              </svg>
              <span className="ml-2">Sign in with Google</span>
            </button>
            <button
              type="button"
              className="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M22,12c0,5.52-4.48,10-10,10S2,17.52,2,12S6.48,2,12,2S22,6.48,22,12z M12,6.75 c-0.69,0-1.25,0.56-1.25,1.25c0,0.69,0.56,1.25,1.25,1.25S13.25,8.69,13.25,8C13.25,7.31,12.69,6.75,12,6.75z M14,15.75h-4 c-0.55,0-1-0.45-1-1v0c0-0.55,0.45-1,1-1h0.75v-2H10c-0.55,0-1-0.45-1-1v0c0-0.55,0.45-1,1-1h1c0.55,0,1,0.45,1,1v3h1 c0.55,0,1,0.45,1,1v0C15,15.3,14.55,15.75,14,15.75z"/>
              </svg>
            </button>
          </div>
        </div>
        
        <div className="absolute -bottom-4 -right-4">
          <div className="bg-pink-400 rounded-full w-8 h-8 flex items-center justify-center">
            <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12,2C6.48,2,2,6.48,2,12s4.48,10,10,10s10-4.48,10-10S17.52,2,12,2z M12,18c-3.31,0-6-2.69-6-6s2.69-6,6-6s6,2.69,6,6 S15.31,18,12,18z M11,15h2v2h-2V15z M11,7h2v6h-2V7z"/>
            </svg>
          </div>
        </div>
        
        <div className="absolute -bottom-4 -left-4">
          <div className="bg-purple-400 rounded-full w-8 h-8 flex items-center justify-center">
            <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M4.5,9.5 C5.88071187,9.5 7,10.6192881 7,12 C7,13.3807119 5.88071187,14.5 4.5,14.5 C3.11928813,14.5 2,13.3807119 2,12 C2,10.6192881 3.11928813,9.5 4.5,9.5 Z M12,2 C13.3807119,2 14.5,3.11928813 14.5,4.5 C14.5,5.88071187 13.3807119,7 12,7 C10.6192881,7 9.5,5.88071187 9.5,4.5 C9.5,3.11928813 10.6192881,2 12,2 Z M12,17 C13.3807119,17 14.5,18.1192881 14.5,19.5 C14.5,20.8807119 13.3807119,22 12,22 C10.6192881,22 9.5,20.8807119 9.5,19.5 C9.5,18.1192881 10.6192881,17 12,17 Z M19.5,9.5 C20.8807119,9.5 22,10.6192881 22,12 C22,13.3807119 20.8807119,14.5 19.5,14.5 C18.1192881,14.5 17,13.3807119 17,12 C17,10.6192881 18.1192881,9.5 19.5,9.5 Z" />
            </svg>
          </div>
        </div>
      </div>
    </div>
  );
};

export default VetAuthPage;