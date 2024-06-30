import React, { useEffect, useState } from "react";
import { MdOutlineOpenInNew } from "react-icons/md";
import VacinaCard from "./VacinaInfo";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../config/firebase";

const accordionItems = [
  {
    title: "Section 1",
    content: "Content for section 1...",
  },
  {
    title: "Section 2",
    content: "Content for section 2...",
  },
  // Add more sections as needed
];

const employees = [
  {
    id: 1,
    firstName: "Susan",
    lastName: "Jordon",
    email: "susan@example.com",
    salary: "95000",
    date: "2019-04-11",
  },
  {
    id: 2,
    firstName: "Adrienne",
    lastName: "Doak",
    email: "adrienne@example.com",
    salary: "80000",
    date: "2019-04-17",
  },
  {
    id: 3,
    firstName: "Rolf",
    lastName: "Hegdal",
    email: "rolf@example.com",
    salary: "79000",
    date: "2019-05-01",
  },
  {
    id: 4,
    firstName: "Kent",
    lastName: "Rosner",
    email: "kent@example.com",
    salary: "56000",
    date: "2019-05-03",
  },
];

export default function VacinasTable() {
  const [selectedVaccine, setSelectedVaccine] = useState(null);
  const [isModalVisible, setIsModalVisible] = useState(false);

  //States
  const [veterinarios, setVeterinarios] = useState(null);
  const [selectedVeterinario, setselectedVeterinario] = useState(null);

  //Função de pegar os pets esperando validação
  const getPetsValidation = async () => {
    const querySnapshot = await getDocs(
      collection(db, "Veterinarios", "9X3JJmWdoERLyrV2qMQo", "Tutores"),
    );
    querySnapshot.forEach((doc) => {
      // doc.data() is never undefined for query doc snapshots
      console.log(doc.id, " => ", doc.data());
    });
    setVeterinarios(veterinarios);
  };

  useEffect(() => {
    getPetsValidation();
  }, []);
  const ModalContent = () => {
    return (
      <div className="flex overflow-auto items-center justify-center fixed inset-0 z-50 bg-black bg-opacity-50">
        <div className="bg-white rounded-lg max-w-3xl p-6 md:max-h-[98vh] relative overflow-y-auto">
          <div className="flex justify-between items-center mb-4">
            <div className="flex items-center space-x-4">
              <div>
                <img
                  src="path-to-your-image.jpg"
                  alt="Image"
                  className="w-10 h-10 rounded-full"
                />
              </div>
              <div>
                <h2 className="text-lg font-semibold">Your Name</h2>
              </div>
            </div>
            <div>
              <button
                onClick={closeModal}
                className="text-gray-600 hover:text-gray-800"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  className="w-6 h-6"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
          </div>
          <div className="flex items-center justify-between py-8 px-8">
            <h1 className="font-bold text-xl">Vacinas:</h1>
            <h1 className="font-bold text-xl">Informações:</h1>
          </div>
          <div className="">
            <VacinaCard title={"Kayque"} content={"Olá mundi"} />
          </div>
        </div>
      </div>
    );
  };

  const openModal = (employee) => {
    setSelectedVaccine(employee);
    setIsModalVisible(true);
  };

  const closeModal = () => {
    setSelectedVaccine(null);
    setIsModalVisible(false);
  };

  return (
    <div className="wt-3 pb-8 px-12 pt-8">
      <table className="table-fixed w-full h-full">
        <thead className="bg-white border-b-1 border-t-0">
          <tr>
            <th className="text-gray-500 text-sm">Nome do Pet</th>
            <th className="text-gray-500 text-sm">Vacina</th>
            <th className="text-gray-500 text-sm">Email</th>
            <th className="text-gray-500 text-sm">Data</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {employees ? (
            employees.map((employee, i) => (
              <tr
                key={employee.id}
                className="cursor-pointer"
                onClick={() => openModal(employee)}
              >
                <td className="text-slate-600">
                  <div className="flex flex-wrap items-center">
                    <div className="bg-gray-500 rounded rounded-full h-10 w-10 mr-2">
                      <img
                        className="rounded rounded-full"
                        src="https://i.pinimg.com/564x/72/f2/56/72f25653ad18c0ec71331a9f9f60d02a.jpg"
                        alt="Imagem do Usuário"
                      />
                    </div>
                    {employee.firstName}
                  </div>
                </td>
                <td className="text-slate-600">{employee.lastName}</td>
                <td className="text-slate-600">{employee.email}</td>
                <td className="text-slate-600">{employee.salary}</td>
                <td className="text-slate-600">
                  <MdOutlineOpenInNew />
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan={6}>No Employees</td>
            </tr>
          )}
        </tbody>
      </table>

      {/* Modal */}
      {/* Modal */}
      {isModalVisible && <ModalContent />}
    </div>
  );
}
