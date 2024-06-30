import React from "react";
import { IoIosAdd } from "react-icons/io";

function AddButton() {
  return (
    <button className="flex items-center bg-gray-200 hover:bg-gray-300 p-2 rounded rounded-full ml-5 mr-5">
      <span className="mr-2">Adicionar</span>
      <IoIosAdd className="text-gray-500" />
    </button>
  );
}

export default AddButton;
