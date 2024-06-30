import React from "react";
import VacinasTable from "../VacinasTable";
import SearchInput from "../SearchInput";
import AddButton from "../AddButton";

export default function Vacinas() {
  return (
    <div className="flex flex-col">
      <h1 className="text-3xl	font-bold px-8">Dashboard</h1>
      <p className="text-[#707070] px-8">TODO: Data</p>
      <h3 className="font-semibold text-left text-[#707070] px-16 pb-16 pt-8">
        Aqui aparecerá todas as vacinas associadas com sua aplicação, você
        precisará valida-las para que o tutor consiga emitir o certificado da
        vacina.
      </h3>
      <div className="flex flex-wrap items-center">
        <h1 style={{ fontSize: "22px" }}>
          <b>Vacinas</b>
        </h1>
        <div className="ml-auto mr-10">
          <div className="flex flex-wrap">
            <AddButton />
            <SearchInput />
          </div>
        </div>
      </div>
      <VacinasTable />
    </div>
  );
}
