// Dashboard.js
import React, { useState } from "react";
import DashboardCards from "../Dashboard/components/DashboardCards";
import Avatar from "../../shared/Header/components/Avatar";
import Table from "../../tables/Table";
import HeaderSubtitle from "../../shared/Header/components/HeaderSubtitle";

function Dashboard() {
  const [selectedTitle, setSelectedTitle] = useState("Tutores");

  const columns = [
    {
      key: "name",
      header: "Nome",
      render: (value, row) => (
        <div className="flex items-center">
          <Avatar image={row.avatar} />
          {value}
        </div>
      ),
    },
    { key: "pets", header: "Pets" },
    { key: "address", header: "Endereço" },
    { key: "phone", header: "Telefone" },
  ];

  const data = Array.from({ length: 5 }).map((_, index) => ({
    id: index,
    name: "Kayque Silva Fernandes Amado",
    pets: "1",
    address: "Rua Cassiano Pinto, 183",
    phone: "(219) 555-0114",
    avatar: "https://avatars.githubusercontent.com/u/93887857?v=4",
  }));

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
      <HeaderSubtitle>
      </HeaderSubtitle>
      <div className="mt-5 flex flex-1 p-8 max-h-[80vh] overflow-auto">
        <Table columns={columns} data={data} rowKey="id" />
      </div>
    </div>
  );
}

export default Dashboard;
