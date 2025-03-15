import React, { useState } from "react";
import { DASHBOARD_SIDEBAR_BOTTOM_LINKS, DASHBOARD_SIDEBAR_LINKS } from "../../../lib/consts/navigation";
import { Link, useLocation } from "react-router-dom";
import classNames from "classnames";
import { IoIosLogOut } from "react-icons/io";

export default function SideBar() {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [hoveredItem, setHoveredItem] = useState(null);

  return (
    <div 
      className={`bg-gradient-to-b from-[#1a1a1a] to-[#252525] p-4 flex flex-col text-white transition-all duration-300 ease-in-out ${isCollapsed ? 'w-20' : 'w-64'} border-r border-neutral-800 shadow-lg overflow-y-auto`}
    >
      {/* Logo and collapse button */}
      <div className="flex items-center justify-between mb-8 px-1">
        {!isCollapsed && (
          <div className="flex items-center gap-3">
            <div className="bg-yellow-500 h-8 w-8 rounded-lg flex items-center justify-center text-black font-bold text-lg shadow-md">
              V
            </div>
            <span className="text-white text-xl font-medium">VetCare</span>
          </div>
        )}
        {isCollapsed && (
          <div className="bg-yellow-500 h-10 w-10 rounded-lg flex items-center justify-center text-black font-bold text-xl mx-auto shadow-md">
            V
          </div>
        )}
        <button 
          onClick={() => setIsCollapsed(!isCollapsed)} 
          className={`text-neutral-400 hover:text-white transition-colors ${isCollapsed ? 'mx-auto mt-4' : ''}`}
        >
          <svg xmlns="http://www.w3.org/2000/svg" className={`h-5 w-5 transition-transform duration-300 ${isCollapsed ? 'rotate-180' : ''}`} viewBox="0 0 20 20" fill="currentColor">
            <path fillRule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clipRule="evenodd" />
          </svg>
        </button>
      </div>

      {/* Navigation Links */}
      <div className="flex-1 py-2 space-y-1">
        {DASHBOARD_SIDEBAR_LINKS.map((item) => (
          <SideBarLink 
            key={item.key} 
            item={item} 
            isCollapsed={isCollapsed} 
            hoveredItem={hoveredItem}
            setHoveredItem={setHoveredItem}
          />
        ))}
      </div>

      {/* Bottom Section */}
      <div className="space-y-1 pt-4 border-t border-neutral-700">
        {DASHBOARD_SIDEBAR_BOTTOM_LINKS.map((item) => (
          <SideBarLink 
            key={item.key} 
            item={item} 
            isCollapsed={isCollapsed}
            hoveredItem={hoveredItem}
            setHoveredItem={setHoveredItem}
          />
        ))}
        
        {/* Logout Button */}
        <div 
          className={classNames(
            'flex items-center gap-3 px-3 py-3 rounded-xl cursor-pointer transition-all duration-200 text-red-400 hover:bg-red-400/10 hover:text-red-300 mt-4',
            isCollapsed ? 'justify-center' : ''
          )}
          onMouseEnter={() => setHoveredItem('logout')}
          onMouseLeave={() => setHoveredItem(null)}
        >
          <div className={classNames(
            'relative text-xl flex items-center justify-center w-8 h-8 rounded-lg',
            hoveredItem === 'logout' ? 'animate-pulse' : ''
          )}>
            <IoIosLogOut />
          </div>
          {!isCollapsed && <span>Logout</span>}
        </div>
      </div>

      {/* User Profile Section */}
      <div className="mt-auto pt-4 border-t border-neutral-700">
        <div className={classNames(
          'flex items-center gap-3 p-3 rounded-xl hover:bg-neutral-700/50 transition-all cursor-pointer',
          isCollapsed ? 'justify-center' : ''
        )}>
          <div className="bg-blue-100 text-blue-600 h-10 w-10 rounded-full flex items-center justify-center font-medium text-sm">
            SW
          </div>
          {!isCollapsed && (
            <div className="flex flex-col">
              <span className="text-sm font-medium">Dra. Sarah Wilson</span>
              <span className="text-xs text-neutral-400">Veterinária Chefe</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function SideBarLink({ item, isCollapsed, hoveredItem, setHoveredItem }) {
  const { pathname } = useLocation();
  const isActive = pathname === item.path;
  
  return (
    <Link 
      to={item.path} 
      className={classNames(
        'flex items-center gap-3 px-3 py-3 rounded-xl cursor-pointer transition-all duration-200',
        isCollapsed ? 'justify-center w-14' : '', // Added fixed width when collapsed
        isActive 
          ? 'bg-yellow-500 text-black font-medium shadow-md' 
          : 'text-neutral-400 hover:bg-neutral-700/50 hover:text-white'
      )}
      onMouseEnter={() => setHoveredItem(item.key)}
      onMouseLeave={() => setHoveredItem(null)}
    >
      <div className={classNames(
        'relative flex items-center justify-center w-8 h-8 rounded-lg text-xl flex-shrink-0', // Added flex-shrink-0
        hoveredItem === item.key && !isActive ? 'animate-bounce' : ''
      )}>
        {item.icon}
        
        {/* The notification dot for certain items */}
        {(item.key === 'patients' || item.key === 'messages') && !isActive && (
          <span className="absolute -top-1 -right-1 bg-red-500 h-2 w-2 rounded-full"></span>
        )}
      </div>
      
      {!isCollapsed && (
        <>
          <span>{item.label}</span>
          
          {/* Show badge for certain items */}
          {item.key === 'messages' && (
            <span className="ml-auto bg-blue-600 text-white text-xs px-2 py-0.5 rounded-full">3</span>
          )}
          {item.key === 'patients' && (
            <span className="ml-auto bg-green-600 text-white text-xs px-2 py-0.5 rounded-full">2</span>
          )}
        </>
      )}
    </Link>
  );
}