// Dashboard.js
import React, { useState } from "react";
import SearchInput from "../SearchInput";
import DashboardCards from "../DashboardCards";

function Dashboard() {
  const [selectedTitle, setSelectedTitle] = useState("Tutores");

  return (
    <div className="flex flex-col">
      <h1 className="text-3xl font-bold">Dashboard</h1>
      <p>TODO: Data</p>
      <div className="flex justify-center">
        <DashboardCards
          title={"Tutores"}
          info={7}
          onClick={() => setSelectedTitle("Tutores")}
        />
        <DashboardCards
          title={"Pets"}
          info={13}
          onClick={() => setSelectedTitle("Pets")}
        />
        <DashboardCards
          title={"Vacinas"}
          info={20}
          onClick={() => setSelectedTitle("Vacinas")}
        />
      </div>
      <div className="mt-2 mb-5 border border-b-4"></div>
      <div className="flex flex-wrap items-center">
        <h1 style={{ fontSize: "22px" }}>
          <b>
            {selectedTitle} #TODO: Quando mudar o titulo, as tabelas devem
            exibir tutores, vacina ou pet?
          </b>
        </h1>
        <div className="ml-auto">
          <SearchInput />
        </div>
      </div>
      <div className="mt-5 flex flex-1 max-h-[30vh] overflow-auto">
        <table className="table-fixed w-full h-full">
          <thead className="bg-white border-b-1 border-t-0">
            <tr>
              <th className="text-gray-500">Nome</th>
              <th className="text-gray-500">Pets</th>
              <th className="text-gray-500">Endereço</th>
              <th className="text-gray-500">Telefone</th>
            </tr>
          </thead>
          <tbody>
            {Array.from({ length: 20 }).map((_, index) => (
              <tr>
                <td className="text-slate-600">
                  <div className="flex flex-wrap items-center">
                    <div className="bg-gray-500 rounded rounded-full h-10 w-10 mr-2">
                      <img
                        className="rounded rounded-full"
                        src="https://avatars.githubusercontent.com/u/93887857?v=4"
                        alt="Imagem do Usuário"
                      />
                    </div>
                    Kayque Silva Fernandes Amado
                  </div>
                </td>
                <td className="text-slate-600">1</td>
                <td className="text-slate-600">Rua Cassiano Pinto, 183</td>
                <td className="text-slate-600">(219) 555-0114</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default Dashboard;
