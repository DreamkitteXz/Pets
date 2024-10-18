import { BrowserRouter as Router, Route, Routes } from "react-router-dom"
import Layout from "../shared/Layout/Layout"
import Dashboard from "../pages/Dashboard/Dashboard"
import Pets from "../pages/Pets/Pets"
import Vacinas from "../pages/Vacinas/Vacinas"
import Login from "../pages/Auth/Login/Login"
import Register from "../pages/Auth/SignUp"

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="pets" element={<Pets />} />
          <Route path="vacinas" element={<Vacinas />} />
        </Route>
        <Route path="login" element={<Login/>} />
        <Route path="register" element={<Register/>} />
      </Routes>
    </Router>

  )
} export default App