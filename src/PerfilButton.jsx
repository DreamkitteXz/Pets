import React from "react";

function PerfilButton({imgChildren}){
    return(
        <div className="flex bg-gray-500 rounded rounded-full">
            <img>
            {imgChildren}
            </img>
        </div>
    );
}

export default PerfilButton;