import React from "react";
import { CiBellOn } from "react-icons/ci";

export default function Header() {
  return (
    <div className="bg-white h-16 px-4 flex justify-end items-center">
      <div className="mr-5 flex items-center">
        <button className="mr-5 flex items-center justify-center h-10 w-10 roundend rounded-md border hover:bg-gray-100">
            <CiBellOn/>
        </button>
        <div className="flex items-center">
          <div className="mr-2 flex items-center justify-center h-10 w-10 roundend rounded-full bg-gray-200">
             img
          </div>
          <div className="flex flex-col">
            <strong>Nome</strong>
            <label style={{fontSize: '10px'}}>cargo</label>
          </div>

        </div>
        </div>
    </div>
  )
}