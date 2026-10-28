import React, { useEffect, useState } from 'react';
import { ref, getBlob } from 'firebase/storage';
import { FileText, Download, ImageOff } from 'lucide-react';
import { storage } from '../../../config/firebase';

// getBlob (e não getDownloadURL): cada download passa pela storage.rules — só os
// participantes da conversa. Link público de exame seria vazamento.
// Cache da sessão: rever a conversa não baixa (nem cobra) a foto de novo.
const cache = new Map(); // path → Promise<objectURL>

function loadUrl(path) {
  if (!cache.has(path)) {
    cache.set(path, getBlob(ref(storage, path)).then((b) => URL.createObjectURL(b)).catch((err) => {
      cache.delete(path);
      throw err;
    }));
  }
  return cache.get(path);
}

const fmtSize = (n) => (n >= 1024 * 1024 ? `${(n / 1024 / 1024).toFixed(1)} MB` : `${Math.max(1, Math.round(n / 1024))} KB`);

export default function Attachment({ anexo, isMine }) {
  const isImage = anexo.contentType?.startsWith('image/');
  const [url, setUrl] = useState(null);
  const [failed, setFailed] = useState(false);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!isImage) return undefined;
    let alive = true;
    loadUrl(anexo.path).then((u) => alive && setUrl(u)).catch(() => alive && setFailed(true));
    return () => { alive = false; };
  }, [anexo.path, isImage]);

  const download = async () => {
    setBusy(true);
    try {
      const u = await loadUrl(anexo.path);
      const a = document.createElement('a');
      a.href = u;
      a.download = anexo.name || 'arquivo';
      a.click();
    } catch {
      setFailed(true);
    } finally {
      setBusy(false);
    }
  };

  if (isImage) {
    if (failed) {
      return (
        <div className="flex items-center gap-1.5 py-2" style={{ fontSize: '13px', color: isMine ? 'rgba(255,255,255,0.8)' : 'var(--text-secondary)' }}>
          <ImageOff size={14} /> Não foi possível carregar a foto
        </div>
      );
    }
    return url ? (
      <a href={url} target="_blank" rel="noopener noreferrer" aria-label={`Abrir foto ${anexo.name}`}>
        <img src={url} alt={anexo.name} className="block rounded-[12px] max-w-full" style={{ maxHeight: '260px', objectFit: 'cover' }} />
      </a>
    ) : (
      <div className="rounded-[12px] animate-pulse" style={{ width: '200px', height: '140px', background: 'rgba(116,116,128,0.18)' }} />
    );
  }

  return (
    <button type="button" onClick={download} disabled={busy}
      className="flex items-center gap-2.5 rounded-[12px] px-3 py-2.5 text-left w-full"
      style={{ background: isMine ? 'rgba(255,255,255,0.16)' : 'var(--surface-grouped-secondary)', color: isMine ? '#fff' : 'var(--text-primary)' }}>
      <FileText size={22} strokeWidth={1.5} style={{ flexShrink: 0 }} />
      <span className="min-w-0">
        <span className="block truncate font-medium" style={{ fontSize: '14px' }}>{anexo.name}</span>
        <span style={{ fontSize: '12px', opacity: 0.7 }}>{failed ? 'Falhou — toque para tentar de novo' : busy ? 'Baixando…' : `PDF · ${fmtSize(anexo.size || 0)}`}</span>
      </span>
      <Download size={16} style={{ flexShrink: 0, marginLeft: 'auto', opacity: 0.8 }} />
    </button>
  );
}
