import React from 'react';
import { Phone, Heart, Star, PawPrint, Award } from 'lucide-react';

// Custom Paw component since Paw isn't available in lucide-react
const Paw = ({ size = 24, className = "" }) => (
  <svg 
    xmlns="http://www.w3.org/2000/svg" 
    width={size} 
    height={size} 
    viewBox="0 0 24 24" 
    fill="currentColor" 
    stroke="none" 
    className={className}
  >
    <path d="M12,5.5C10.7,5.5 9.6,6.6 9.6,8C9.6,9.4 10.7,10.5 12,10.5C13.3,10.5 14.4,9.4 14.4,8C14.4,6.6 13.3,5.5 12,5.5M12,2C10.3,2 9,3.3 9,5C9,6.7 10.3,8 12,8C13.7,8 15,6.7 15,5C15,3.3 13.7,2 12,2M18,12C16.3,12 15,13.3 15,15C15,16.7 16.3,18 18,18C19.7,18 21,16.7 21,15C21,13.3 19.7,12 18,12M18,8.5C16.7,8.5 15.6,9.6 15.6,11C15.6,12.4 16.7,13.5 18,13.5C19.3,13.5 20.4,12.4 20.4,11C20.4,9.6 19.3,8.5 18,8.5M6,12C4.3,12 3,13.3 3,15C3,16.7 4.3,18 6,18C7.7,18 9,16.7 9,15C9,13.3 7.7,12 6,12M6,8.5C4.7,8.5 3.6,9.6 3.6,11C3.6,12.4 4.7,13.5 6,13.5C7.3,13.5 8.4,12.4 8.4,11C8.4,9.6 7.3,8.5 6,8.5M12,12C9.5,12 7.5,13.9 7.5,16.3C7.5,18.7 9.5,20.6 12,20.6C14.5,20.6 16.5,18.7 16.5,16.3C16.5,13.9 14.5,12 12,12M12,15.5C10.8,15.5 9.8,16.5 9.8,17.8C9.8,19 10.8,20 12,20C13.2,20 14.2,19 14.2,17.8C14.2,16.5 13.2,15.5 12,15.5Z" />
  </svg>
);

// Custom Bone component
const Bone = ({ size = 24, className = "" }) => (
  <svg 
    xmlns="http://www.w3.org/2000/svg" 
    width={size} 
    height={size} 
    viewBox="0 0 24 24" 
    fill="currentColor" 
    stroke="none" 
    className={className}
  >
    <path d="M20.57,8.67C20.57,10.41 19.16,11.81 17.41,11.81C15.67,11.81 14.26,10.41 14.26,8.67C14.26,8.03 14.44,7.44 14.76,6.94L9.31,11.82C8.6,12.5 7.5,12.78 6.5,12.44C5.69,12.15 5.06,11.54 4.77,10.83C4.5,10.15 4.5,9.39 4.77,8.6C5.06,7.76 5.69,7.15 6.5,6.86C7.5,6.5 8.6,6.91 9.31,7.6L14.76,2.71C14.44,2.21 14.26,1.62 14.26,1C14.26,-0.74 15.67,-2.21 17.41,-2.21C19.16,-2.21 20.57,-0.74 20.57,1C20.57,2.74 19.16,4.21 17.41,4.21C16.97,4.21 16.56,4.11 16.18,3.95L10.89,8.77C11.12,9.1 11.27,9.5 11.27,9.92C11.27,10.33 11.12,10.73 10.89,11.06L16.18,15.82C16.57,15.62 16.97,15.5 17.41,15.5C19.16,15.5 20.57,16.96 20.57,18.71C20.57,20.45 19.16,21.86 17.41,21.86C15.67,21.86 14.26,20.45 14.26,18.71C14.26,18.06 14.44,17.47 14.76,16.97L9.35,12.13C8.63,11.45 7.5,11.03 6.5,11.38C5.33,11.8 4.5,12.81 4.5,14.01C4.5,15.57 5.83,16.86 7.41,16.86C8.48,16.86 9.47,16.36 10.03,15.57H10.03L15.4,20.3C15.4,20.3 15.4,20.3 15.4,20.3C15.4,20.3 15.4,20.3 15.4,20.3C15.03,20.81 14.26,21.86 14.26,21.86C12.5,21.86 11.09,20.45 11.09,18.7C11.09,16.96 12.5,15.5 14.24,15.5C14.7,15.5 15.09,15.61 15.46,15.78L20.57,11.06C20.57,11.06 20.57,11.06 20.57,11.06C20.57,11.06 20.57,11.06 20.57,11.06C20.57,11.06 20.57,8.67 20.57,8.67Z" />
  </svg>
);

const PettoHomepage = () => {
  return (
    <div className="min-h-screen bg-amber-50">
      {/* Navigation Bar */}
      <header className="container mx-auto py-4 px-6 flex justify-between items-center">
        <div className="flex items-center">
          <h1 className="text-2xl font-bold text-slate-800">Petto</h1>
          <Paw className="text-amber-500 ml-2" size={24} />
        </div>
        
        <nav className="hidden md:flex space-x-8">
          <a href="#" className="text-red-500 font-medium flex items-center">
            HOME <span className="ml-1">+</span>
          </a>
          <a href="#" className="text-gray-500 font-medium flex items-center">
            SERVICES <span className="ml-1">+</span>
          </a>
          <a href="#" className="text-gray-500 font-medium flex items-center">
            BLOG <span className="ml-1">+</span>
          </a>
          <a href="#" className="text-gray-500 font-medium flex items-center">
            SHOP <span className="ml-1">+</span>
          </a>
          <a href="#" className="text-gray-500 font-medium">
            CONTACT
          </a>
        </nav>
        
        <button className="bg-red-500 text-white px-4 py-2 rounded-md flex items-center">
          <Phone size={16} className="mr-2" />
          (480) 555-0103
        </button>
      </header>
      
      {/* Hero Section */}
      <section className="container mx-auto px-6 py-8">
        <div className="flex flex-col md:flex-row items-center">
          <div className="md:w-1/2">
            <h2 className="text-5xl font-bold text-slate-800 mb-4">
              GROOMING AND SUPPLIES
            </h2>
            <h3 className="text-4xl font-bold text-amber-500 mb-6">
              AT THE BEST RATES
            </h3>
            
            <p className="text-gray-600 mb-8">
              Little pets for a big heart. Fulfill all your pet's needs. The final stop for your pets.
              The happy store for pets. A natural treat for your pets. The pets' daycare.
            </p>
          </div>
          
          <div className="md:w-1/2 flex justify-end">
            {/* Placeholder for decorative paw prints */}
            <div className="relative">
              <div className="absolute -top-16 -left-16">
                <Paw className="text-amber-200" size={60} />
              </div>
              <div className="absolute -bottom-8 -right-12">
                <Paw className="text-amber-200" size={60} />
              </div>
            </div>
          </div>
        </div>
      </section>
      
      {/* Services Section */}
      <section className="container mx-auto px-6 py-8">
        <div className="flex flex-col md:flex-row">
          {/* Services Column */}
          <div className="md:w-1/4 space-y-8">
            <div className="flex flex-col items-center">
              <div className="bg-amber-300 w-24 h-24 rounded-full flex items-center justify-center mb-4">
                <img src="/api/placeholder/100/100" alt="Grooming" className="w-16 h-16" />
              </div>
              <h4 className="font-semibold text-slate-800">Grooming</h4>
            </div>
            
            <div className="flex flex-col items-center">
              <div className="bg-indigo-300 w-24 h-24 rounded-full flex items-center justify-center mb-4">
                <img src="/api/placeholder/100/100" alt="Hygiene Care" className="w-16 h-16" />
              </div>
              <h4 className="font-semibold text-slate-800">Hygiene Care</h4>
            </div>
            
            <div className="flex flex-col items-center">
              <div className="bg-red-300 w-24 h-24 rounded-full flex items-center justify-center mb-4">
                <img src="/api/placeholder/100/100" alt="Training Camp" className="w-16 h-16" />
              </div>
              <h4 className="font-semibold text-slate-800">Training Camp</h4>
            </div>
          </div>
          
          {/* Pet Image Column */}
          <div className="md:w-2/4 flex justify-center items-center relative py-8">
            <div className="bg-red-400 w-64 h-64 md:w-96 md:h-96 rounded-full absolute z-0"></div>
            <img 
              src="/api/placeholder/400/450" 
              alt="Golden Retriever" 
              className="relative z-10" 
            />
            <div className="absolute bottom-0 z-20">
              <img src="/api/placeholder/100/100" alt="Dog Bowl" className="w-24 h-24" />
            </div>
            {/* Decorative elements */}
            <div className="absolute top-1/4 right-1/4">
              <div className="bg-white rounded-full p-2">
                <PawPrint className="text-red-400" size={24} />
              </div>
            </div>
            <div className="absolute bottom-1/4 left-1/4">
              <Heart className="text-amber-500" size={32} />
            </div>
          </div>
          
          {/* Product Column */}
          <div className="md:w-1/4 space-y-8">
            <div className="bg-amber-100 p-6 rounded-lg">
              <div className="flex justify-center mb-4">
                <img src="/api/placeholder/150/150" alt="Dog Food" className="w-32 h-32" />
              </div>
              
              <h4 className="font-bold text-slate-800">SEANIOT | 5KG</h4>
              <p className="text-gray-600 text-sm">
                Adult chicken and egg Reg. 
                Chicken 5 kg Dry Adult Dog Food
              </p>
              
              <button className="border border-slate-800 text-slate-800 px-4 py-2 rounded mt-4 text-sm">
                Buy Now
              </button>
            </div>
            
            <div className="space-y-4">
              <div className="flex justify-center">
                <Star className="text-amber-500" size={20} fill="currentColor" />
                <Star className="text-amber-500" size={20} fill="currentColor" />
                <Star className="text-amber-500" size={20} fill="currentColor" />
                <Star className="text-amber-500" size={20} fill="currentColor" />
                <Star className="text-gray-300" size={20} />
                <span className="ml-2 text-gray-600">4.7/5</span>
              </div>
              
              <div className="bg-gray-100 p-4 rounded-lg">
                <p className="text-gray-600 text-sm italic">
                  "I highly recommend Petto! My two dogs received the care and attention they needed. They're really trustworthy."
                </p>
                
                <div className="flex items-center mt-4">
                  <div className="w-10 h-10 rounded-full bg-gray-300 overflow-hidden">
                    <img src="/api/placeholder/50/50" alt="Customer" />
                  </div>
                  <div className="ml-3">
                    <p className="font-semibold text-slate-800">ANN SMITH</p>
                    <p className="text-gray-500 text-xs">New York</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      
      {/* Decorative Elements */}
      <div className="fixed bottom-4 left-4">
        <Bone className="text-red-300" size={32} />
      </div>
      <div className="fixed top-1/4 right-4">
        <Paw className="text-amber-200" size={32} />
      </div>

      {/* Features Section */}
      <section className="container mx-auto px-6 py-16 bg-white rounded-lg shadow-lg mt-12 mb-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="text-center">
            <div className="bg-red-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <Award className="text-red-500" size={24} />
            </div>
            <h3 className="text-xl font-bold text-slate-800 mb-2">Quality Service</h3>
            <p className="text-gray-600">Professional pet care services with experienced staff</p>
          </div>

          <div className="text-center">
            <div className="bg-amber-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <Heart className="text-amber-500" size={24} />
            </div>
            <h3 className="text-xl font-bold text-slate-800 mb-2">Pet Love</h3>
            <p className="text-gray-600">Caring and loving environment for your furry friends</p>
          </div>

          <div className="text-center">
            <div className="bg-indigo-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <Phone className="text-indigo-500" size={24} />
            </div>
            <h3 className="text-xl font-bold text-slate-800 mb-2">24/7 Support</h3>
            <p className="text-gray-600">Always available for pet emergencies and inquiries</p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-800 text-white py-12">
        <div className="container mx-auto px-6">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div>
              <h4 className="text-xl font-bold mb-4">Petto</h4>
              <p className="text-gray-400">Your one-stop shop for all pet needs</p>
            </div>
            <div>
              <h4 className="text-xl font-bold mb-4">Quick Links</h4>
              <ul className="space-y-2">
                <li><a href="#" className="text-gray-400 hover:text-white">About Us</a></li>
                <li><a href="#" className="text-gray-400 hover:text-white">Services</a></li>
                <li><a href="#" className="text-gray-400 hover:text-white">Products</a></li>
                <li><a href="#" className="text-gray-400 hover:text-white">Contact</a></li>
              </ul>
            </div>
            <div>
              <h4 className="text-xl font-bold mb-4">Services</h4>
              <ul className="space-y-2">
                <li><a href="#" className="text-gray-400 hover:text-white">Pet Grooming</a></li>
                <li><a href="#" className="text-gray-400 hover:text-white">Veterinary Care</a></li>
                <li><a href="#" className="text-gray-400 hover:text-white">Pet Training</a></li>
                <li><a href="#" className="text-gray-400 hover:text-white">Pet Supplies</a></li>
              </ul>
            </div>
            <div>
              <h4 className="text-xl font-bold mb-4">Contact Us</h4>
              <ul className="space-y-2">
                <li className="text-gray-400">123 Pet Street</li>
                <li className="text-gray-400">New York, NY 10001</li>
                <li className="text-gray-400">(480) 555-0103</li>
                <li className="text-gray-400">info@petto.com</li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-700 mt-8 pt-8 text-center">
            <p className="text-gray-400">&copy; 2024 Petto. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default PettoHomepage;