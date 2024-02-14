import React, { useState } from "react";
import { MdOutlineOpenInNew } from "react-icons/md";
import VacinaCard from "./VacinaInfo";

const accordionItems = [
  {
    title: 'Section 1',
    content: 'Content for section 1...',
  },
  {
    title: 'Section 2',
    content: 'Content for section 2...',
  },
  // Add more sections as needed
];

const employees = [
  {
    id: 1,
    firstName: 'Susan',
    lastName: 'Jordon',
    email: 'susan@example.com',
    salary: '95000',
    date: '2019-04-11',
  },
  {
    id: 2,
    firstName: 'Adrienne',
    lastName: 'Doak',
    email: 'adrienne@example.com',
    salary: '80000',
    date: '2019-04-17',
  },
  {
    id: 3,
    firstName: 'Rolf',
    lastName: 'Hegdal',
    email: 'rolf@example.com',
    salary: '79000',
    date: '2019-05-01',
  },
  {
    id: 4,
    firstName: 'Kent',
    lastName: 'Rosner',
    email: 'kent@example.com',
    salary: '56000',
    date: '2019-05-03',
  }
];

export default function VacinasTable() {
  const [selectedVaccine, setSelectedVaccine] = useState(null);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const ModalContent = () => {
    return (
      <div className="fixed top-0 left-0 w-full h-full flex items-center justify-center bg-gray-800 bg-opacity-50">
        <div className="bg-white p-8 w-9/12 max-h-4/6 rounded-3xl shadow-lg overflow-y-auto">
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
              <button onClick={closeModal} className="text-gray-600 hover:text-gray-800">
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
          <div className="px-8">
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
      <table className="w-full">
        <thead>
          <tr>
            <th></th>
            <th className="text-sm">First Name</th>
            <th className="text-sm">Last Name</th>
            <th className="text-sm">Email</th>
            <th className="text-sm">Salary</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {employees ? (
            employees.map((employee, i) => (
              <tr key={employee.id} className="cursor-pointer" onClick={() => openModal(employee)}>
                <td>img</td>
                <td>{employee.firstName}</td>
                <td>{employee.lastName}</td>
                <td>{employee.email}</td>
                <td>{employee.salary}</td>
                <td><MdOutlineOpenInNew /></td>
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
      {isModalVisible && (<ModalContent />)}
    </div>
  );
}
