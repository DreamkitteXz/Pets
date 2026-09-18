import React, { useState } from 'react';
import {
  LifeBuoy, ChevronDown, Syringe, ShieldCheck, FileText, CalendarClock,
  Mail, Send, HelpCircle,
} from 'lucide-react';

const SUPPORT_EMAIL = 'suporte@petapp.com.br';

const card = {
  background: 'var(--surface-grouped-secondary)',
  boxShadow: '0 1px 3px rgba(0,0,0,0.06)',
};

// ── FAQ ──────────────────────────────────────────────────────────────────────
const FAQS = [
  {
    q: 'Como registro uma vacina ou vermífugo?',
    a: 'Abra o paciente em "Meus Pacientes" → aba Vacinas (ou Vermifugações) → "Nova vacina/vermífugo". Registros feitos pelo veterinário já entram como aprovados, validados pelo seu CRMV.',
  },
  {
    q: 'O que significa "Pendente", "Aprovado" e "Rejeitado"?',
    a: 'Pendente aguarda a validação do veterinário; Aprovado/Rejeitado é a decisão do profissional. Após validado, o registro fica imutável — correções são feitas por um novo registro.',
  },
  {
    q: 'Como vejo o que está vencendo?',
    a: 'A tela "Vencimentos" lista vacinas e vermífugos vencidos ou a vencer (próximos 30/60/90 dias). O Dashboard também resume os alertas.',
  },
  {
    q: 'O que é a carteira de vacinação?',
    a: 'No prontuário do pet, o botão "Carteira" gera um documento com os registros aprovados (vacina, lote, datas, responsável). Use "Imprimir / Salvar PDF" para compartilhar.',
  },
  {
    q: 'O tutor também acessa o sistema?',
    a: 'Sim. O tutor tem a própria área (Início, Meus Pets, Vacinas) e pode dar ciência nos registros dos seus pets, além de conversar com o veterinário pelo Chat.',
  },
];

const FaqItem = ({ item, open, onToggle }) => (
  <div style={{ borderBottom: '1px solid var(--separator)' }}>
    <button
      onClick={onToggle}
      className="w-full flex items-center justify-between gap-3 px-5 py-4 text-left transition-colors duration-100"
      onMouseEnter={e => e.currentTarget.style.background = 'rgba(116,116,128,0.04)'}
      onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
    >
      <span className="font-medium" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>{item.q}</span>
      <ChevronDown
        size={18} strokeWidth={2}
        style={{ color: 'var(--text-tertiary)', flexShrink: 0, transform: open ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s' }}
      />
    </button>
    {open && (
      <div className="px-5 pb-4" style={{ fontSize: '14px', color: 'var(--text-secondary)', lineHeight: 1.6 }}>
        {item.a}
      </div>
    )}
  </div>
);

// ── Como usar ────────────────────────────────────────────────────────────────
const GUIDES = [
  { icon: Syringe,       title: 'Registrar aplicações', desc: 'Cadastre vacinas e vermífugos pelo prontuário do paciente, com foto do rótulo.' },
  { icon: ShieldCheck,   title: 'Validar envios',       desc: 'Aprove ou rejeite envios pendentes direto na lista de Vacinas, em 1 clique.' },
  { icon: CalendarClock, title: 'Acompanhar vencimentos', desc: 'Veja o que está vencido ou a vencer em "Vencimentos" e no Dashboard.' },
  { icon: FileText,      title: 'Emitir a carteira',    desc: 'Gere a carteira de vacinação do pet em PDF a partir do prontuário.' },
];

const Support = () => {
  const [openFaq, setOpenFaq] = useState(0);
  const [form, setForm] = useState({ nome: '', email: '', mensagem: '' });

  const set = (k) => (e) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e) => {
    e.preventDefault();
    const subject = encodeURIComponent(`Suporte — ${form.nome || 'Contato'}`);
    const body = encodeURIComponent(`${form.mensagem}\n\n— ${form.nome} (${form.email})`);
    window.location.href = `mailto:${SUPPORT_EMAIL}?subject=${subject}&body=${body}`;
  };

  const inputStyle = {
    width: '100%', background: 'var(--surface-secondary)', borderRadius: '10px',
    padding: '12px 14px', fontSize: '15px', color: 'var(--text-primary)', border: 'none', outline: 'none',
  };
  const labelStyle = { display: 'block', fontSize: '13px', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '6px' };

  return (
    <div className="min-h-full font-sf">
      {/* Header */}
      <div className="mb-6 fade-in-up">
        <div className="flex items-center gap-2">
          <LifeBuoy size={22} strokeWidth={1.75} style={{ color: 'var(--apple-blue)' }} />
          <h1 className="font-bold" style={{ fontSize: '28px', color: 'var(--text-primary)', letterSpacing: '-0.02em' }}>
            Ajuda e Suporte
          </h1>
        </div>
        <p className="mt-1" style={{ fontSize: '15px', color: 'var(--text-secondary)' }}>
          Tire dúvidas, aprenda a usar o sistema e fale com a gente.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Coluna principal: Como usar + FAQ */}
        <div className="lg:col-span-2 flex flex-col gap-5">
          {/* Como usar */}
          <div className="fade-in-up rounded-[16px] p-5" style={{ ...card, animationDelay: '50ms' }}>
            <h2 className="font-semibold mb-4" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Como usar as principais funções</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {GUIDES.map(({ icon: Icon, title, desc }) => (
                <div key={title} className="flex gap-3">
                  <div className="w-9 h-9 rounded-[10px] flex items-center justify-center flex-shrink-0" style={{ background: 'rgba(0,122,255,0.1)' }}>
                    <Icon size={18} strokeWidth={1.5} style={{ color: 'var(--apple-blue)' }} />
                  </div>
                  <div>
                    <div className="font-medium" style={{ fontSize: '14px', color: 'var(--text-primary)' }}>{title}</div>
                    <div style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>{desc}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* FAQ */}
          <div className="fade-in-up rounded-[16px] overflow-hidden" style={{ ...card, animationDelay: '100ms' }}>
            <div className="px-5 py-4 flex items-center gap-2" style={{ borderBottom: '1px solid var(--separator)' }}>
              <HelpCircle size={18} strokeWidth={1.75} style={{ color: 'var(--text-secondary)' }} />
              <h2 className="font-semibold" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Perguntas frequentes</h2>
            </div>
            {FAQS.map((item, i) => (
              <FaqItem key={i} item={item} open={openFaq === i} onToggle={() => setOpenFaq(openFaq === i ? -1 : i)} />
            ))}
          </div>
        </div>

        {/* Coluna lateral: contato */}
        <div className="flex flex-col gap-5">
          <div className="fade-in-up rounded-[16px] p-5" style={{ ...card, animationDelay: '150ms' }}>
            <h2 className="font-semibold mb-1" style={{ fontSize: '15px', color: 'var(--text-primary)' }}>Fale com o suporte</h2>
            <p className="mb-4" style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
              Respondemos em até 1 dia útil.
            </p>

            <a href={`mailto:${SUPPORT_EMAIL}`}
              className="flex items-center gap-2 mb-4 px-3 py-2.5 rounded-[10px] transition-colors duration-150"
              style={{ background: 'var(--surface-secondary)', textDecoration: 'none' }}>
              <Mail size={16} strokeWidth={1.75} style={{ color: 'var(--apple-blue)' }} />
              <span style={{ fontSize: '14px', color: 'var(--text-primary)' }}>{SUPPORT_EMAIL}</span>
            </a>

            <form onSubmit={handleSubmit} className="flex flex-col gap-3">
              <div>
                <label style={labelStyle}>Nome</label>
                <input type="text" value={form.nome} onChange={set('nome')} style={inputStyle} placeholder="Seu nome" />
              </div>
              <div>
                <label style={labelStyle}>E-mail</label>
                <input type="email" value={form.email} onChange={set('email')} style={inputStyle} placeholder="voce@email.com" />
              </div>
              <div>
                <label style={labelStyle}>Mensagem</label>
                <textarea rows={4} value={form.mensagem} onChange={set('mensagem')} style={{ ...inputStyle, resize: 'none' }} placeholder="Como podemos ajudar?" />
              </div>
              <button type="submit"
                className="flex items-center justify-center gap-2 rounded-[10px] font-medium transition-opacity duration-150"
                style={{ height: '44px', fontSize: '15px', color: '#fff', background: 'var(--apple-blue)' }}
                onMouseEnter={e => e.currentTarget.style.opacity = '0.85'}
                onMouseLeave={e => e.currentTarget.style.opacity = '1'}>
                <Send size={15} strokeWidth={2} /> Enviar mensagem
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Support;
