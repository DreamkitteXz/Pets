// AccordionCard.js
import React, { useState } from 'react';
import { IoIosArrowDown, IoIosArrowUp } from "react-icons/io";
import VacinaLogo from "../assets/images/vacina.svg"

export default function VacinaCard({ title, content }) {
  const [isOpen, setIsOpen] = useState(false);

  const handleToggle = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div className='flex items-start justify-between'>
      <div className='flex-vertical w-full h-full mr-3'>
        <div className="bg-[#E6E6E6] rounded-xl shadow-md mb-4 mr-6 w-full items-start">
          <div className="p-4 cursor-pointer" onClick={handleToggle}>
            {/*  TOP  */}
            <div className="flex justify-between items-center p-2">
              <div className='flex flex-row'>
                <img
                  src={VacinaLogo}
                  alt="Image"
                  className="w-30 h-30 rounded-full pr-4"
                />
                <div className='flex items-center'>
                  <h2 className="text-lg font-bold px-4">{title}</h2>

                </div>

              </div>
              <div className='flex'>
                <span className='px-4 font-bold'>Status:</span>
                <span className="text-gray-600">{isOpen ? <div className='text-xl'><IoIosArrowUp /></div> : <div className='text-xl'><IoIosArrowDown /></div>}</span>
              </div>
            </div>
          </div>
          {isOpen && (
            <div className="p-4 border-t">
              {/* CONTENT */}
              <div className='flex items-center justify-between mb-4'>
                <div className='flex flex-row'>
                  <h2 className="text-lg font-bold px-4">Dados da Vacina</h2>
                  <h2 className="text-sm text-[#656565] font-bold px-4 py-1">Data Aplicada: {content.data}</h2>
                </div>
                <h2 className="text-sm text-[#656565] font-bold px-4 py-1">Próxima Aplicação: {content.proxaplicacao}</h2>
              </div>
              <div className='flex items-start justify-between'>

                <div className='flex-vertical items-start w-full'>
                  {/* FARMACÊUTICA E LOTE */}
                  <div className='flex items-center justify-around pb-3 w-full'>
                    <div className='mr-3 bg-[#D9D9D9] rounded-xl w-full'>
                      <p className="text-base font-bold p-4">Farmacêutica:{content.farmaceutica}</p>
                    </div>
                    <div className='mr-3 bg-[#D9D9D9] rounded-xl w-full'>
                      <p className="text-base font-bold p-4">Lote:{content.lote}</p>
                    </div>
                  </div>

                  {/* PESO | DATA VALIDADE */}
                  <div className='flex items-center justify-between pb-2'>
                    <div className='mr-3 bg-[#D9D9D9] rounded-xl w-1/2'>
                      <p className="text-base font-bold p-4">Peso:{content.farmaceutica}</p>
                    </div>
                    <div className='mr-3 bg-[#D9D9D9] rounded-xl w-1/2'>
                      <p className="text-base font-bold p-4">Data de Validade:{content.lote}</p>
                    </div>
                  </div>
                  {/* Dados do Veterinario */}
                  <div className='flex items-center justify-between mb-4'>
                    <div className='py-4'>
                      <h2 className="text-lg font-bold px-4">Dados do Veterinário(a)</h2>
                    </div>
                  </div>
                  <div className='flex-initial items-center justify-between'>
                    <div className='w-full mr-3 bg-[#D9D9D9] rounded-xl w-1/2'>
                      <p className="text-base font-bold p-4">Nome:{content.farmaceutica}</p>
                    </div>
                    <div className='w-full mt-3 mr-3 bg-[#D9D9D9] rounded-xl w-1/2'>
                      <p className="text-base font-bold p-4">CRMV:{content.lote}</p>
                    </div>
                  </div>
                  {/* Dados da Clínica */}
                  <div className='flex items-center justify-between mb-4'>
                    <div className='py-4'>
                      <h2 className="text-lg font-bold px-4">Dados da Clínica</h2>
                    </div>
                  </div>
                  <div className='flex-initial items-center justify-between'>
                    <div className='w-full mr-3 bg-[#D9D9D9] rounded-xl w-1/2'>
                      <p className="text-base font-bold p-4">Clínica:{content.farmaceutica}</p>
                    </div>
                    <div className='flex items-center justify-between pb-3 mt-3'>
                      <div className='mr-3 bg-[#D9D9D9] rounded-xl w-1/2'>
                        <p className="text-base font-bold p-4">CNPJ:{content.farmaceutica}</p>
                      </div>
                      <div className='bg-[#D9D9D9] rounded-xl w-1/2'>
                        <p className="text-base font-bold p-4">Endereço:{content.lote}</p>
                      </div>
                    </div>
                  </div>
                  {/* Foto do Rótulo */}
                  <div className='flex items-center  mb-4'>
                    <div className='py-4'>
                      <h2 className="text-lg font-bold px-4">Foto do Rótulo</h2>
                    </div>
                  </div>
                  <div className='mt-3 flex items-end pb-3'>
                    <div className='justify-items-center'>
                      <img
                        src="https://images.unsplash.com/photo-1581260466152-d2c0303e54f5?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8OSUzQTE2fGVufDB8fDB8fHww"
                        alt="Image"
                        className="w-4/5 h-4/5 object-cover rounded-xl"
                      />
                    </div>
                    {/* BUTTONS */}
                    <div className='bg-[#D5F3C2] font-bold mr-3 text-[#5A9F31] rounded-2xl'>
                        <button className='p-3 px-6'>
                          Aceitar
                        </button>
                    </div>
                    <div className='bg-[#FED7D7] font-bold text-[#BE5050] rounded-2xl mr-1'>
                        <button className='p-3 px-6'>
                          Recusar
                        </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

      </div>
      <div className='bg-[#E6E6E6] rounded-xl  shadow-md flex-vertical'>
        <div className='pl-4 pr-16 py-8'>
          <img
            src={VacinaLogo}
            alt="Image"
            className="w-45 h-45 rounded-full pr-4 " />
          <div className='flex items-center justify-around py-2 px-2'>
            <span className="text-base font-bold">Nome:</span><p className='text-sm font-medium text-[#656565]'>{content.nome}Teste</p>
          </div>
          <div className='flex items-center justify-around py-2 px-2'>
            <span className="text-base font-bold">Cor:</span><p className='text-sm font-medium text-[#656565]'>{content.cor}Teste</p>
          </div>
          <div className='flex items-center justify-around py-2 px-2'>
            <span className="text-base font-bold">Raça:</span><p className='text-sm font-medium text-[#656565]'>{content.raca}Teste</p>
          </div>
          <div className='flex items-center justify-around py-2 px-2'>
            <span className="text-base font-bold">Tipo:</span><p className='text-sm font-medium text-[#656565]'>{content.tipo}Teste</p>
          </div>
          <div className='flex items-center justify-around py-2 px-2'>
            <span className="text-base font-bold">Sexo:</span><p className='text-sm font-medium text-[#656565]'>{content.sexo}Teste</p>
          </div>
          <div className='flex items-center justify-around py-2 px-2'>
            <span className="text-base font-bold">Peso:</span><p className='text-sm font-medium text-[#656565]'>{content.peso}Teste</p>
          </div>
        </div>
      </div>
    </div>
  );
};