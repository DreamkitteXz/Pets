import React from "react";
import LogoBlack from "../../../../assets/logos/logo_black";

function Avatar({image={}}) {
    return(
        <div className="flex items-center">
            {image ? (
                <div className="bg-gray-500 rounded rounded-full h-10 w-10 mr-2">
                    <img
                        className="rounded rounded-full"
                        src={image}
                        alt="Imagem do Usuário"
                    />
                </div>
            ) : (
                <LogoBlack className="h-10" />
            )}
        </div>
    );
}

export default Avatar;