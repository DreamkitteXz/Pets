import React, { useEffect, useMemo, useRef } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Mapa gratuito: Leaflet + tiles do OpenStreetMap (sem chave nem cobrança).
// As coordenadas vêm de `clinic.location`, gravada pela CF geocodeClinic.
const TILE_URL = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const BRAZIL = { center: [-14.2, -51.9], zoom: 4 };

const hasPoint = (c) => Number.isFinite(c.location?.lat) && Number.isFinite(c.location?.lng);

const formatAddress = (a = {}) => [
  a.street && a.number ? `${a.street}, ${a.number}` : a.street,
  a.neighborhood,
  a.city && a.state ? `${a.city}/${a.state}` : a.city,
].filter(Boolean).join(' · ');

// Conteúdo do balão montado com textContent: nome e endereço vêm de usuários,
// nunca viram HTML.
function tooltipContent(clinic) {
  const box = document.createElement('div');
  box.className = 'clinic-tooltip';
  const add = (tag, text, cls) => {
    if (!text) return;
    const el = document.createElement(tag);
    el.textContent = text;
    if (cls) el.className = cls;
    box.appendChild(el);
  };
  add('strong', clinic.name);
  add('span', formatAddress(clinic.address));
  add('span', clinic.phone);
  if (clinic.location?.precision && clinic.location.precision !== 'endereco') {
    add('em', 'Localização aproximada');
  }
  return box;
}

export default function ClinicsMap({ clinics, highlightId }) {
  const containerRef = useRef(null);
  const mapRef = useRef(null);
  const markersRef = useRef(new Map());
  const points = useMemo(() => clinics.filter(hasPoint), [clinics]);

  useEffect(() => {
    // Tela de toque: o popup abre no primeiro evento do toque (ver abaixo) e o
    // clique que o navegador sintetiza logo depois às vezes cai no fundo do mapa
    // — com closePopupOnClick padrão, ele fecharia o popup recém-aberto.
    const touchOnly = window.matchMedia?.('(hover: none)').matches;
    const map = L.map(containerRef.current, { scrollWheelZoom: false, attributionControl: true, closePopupOnClick: !touchOnly })
      .setView(BRAZIL.center, BRAZIL.zoom);
    if (touchOnly) {
      let openedAt = 0;
      map.on('popupopen', () => { openedAt = Date.now(); });
      map.on('click', () => { if (Date.now() - openedAt > 500) map.closePopup(); });
    }
    L.tileLayer(TILE_URL, {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener noreferrer">OpenStreetMap</a>',
    }).addTo(map);
    mapRef.current = map;
    return () => { map.remove(); mapRef.current = null; };
  }, []);

  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    markersRef.current.forEach((m) => m.remove());
    markersRef.current.clear();

    // Tela de toque não tem hover: lá não há balão, só o popup, aberto já no
    // "mouseover" que o toque gera (o clique seguinte nem sempre acerta o marcador).
    const touchOnly = window.matchMedia?.('(hover: none)').matches;

    points.forEach((c) => {
      const marker = L.circleMarker([c.location.lat, c.location.lng], {
        radius: 9, color: '#ffffff', weight: 2, fillColor: '#0A84FF', fillOpacity: 1,
      })
        // Clique ou toque: o mesmo conteúdo num popup, que fica aberto.
        .bindPopup(tooltipContent(c), { closeButton: false, offset: [0, -4] })
        .addTo(map);
      if (touchOnly) {
        marker.on('mouseover', () => marker.openPopup());
      } else {
        marker.bindTooltip(tooltipContent(c), { direction: 'top', offset: [0, -8], opacity: 1 });
        marker.on('popupopen', () => marker.closeTooltip());
      }
      markersRef.current.set(c.id, marker);
    });

    if (points.length === 1) {
      map.setView([points[0].location.lat, points[0].location.lng], 15);
    } else if (points.length > 1) {
      map.fitBounds(L.latLngBounds(points.map((c) => [c.location.lat, c.location.lng])), { padding: [40, 40], maxZoom: 15 });
    } else {
      map.setView(BRAZIL.center, BRAZIL.zoom);
    }
  }, [points]);

  // Passar o mouse numa linha da lista destaca a clínica no mapa.
  useEffect(() => {
    markersRef.current.forEach((m, id) => {
      const on = id === highlightId;
      m.setStyle({ radius: on ? 12 : 9, fillColor: on ? '#FF9500' : '#0A84FF' });
      if (!m.getTooltip()) return; // tela de toque: sem balão de hover
      if (on) { m.bringToFront(); m.openTooltip(); } else m.closeTooltip();
    });
  }, [highlightId, points]);

  return (
    <div className="relative rounded-[16px] overflow-hidden"
      style={{ background: 'var(--surface-grouped-secondary)', boxShadow: '0 1px 3px rgba(0,0,0,0.06)' }}>
      <div ref={containerRef} role="region" aria-label="Mapa das clínicas" className="h-[260px] md:h-[340px] w-full" style={{ zIndex: 0 }} />
      {points.length < clinics.length && (
        <p className="px-4 py-2.5" style={{ fontSize: '12px', color: 'var(--text-tertiary)', borderTop: '1px solid var(--separator)' }}>
          {clinics.length - points.length} clínica(s) ainda sem localização no mapa — confira se o endereço está completo.
        </p>
      )}
    </div>
  );
}
