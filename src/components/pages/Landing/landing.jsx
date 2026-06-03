import React, { useState } from 'react';

import Preloader         from './Preloader';
import Navbar            from './Navbar';
import HeroSection       from './HeroSection';
import AboutSection      from './AboutSection';
import HowItWorksSection from './HowItWorksSection';
import FooterSection     from './FooterSection';

const PettoHomepage = () => {
  const [loaded, setLoaded] = useState(false);

  return (
    <>
      {/* Preloader — shown until progress bar reaches 100% */}
      {!loaded && <Preloader onComplete={() => setLoaded(true)} />}

      {/* Main page — fades in after preloader completes */}
      <div
        className="bg-white"
        style={{
          opacity: loaded ? 1 : 0,
          transition: 'opacity 500ms ease',
          pointerEvents: loaded ? 'auto' : 'none',
        }}
      >
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
    </>
  );
};

export default PettoHomepage;
