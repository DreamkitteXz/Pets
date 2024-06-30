import React from "react";

import SearchInput from "./SearchInput";

function HeaderSubtitle({ children }) {
  return (
    <div className="flex flex-wrap items-center">
      <h1 style={{ fontSize: "22px" }}>
        <b>{children}</b>
      </h1>
      <div className="ml-auto mr-10">
        <SearchInput />
      </div>
    </div>
  );
}

export default HeaderSubtitle;
