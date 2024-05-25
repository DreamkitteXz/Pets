// DaashboardCards.js
import React from "react";

function DashboardCards({ title, info, onClick }) {
  return (
    <div
      className="flex flex-col bg-gray-200 hover:bg-gray-300 cursor-pointer m-10 w-[300px] h-[200px] p-4 rounded rounded-md"
      onClick={onClick}
    >
      <h1 className="text-left">
        <b>{title}</b>
      </h1>
      <span className="flex items-center justify-center flex-grow">
        <h2 style={{ fontSize: "22px" }}>
          <b>{info}</b>
        </h2>
      </span>
    </div>
  );
}

export default DashboardCards;
