import React, { useState } from "react";
import { CiBellOn, CiSettings, CiLogout, CiUser, CiBookmark, CiChat1 } from "react-icons/ci";

export default function Header() {
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);
  
  // Sample notifications
  const notifications = [
    { id: 1, message: "New patient registered: Milo (Golden Retriever)", time: "10 mins ago", read: false },
    { id: 2, message: "Appointment rescheduled: Luna with Dr. Johnson", time: "1 hour ago", read: false },
    { id: 3, message: "Lab results available for Charlie", time: "3 hours ago", read: true },
    { id: 4, message: "Medication reminder: Rocky needs follow-up", time: "Yesterday", read: true }
  ];
  
  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <div className="bg-white h-16 px-6 flex justify-between items-center border-b shadow-sm">
      {/* Left side - Logo */}
      <div className="flex items-center">
        <div className="text-blue-600 font-bold text-xl">VetCare</div>
        <span className="text-gray-400 ml-2">Dashboard</span>
      </div>
      
      {/* Right side - Notifications and Profile */}
      <div className="flex items-center">
        {/* Search bar */}
        <div className="mr-6 hidden md:block">
          <div className="relative">
            <input 
              type="text" 
              placeholder="Search..." 
              className="bg-gray-100 rounded-full px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 w-64"
            />
            <span className="absolute right-3 top-2.5 text-gray-400">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </span>
          </div>
        </div>
        
        {/* Notification Bell */}
        <div className="relative mr-5">
          <button 
            className="flex items-center justify-center h-10 w-10 rounded-md hover:bg-gray-100 relative"
            onClick={() => setShowNotifications(!showNotifications)}
          >
            <CiBellOn size={22} />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 bg-red-500 text-white text-xs w-4 h-4 flex items-center justify-center rounded-full">
                {unreadCount}
              </span>
            )}
          </button>
          
          {/* Notifications Dropdown */}
          {showNotifications && (
            <div className="absolute right-0 mt-2 w-80 bg-white rounded-md shadow-lg py-1 z-10 border">
              <div className="px-4 py-2 border-b flex justify-between items-center">
                <h3 className="font-medium">Notifications</h3>
                <button className="text-blue-500 text-xs">Mark all as read</button>
              </div>
              <div className="max-h-96 overflow-y-auto">
                {notifications.map(notification => (
                  <div 
                    key={notification.id} 
                    className={`px-4 py-3 border-b hover:bg-gray-50 cursor-pointer ${notification.read ? '' : 'bg-blue-50'}`}
                  >
                    <div className="flex justify-between">
                      <p className="text-sm font-medium">{notification.message}</p>
                      {!notification.read && <div className="w-2 h-2 bg-blue-500 rounded-full"></div>}
                    </div>
                    <p className="text-xs text-gray-500 mt-1">{notification.time}</p>
                  </div>
                ))}
              </div>
              <div className="px-4 py-2 text-center">
                <button className="text-blue-500 text-sm">View all notifications</button>
              </div>
            </div>
          )}
        </div>
        
        {/* Profile */}
        <div className="relative">
          <div 
            className="flex items-center cursor-pointer"
            onClick={() => setShowProfileMenu(!showProfileMenu)}
          >
            <div className="flex items-center justify-center h-10 w-10 rounded-full bg-blue-100 text-blue-600 mr-2 border-2 border-white shadow">
              <CiUser size={20} />
            </div>
            <div className="flex flex-col mr-2 hidden md:block">
              <strong className="text-sm">Dr. Sarah Wilson</strong>
              <label className="text-xs text-gray-500">Lead Veterinarian</label>
            </div>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className={`h-4 w-4 text-gray-500 transition-transform ${showProfileMenu ? 'rotate-180' : ''}`}
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </div>
          
          {/* Profile Dropdown */}
          {showProfileMenu && (
            <div className="absolute right-0 mt-2 w-56 bg-white rounded-md shadow-lg py-1 z-10 border">
              <div className="px-4 py-3 border-b">
                <p className="text-sm font-medium text-gray-900">Dr. Sarah Wilson</p>
                <p className="text-xs text-gray-500">sarah.wilson@vetcare.com</p>
              </div>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                <CiUser className="mr-2" /> My Profile
              </a>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                <CiBookmark className="mr-2" /> My Patients
              </a>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                <CiChat1 className="mr-2" /> Messages
              </a>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                <CiSettings className="mr-2" /> Settings
              </a>
              <div className="border-t my-1"></div>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-red-500 hover:bg-gray-100">
                <CiLogout className="mr-2" /> Sign out
              </a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}