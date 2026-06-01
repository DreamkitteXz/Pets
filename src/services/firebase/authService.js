import { auth, db } from '../../config/firebase';
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut as firebaseSignOut,
  GoogleAuthProvider,
  signInWithPopup,
  sendPasswordResetEmail,
  sendEmailVerification,
  confirmPasswordReset,
  reload,
} from 'firebase/auth';
import { doc, setDoc, getDoc } from 'firebase/firestore';
import { getAuthErrorMessage } from '../../utils/authErrors';
import { sendOtp } from './otpService';

export async function signInWithEmail(email, password) {
  try {
    const credential = await signInWithEmailAndPassword(auth, email, password);
    return { user: credential.user, error: null };
  } catch (err) {
    return { user: null, error: getAuthErrorMessage(err) };
  }
}

export async function signUpWithEmail(email, password, name) {
  try {
    const credential = await createUserWithEmailAndPassword(auth, email, password);
    const user = credential.user;

    await setDoc(doc(db, 'users', user.uid), {
      email,
      name,
      createdAt: new Date().toISOString(),
      emailVerified: false,
    });

    // Try OTP-based verification (requires Functions deployed).
    // Falls back to the Firebase email-link if Functions are unavailable.
    const { error: otpError } = await sendOtp();
    if (otpError) {
      await sendEmailVerification(user).catch(() => {});
    }

    return { user, error: null };
  } catch (err) {
    return { user: null, error: getAuthErrorMessage(err) };
  }
}

export async function signInWithGoogle() {
  try {
    const provider = new GoogleAuthProvider();
    const credential = await signInWithPopup(auth, provider);
    const user = credential.user;

    const userRef = doc(db, 'users', user.uid);
    const userSnap = await getDoc(userRef);

    if (!userSnap.exists()) {
      await setDoc(userRef, {
        email: user.email,
        name: user.displayName || '',
        photoURL: user.photoURL || '',
        createdAt: new Date().toISOString(),
        emailVerified: true,
      });
    }

    return { user, error: null };
  } catch (err) {
    return { user: null, error: getAuthErrorMessage(err) };
  }
}

export async function signOut() {
  try {
    await firebaseSignOut(auth);
    return { error: null };
  } catch (err) {
    return { error: getAuthErrorMessage(err) };
  }
}

export async function sendPasswordReset(email) {
  try {
    await sendPasswordResetEmail(auth, email);
    return { error: null };
  } catch (err) {
    return { error: getAuthErrorMessage(err) };
  }
}

export async function resendVerificationEmail() {
  return sendOtp();
}

export async function resetPassword(oobCode, newPassword) {
  try {
    await confirmPasswordReset(auth, oobCode, newPassword);
    return { error: null };
  } catch (err) {
    return { error: getAuthErrorMessage(err) };
  }
}

export async function reloadUser() {
  try {
    const user = auth.currentUser;
    if (user) await reload(user);
    return auth.currentUser;
  } catch {
    return null;
  }
}
