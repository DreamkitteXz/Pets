import React from "react";
import VacinasTable from "../Vacinas/VacinasTable";
import SearchInput from "../../tables/SearchInput";
import AddButton from "../../tables/AddButton";

export default function Vacinas() {
  return (
    <div className="flex flex-col">
      <h1 className="text-3xl	font-bold px-8">Vacinas</h1>
      <p className="text-[#707070] px-8">22/10/2024</p>
      <h3 className="font-semibold text-left text-[#707070] px-16 pb-8 pt-8">
        Aqui aparecerá todas as vacinas associadas com sua aplicação, você
        precisará valida-las para que o tutor consiga emitir o certificado da
        vacina.
      </h3>
      <VacinasTable />
    </div>
  );
}
