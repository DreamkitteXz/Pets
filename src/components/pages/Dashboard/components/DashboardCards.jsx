// DaashboardCards.js
import React from "react";

function DashboardCards({ title, info, onClick, icon }) {
  return (
    <div
      className="flex flex-col bg-gray-200 hover:bg-gray-300 cursor-pointer m-5 w-full h-[150px] p-3 rounded rounded-md"
      onClick={onClick}
    >
      <h1 className="text-left">
        <b className="text-color_var">{title}</b>
      </h1>
      <span className="flex items-center justify-center flex-grow">
        <h2 style={{ fontSize: "22px" }}>
          <b>{info}</b>
        </h2>
      </span>
      <img
            className="rounded rounded-full"
            src={icon}
            alt="TODO: Icon"
            />
      </div>
  );
}

export default DashboardCards;
