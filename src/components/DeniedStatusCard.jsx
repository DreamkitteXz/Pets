import React from "react";

function DeniedStatusCard() {
    return(
        <div className="flex flex-nowrap justify-center items-center bg-[#FFE5E5] w-[5rem] h-[2rem] rounded-md">
            <div className="text-[#BE5050] p-2">
                <b>Negado</b>
            </div>
        </div>
    );
}

export default DeniedStatusCard;