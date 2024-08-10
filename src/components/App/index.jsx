import { BrowserRouter as Router, Route, Routes } from "react-router-dom"
import Layout from "../shared/Layout"
import Dashboard from "../pages/Dashboard"
import Pets from "../pages/Pets"
import Vacinas from "../pages/Vacinas"
import Login from "../pages/login"

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
      </Routes>
    </Router>

  )
} export default App