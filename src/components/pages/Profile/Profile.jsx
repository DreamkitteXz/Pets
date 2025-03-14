import React from 'react';
import { auth } from '../../../config/firebase';

const Profile = () => {
  const user = auth.currentUser;

  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Profile</h1>
      <div className="bg-white rounded-lg shadow p-6">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Email</label>
            <p className="mt-1">{user?.email}</p>
          </div>
          {/* Add more profile fields as needed */}
        </div>
      </div>
    </div>
  );
};

export default Profile;
