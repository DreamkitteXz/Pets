import { useState, useEffect } from 'react';

/** true enquanto a media query casar (reage a resize/rotação). */
export function useMediaQuery(query) {
  const get = () => typeof window !== 'undefined' && window.matchMedia(query).matches;
  const [matches, setMatches] = useState(get);

  useEffect(() => {
    const mql = window.matchMedia(query);
    const onChange = () => setMatches(mql.matches);
    onChange();
    mql.addEventListener('change', onChange);
    return () => mql.removeEventListener('change', onChange);
  }, [query]);

  return matches;
}

// Breakpoint `md` do Tailwind: a partir daqui o menu lateral fica fixo na tela.
export const DESKTOP_QUERY = '(min-width: 768px)';
