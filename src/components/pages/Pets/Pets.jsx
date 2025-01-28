/*import React from "react";

//internal components
import HeaderTitle from "../../shared/Header/components/HeaderSubtitle";
import Avatar from "../../shared/Header/components/Avatar";
import Table from "../../tables/Table";
import ValidStatusCard from "../../cards/ValidStatusCard";
import WaitingStatusCard from "../../cards/WaitingStatusCard";
import DeniedStatusCard from "../../cards/DeniedStatusCard";

//icons
import { FaSort } from "react-icons/fa";

function Pets() {

  const data = [
    {
      id: 1,
      name: "Coragem, Cão Covarde",
      vaccine: "Raiva",
      status: "valid",
      date: "16/06/24",
      avatar: "https://i.pinimg.com/236x/d8/fc/c0/d8fcc0c6b81f56c3e5c80fdaebe2ebe5.jpg",
    },
    {
      id: 2,
      name: "Scooby Doo",
      vaccine: "Polivalente",
      status: "wating",
      date: "20/06/24",
      avatar: "https://i.pinimg.com/564x/72/f2/56/72f25653ad18c0ec71331a9f9f60d02a.jpg",
    },
    {
      id: 3,
      name: "Dino",
      vaccine: "Gripe Canina",
      status: "denied",
      date: "25/06/24",
      avatar: "https://media4.giphy.com/media/3o6EhEsq0gQuOJAZtm/giphy.gif?cid=6c09b9523pi8y3vuh97mhkllvfqjee8w7tiwm9yjbxl4s9cq&ep=v1_internal_gif_by_id&rid=giphy.gif&ct=g",
    },
  ];

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
    { key: "vaccine", header: "Vacinas" },
    { key: "status", header: (
      <div className="flex items-center">
        Status
        <FaSort 
          className="ml-2" 
        />
      </div>
    ), render: (value, row) => <StatusCell status={row.status} />
  },
    { key: "date", header: "Data" },
  ];

  const StatusCell = ({ status }) => {
    switch (status) {
      case "valid":
        return <ValidStatusCard />;
      case "wating":
        return <WaitingStatusCard />;
      case "denied":
        return <DeniedStatusCard />;
      default:
        return null;
    }
  };

  return (
    <div className="flex flex-col">
      <h1 className="text-3xl	font-bold px-8">Overview</h1>
      <p className="text-[#707070] px-8">TODO: Data</p>
      <h3 className="font-semibold text-left text-[#707070] px-16 pb-16 pt-8">
      Aqui esta todos os pets os quais você ja aplicou alguma vacina. 💉
      </h3>
      <HeaderTitle>Pets</HeaderTitle>
      <div className="mt-5 flex flex-1 p-8 max-h-[80vh] overflow-auto">
        <Table columns={columns} data={data} rowKey="id" />
      </div>
    </div>
  );
}

export default Pets;
*/

import React, { useEffect, useState } from "react";
import { db } from "../../../config/firebase";
import { collection, getDocs } from "firebase/firestore";
import Table from "../../tables/Table"; // Import the Table component you provided

const FirestoreTable = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);

  // Define columns for the Table
  const columns = [
    { key: "Nome do Pet", header: "Pets" },
    { key: "field1", header: "Field 1" },
    { key: "field2", header: "Field 2" },
    { key: "field3", header: "Field 3" },
  ];

  // Fetch data from Firestore
  useEffect(() => {
    const fetchData = async () => {
      try {
        const querySnapshot = await getDocs(collection(db, "Veterinarians"));
        const items = querySnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
        setData(items);
      } catch (error) {
        console.error("Error fetching data: ", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Firestore Table</h1>
      {loading ? (
        <div className="text-center text-gray-500">Loading...</div>
      ) : data.length > 0 ? (
        <Table columns={columns} data={data} rowKey="id" />
      ) : (
        <div className="text-center text-gray-500">No data available</div>
      )}
    </div>
  );
};

export default FirestoreTable;
