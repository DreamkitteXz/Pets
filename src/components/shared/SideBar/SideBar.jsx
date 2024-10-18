  import React from "react";
  import { DASHBOARD_SIDEBAR_BOTTOM_LINKS, DASHBOARD_SIDEBAR_LINKS } from "../../../lib/consts/navigation";
  import { Link, useLocation } from "react-router-dom";
  import classNames from "classnames";
  import { IoIosLogOut } from "react-icons/io";
  import { readData } from "../../../api/firebase";

  const linkClasses = 'flex items-center gap-2 font-light px-3 py-3 hover:bg-neutral-700 hover:no-underline active:bg-neutral-600 rounded-sm text-base'

  export default function SideBar() {
    return <div className="bg-[#212121] w-60 p-3 flex flex-col text-white">
      <div className="flex itens-center gap-2 px-1 py-3">
        <span className="text-neutral-100 text-2xl">Logo.</span>
        <button onClick={readData}>Ola</button>
      </div>
      <div className=" flex-1 py-6 ">
        {DASHBOARD_SIDEBAR_LINKS.map((item) => (
          <SideBarLink key={item.key} item={item}/>
        ))}
      </div>
      <div className="flex flex-col gap-0.5 pt-2 border-t border-neutral-700">{DASHBOARD_SIDEBAR_BOTTOM_LINKS.map((item) => (
        <SideBarLink key={item.key} item={item}/>
      ))}
        <div className={classNames('bg-neutral-7000', 'text-red-400 cursor-pointer', linkClasses)}>
          <span className="text-xl"><IoIosLogOut /></span>
          Logout
        </div>
      </div>
    </div>
  }
  function SideBarLink({ item }) {
    const { pathname } = useLocation()
    return (
      <Link to={item.path} className={classNames(pathname === item.path ? 'bg-contain bg-center bg-yellow-500 font-medium py-3 rounded-xl text-black' : 'bg-contain bg-center py-3 font-medium text-neutral-400 rounded-xl', linkClasses)}>
        <span className="text-xl">{item.icon}</span>
        {item.label}
      </Link>
    )
  }