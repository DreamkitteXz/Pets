// AccordionCard.js
import React, { useState } from 'react';

export default function AccordionCard({ title, content }){
  const [isOpen, setIsOpen] = useState(false);

  const handleToggle = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div className="bg-white rounded-md shadow-md overflow-hidden mb-4">
      <div className="p-4 cursor-pointer" onClick={handleToggle}>
        <div className="flex justify-between items-center">
          <h2 className="text-xl font-semibold">{title}</h2>
          <span className="text-gray-600">{isOpen ? '▲' : '▼'}</span>
        </div>
      </div>
      {isOpen && (
        <div className="p-4 border-t">
          <p className="text-gray-700">{content}</p>
        </div>
      )}
    </div>
  );
};