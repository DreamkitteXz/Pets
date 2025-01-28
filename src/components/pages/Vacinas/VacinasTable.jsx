import React, { useEffect, useState } from "react";
import { MdOutlineOpenInNew } from "react-icons/md";
import VacinaCard from "./VacinaInfo";
import { readData } from "../../../api/firebase";
export default function VacinasTable() {
  const [selectedVaccine, setSelectedVaccine] = useState(null);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [vacinas, setVacinas] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      const data = await readData();
      setVacinas(data);
    };
    fetchData();
  }, []);

  const openModal = (vaccine) => {
    setSelectedVaccine(vaccine);
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
            <th className="text-gray-500 text-sm">Data</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {vacinas.length > 0 ? (
            vacinas.map((vacina) => (
              <tr
                key={vacina.id}
                className="cursor-pointer"
                onClick={() => openModal(vacina)}
              >
                <td className="text-slate-600">
                  <div className="flex flex-wrap items-center">
                    <div className="bg-gray-500 rounded-full h-10 w-10 mr-2">
                      <img
                        className="rounded-full"
                        src="https://i.pinimg.com/564x/72/f2/56/72f25653ad18c0ec71331a9f9f60d02a.jpg"
                        alt="Imagem do Usuário"
                      />
                    </div>
                    {vacina.pet}
                  </div>
                </td>
                <td className="text-slate-500">{vacina.vacina}</td>
                <td className="text-slate-600">{vacina.data_aplicacao}</td>
                <td className="text-slate-600">
                  <MdOutlineOpenInNew />
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan={4}>No Vacinas</td>
            </tr>
          )}
        </tbody>
      </table>

      {isModalVisible && (
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
                  <h2 className="text-lg font-semibold">{selectedVaccine?.pet}</h2>
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
              <VacinaCard title={selectedVaccine?.pet} content={selectedVaccine} />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
