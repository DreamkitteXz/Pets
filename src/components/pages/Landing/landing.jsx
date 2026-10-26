import React from 'react';

import Navbar            from './Navbar';
import HeroSection       from './HeroSection';
import AboutSection      from './AboutSection';
import HowItWorksSection from './HowItWorksSection';
import FooterSection     from './FooterSection';

// No preloader: the hero's own entrance sequence is the loading moment.
const PettoHomepage = () => (
  <div className="bg-white">
    {/* Fixed navigation */}
    <Navbar />

    <main>
      {/* 1. Hero — yellow blob, Golden Retriever, letter-reveal title */}
      <HeroSection />

      {/* 2. About — Beagle blob, title, description */}
      <AboutSection />

      {/* 3. Funcionalidades — 5-step carousel */}
      <HowItWorksSection />
    </main>

    {/* Footer */}
    <FooterSection />
  </div>
);

export default PettoHomepage;
