import { useState, useEffect } from "react";

export default function App() {
  useEffect(() => {
    // Smooth scroll
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener("click", function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute("href"));
        if (target) {
          target.scrollIntoView({ behavior: "smooth", block: "start" });
        }
      });
    });
  }, []);

  return (
    <div className="selection:bg-blue-100">
      {/* Header */}
      <header className="fixed top-0 w-full z-50 px-6 lg:px-12 h-20 border-b border-slate-200 bg-white/90 backdrop-blur-xl">
        <div className="max-w-7xl mx-auto h-full flex items-center justify-between">
          <a href="#" className="flex items-center gap-3 group">
            <div className="size-10 bg-blue-600 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-blue-200 group-hover:shadow-xl transition-shadow">
              <span>✔</span>
            </div>
            <span className="text-xl font-bold tracking-tight text-slate-900">
              VetPortal
            </span>
          </a>

          <nav className="hidden lg:flex items-center gap-8 text-xs font-semibold uppercase tracking-wider text-slate-500">
            <a href="#dashboard" className="hover:text-blue-600 transition-colors">
              Painel
            </a>
            <a href="#seguranca" className="hover:text-blue-600 transition-colors">
              Segurança
            </a>
            <a href="#verificacao" className="hover:text-blue-600 transition-colors">
              Verificação
            </a>
            <a href="#faq" className="hover:text-blue-600 transition-colors">
              FAQ
            </a>
          </nav>

          <div className="flex items-center gap-4">
            <button className="hidden md:block bg-blue-600 text-white px-6 py-3 rounded-full text-xs font-bold uppercase tracking-wider hover:bg-blue-700 hover:shadow-xl hover:shadow-blue-200/50 transition-all active:scale-95">
              Acessar Painel
            </button>
          </div>
        </div>
      </header>

      <main className="pt-20">
        {/* HERO */}
        <section className="py-12 lg:py-20 px-6 bg-slate-50">
          <div className="max-w-7xl mx-auto grid lg:grid-cols-12 gap-8 lg:gap-12 items-center">
            <div className="lg:col-span-7 space-y-8 lg:space-y-12">
              <div className="inline-flex items-center gap-2 px-4 py-2 bg-white rounded-full border border-blue-100 shadow-sm">
                <span className="text-xs font-bold uppercase tracking-wider text-blue-700">
                  Plataforma Verificada pelo CRMV
                </span>
              </div>

              <h1 className="hero-title text-slate-900">
                Valide Vacinas
                <br />
                com <span className="text-blue-600">Autoridade</span>
                <br />
                <span className="text-slate-300">CRMV</span>
              </h1>

              <p className="text-lg lg:text-xl text-slate-600 font-medium leading-relaxed max-w-md">
                Painel seguro para veterinários licenciados revisarem, aprovarem e
                gerenciarem registros de vacinação.
              </p>

              <div className="flex flex-col sm:flex-row gap-4">
                <button className="btn-primary">Acessar Painel Vet</button>
                <button className="btn-secondary">Ver Demonstração</button>
              </div>
            </div>

            <div className="lg:col-span-5 relative">
              <div className="aspect-[3/4] rounded-[40px] overflow-hidden shadow-2xl border-8 border-white bg-white">
                <img
                  src="https://img.rocket.new/generatedImages/rocket_gen_img_10d2c8d4e-1764660353364.png"
                  className="w-full h-full object-cover"
                  alt="Preview"
                />
              </div>
            </div>
          </div>
        </section>

        {/* DASHBOARD */}
        <section id="dashboard" className="py-20 lg:py-32 bg-white">
          <div className="max-w-7xl mx-auto px-6 space-y-16">
            <div className="text-center space-y-6 max-w-3xl mx-auto">
              <h2 className="text-4xl lg:text-6xl font-bold uppercase tracking-tight leading-tight text-slate-900">
                Aprove 12 Vacinas
                <br />
                em <span className="text-blue-600">3 Minutos</span>
              </h2>
              <p className="text-lg lg:text-xl text-slate-600 font-medium">
                Interface intuitiva desenvolvida para veterinários.
              </p>
            </div>
          </div>
        </section>

        {/* SEGURANÇA */}
        <section id="seguranca" className="py-20 lg:py-32 bg-slate-50">
          <div className="max-w-7xl mx-auto px-6 space-y-16 text-center">
            <h2 className="text-4xl lg:text-6xl font-bold uppercase tracking-tight leading-tight text-slate-900">
              Dados Protegidos com
              <br />
              <span className="text-blue-600">Conformidade Total</span>
            </h2>
          </div>
        </section>

        {/* VERIFICAÇÃO */}
        <section id="verificacao" className="py-20 lg:py-32 bg-white">
          <div className="max-w-6xl mx-auto px-6 space-y-16 text-center">
            <h2 className="text-4xl lg:text-6xl font-bold uppercase tracking-tight leading-tight text-slate-900">
              3 Passos para
              <br />
              <span className="text-blue-600">Validação CRMV</span>
            </h2>
          </div>
        </section>

        {/* FAQ */}
        <section id="faq" className="py-20 lg:py-32 bg-slate-50">
          <div className="max-w-4xl mx-auto px-6 space-y-12">
            <h2 className="text-4xl lg:text-5xl font-bold uppercase tracking-tight text-center text-slate-900">
              Dúvidas sobre o <span className="text-blue-600">VetPortal</span>
            </h2>

            <FAQItem
              title="O VetPortal é reconhecido pelo CRMV?"
              content="Sim. O VetPortal é auditado e aprovado pelo CRMV-SP."
            />
            <FAQItem
              title="Como funciona a segurança dos dados?"
              content="Utilizamos criptografia AES-256 e conformidade LGPD."
            />
            <FAQItem
              title="Preciso instalar algum software?"
              content="Não. O VetPortal é 100% web."
            />
            <FAQItem
              title="Quanto tempo leva para aprovar uma vacina?"
              content="O tempo médio é de 2 minutos e 45 segundos."
            />
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="bg-slate-900 text-white py-16 px-6 border-t border-slate-800">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-8">
          <div className="flex items-center gap-3">
            <div className="size-10 bg-blue-600 rounded-2xl flex items-center justify-center">
              ✔
            </div>
            <span className="text-xl font-bold tracking-tight">VetPortal</span>
          </div>

          <div className="flex flex-wrap justify-center gap-8 text-sm font-semibold text-white/60">
            <a href="#" className="hover:text-white transition-colors">
              Privacidade
            </a>
            <a href="#" className="hover:text-white transition-colors">
              Termos de Uso
            </a>
            <a href="#" className="hover:text-white transition-colors">
              Suporte
            </a>
            <a href="#" className="hover:text-white transition-colors">
              Contato
            </a>
          </div>

          <p className="text-sm text-white/40 font-medium">
            © 2026 VetPortal. Todos os direitos reservados.
          </p>
        </div>
      </footer>
    </div>
  );
}

function FAQItem({ title, content }) {
  const [open, setOpen] = useState(false);

  return (
    <div className="border-t border-slate-200">
      <button
        onClick={() => setOpen(!open)}
        className="w-full py-6 flex items-center justify-between text-left group"
      >
        <span className="text-xl font-bold uppercase tracking-tight text-slate-900 group-hover:text-blue-600 transition-colors">
          {title}
        </span>
        <span
          className={`transition-transform duration-300 ${
            open ? "rotate-180" : ""
          }`}
        >
          ▼
        </span>
      </button>
      <div className={`${open ? "block" : "hidden"} pb-6 text-sm text-slate-600`}>
        {content}
      </div>
    </div>
  );
}
