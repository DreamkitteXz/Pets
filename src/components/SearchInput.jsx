import React from "react";
import { IoMdSearch } from "react-icons/io";

function SearchInput() {
  return (
    <div className="relative flex items-center">
      <input
        className="bg-gray-200 p-1 pr-8 w-[100px] placeholder-black rounded rounded-md"
        type="text"
        placeholder="Search"
        style={{ color: "black" }}
      />
      <IoMdSearch className="absolute right-2 text-gray-500 pointer-events-none" />
    </div>
  );
}

export default SearchInput;
