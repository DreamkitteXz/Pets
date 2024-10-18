import React from "react";
import { IoMdSearch } from "react-icons/io";

function SearchInput() {
  return (
    <div className="relative flex items-center ml-5 mr-5">
      <input
        className="bg-gray-200 p-2 pr-8 w-[100px] placeholder-black rounded rounded-full"
        type="text"
        placeholder="Search"
        style={{ color: "black" }}
      />
      <IoMdSearch className="absolute right-2 text-gray-500 pointer-events-none" />
    </div>
  );
}

export default SearchInput;
