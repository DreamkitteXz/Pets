// Create a new file: src/components/auth/LimitedAccessWrapper.jsx

import React, { useEffect, useState } from 'react';
import { auth } from '../../../config/firebase';
import { getFirestore, doc, getDoc } from 'firebase/firestore';
import ProfileIncompleteBanner from '../../ui/ProfileIncompleteBanner';

const db = getFirestore();

// This component wraps any page that should still be accessible with limited functionality
// when profile is incomplete (unlike ProfileCompletionCheck which redirects completely)
const LimitedAccessWrapper = ({ children, limitedView }) => {
  // COMENTADO: Verificação de perfil incompleto removida
  // O componente agora permite acesso total sem verificar se o perfil está completo
  // const [loading, setLoading] = useState(true);
  // const [isProfileComplete, setIsProfileComplete] = useState(false);
  
  // useEffect(() => {
  //   const checkProfileCompletion = async () => {
  //     try {
  //       const user = auth.currentUser;
  //       if (!user) {
  //         setLoading(false);
  //         return;
  //       }
  //       
  //       const userRef = doc(db, "users", user.uid);
  //       const userDoc = await getDoc(userRef);
  //       
  //       if (userDoc.exists()) {
  //         const userData = userDoc.data();
  //         setIsProfileComplete(userData.profileCompleted === true);
  //       } else {
  //         setIsProfileComplete(false);
  //       }
  //     } catch (error) {
  //       console.error("Error checking profile completion:", error);
  //       setIsProfileComplete(false);
  //     } finally {
  //       setLoading(false);
  //     }
  //   };
  //   
  //   checkProfileCompletion();
  // }, []);
  
  // if (loading) {
  //   return null; // Or a smaller loading indicator
  // }
  
  // COMENTADO: Verificação de ProfileIncompleteBanner desabilitada
  // if (!isProfileComplete) {
  //   // Either show a banner above limited content, or show an alternative limited view
  //   return limitedView ? (
  //     limitedView
  //   ) : (
  //     <>
  //       <ProfileIncompleteBanner />
  //       {children}
  //     </>
  //   );
  // }
  
  // Sempre permite acesso total sem restrições
  return children;
};

export default LimitedAccessWrapper;