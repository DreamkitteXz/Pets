import React, { useState } from "react";
import { CiBellOn, CiSettings, CiLogout, CiUser, CiBookmark, CiChat1 } from "react-icons/ci";
import LogoBlack from "../../../assets/logo_black";

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
    <div className="bg-white h-16 px-6 flex justify-between items-center border-b border-neutral-200 shadow-sm">
      {/* Left side - Logo */}
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2">
          <div className="flex flex-col">
            <span className="text-neutral-900 font-bold text-lg leading-none">Pets</span>
            <span className="text-neutral-500 text-xs leading-none">Sistema de Gerenciamento</span>
          </div>
        </div>
      </div>
      
      {/* Right side - Search, Notifications and Profile */}
      <div className="flex items-center gap-4">
        {/* Search bar */}
        <div className="hidden md:block">
          <div className="relative">
            <input 
              type="text" 
              placeholder="Buscar..." 
              className="bg-neutral-100 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-yellow-500 w-64 pl-10"
            />
            <span className="absolute left-3 top-2.5 text-neutral-400">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </span>
          </div>
        </div>
        
        {/* Notification Bell */}
        <div className="relative">
          <button 
            className="flex items-center justify-center h-10 w-10 rounded-xl hover:bg-neutral-100 relative transition-colors"
            onClick={() => setShowNotifications(!showNotifications)}
          >
            <CiBellOn size={24} className="text-neutral-600" />
            {unreadCount > 0 && (
              <span className="absolute top-1 right-1 bg-red-500 text-white text-xs w-5 h-5 flex items-center justify-center rounded-full border-2 border-white">
                {unreadCount}
              </span>
            )}
          </button>
          
          {/* Notifications Dropdown */}
          {showNotifications && (
            <div className="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-lg py-1 z-10 border">
              <div className="px-4 py-2 border-b flex justify-between items-center">
                <h3 className="font-medium text-neutral-900">Notificações</h3>
                <button className="text-yellow-600 text-xs hover:text-yellow-700">Marcar todas como lidas</button>
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
        <div className="relative pl-4 border-l border-neutral-200">
          <div 
            className="flex items-center cursor-pointer group"
            onClick={() => setShowProfileMenu(!showProfileMenu)}
          >
            <div className="flex items-center justify-center h-10 w-10 rounded-xl bg-yellow-100 text-yellow-600 mr-2 group-hover:bg-yellow-200 transition-colors">
              <CiUser size={24} />
            </div>
            <div className="flex flex-col mr-2 hidden md:block">
              <span className="text-sm font-medium text-neutral-900">Dra. Sarah Wilson</span>
              <span className="text-xs ml-2 text-neutral-500">Veterinária Chefe</span>
            </div>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className={`h-4 w-4 text-neutral-400 transition-transform duration-200 ${showProfileMenu ? 'rotate-180' : ''}`}
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </div>
          
          {/* Profile Dropdown */}
          {showProfileMenu && (
            <div className="absolute right-0 mt-2 w-56 bg-white rounded-xl shadow-lg py-1 z-10 border">
              <div className="px-4 py-3 border-b">
                <p className="text-sm font-medium text-neutral-900">Dra. Sarah Wilson</p>
                <p className="text-xs text-neutral-500">sarah.wilson@vetcare.com</p>
              </div>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-neutral-700 hover:bg-neutral-50">
                <CiUser className="mr-2" /> Meu Perfil
              </a>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-neutral-700 hover:bg-neutral-50">
                <CiBookmark className="mr-2" /> Meus Pacientes
              </a>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-neutral-700 hover:bg-neutral-50">
                <CiChat1 className="mr-2" /> Mensagens
              </a>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-neutral-700 hover:bg-neutral-50">
                <CiSettings className="mr-2" /> Configurações
              </a>
              <div className="border-t my-1"></div>
              <a href="#" className="flex items-center px-4 py-2 text-sm text-red-500 hover:bg-red-50">
                <CiLogout className="mr-2" /> Sair
              </a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}