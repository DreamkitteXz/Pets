import { useAuth } from '../contexts/AuthContext';

const useCurrentVetId = () => {
  const { user } = useAuth();
  // Assuming user.uid is the veterinarian id for vets
  return user ? user.uid : null;
};

export default useCurrentVetId;
