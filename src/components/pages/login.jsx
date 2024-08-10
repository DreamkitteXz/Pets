import { Form } from "react-router-dom";

function Login()
{
  return(
    <div className="flex w-full h-screen">
      <div className="w-full flex items-center justify-center lg:w-1/2">
      <Form/>
      </div>
    <div className="hidden lg:flex h-full items-center justify-center "/>
    <div className="w-60 h-60 bg-gradient-to-tr from-violet-500 to-pink-500 rounded-full">

    </div>
    <div/>
    </div>
  );
}
export default Login;