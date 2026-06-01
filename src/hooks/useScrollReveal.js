import { useEffect, useRef, useState } from 'react';

/**
 * Returns [ref, isVisible].
 * Attach ref to a DOM element; isVisible flips true once it enters the viewport.
 * The observation stops after the first trigger (elements animate once).
 */
const useScrollReveal = (threshold = 0.15) => {
  const ref = useRef(null);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
          observer.unobserve(el);
        }
      },
      { threshold }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [threshold]);

  return [ref, isVisible];
};

export default useScrollReveal;
