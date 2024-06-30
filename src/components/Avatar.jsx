import React from "react";

function Avatar({image={}}) {
    return(
        <div className="bg-gray-500 rounded rounded-full h-10 w-10 mr-2">
            <img
            className="rounded rounded-full"
            src={image}
            alt="Imagem do Usuário"
            />
        </div>
    );
}

export default Avatar;