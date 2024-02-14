import React from "react";
import VacinasTable from "../VacinasTable";

export default function Vacinas() {
  return (
    <div className="flex-1">
      <h1 className="text-3xl	font-bold px-8">Dashboard</h1>
      <p className="text-[#707070] px-8">TODO: Data</p>
      <h3 className="font-semibold text-left text-[#707070] px-16 pb-16 pt-8">Aqui aparecerá todas as vacinas associadas com sua aplicação, você precisará valida-las  para que o tutor
        consiga emitir o certificado da vacina.</h3>
        <div>
          <h1 className="text-2xl	font-bold px-8">Vacinas</h1>
          <VacinasTable />
        </div>
    </div>
  )
}