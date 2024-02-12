import { BrowserRouter as Router, Route, Routes } from "react-router-dom"
import Layout from "../shared/Layout"
import Dashboard from "../Dashboard"
import Pets from "../Pets"
import Vacinas from "../Vacinas"

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index={true} element={<Dashboard />} />
          <Route path="pets" element={<Pets />} />
          <Route path="vacinas" element={<Vacinas />} />
        </Route>
        <Route path="login" element={<div>this is login page</div>} />
      </Routes>
    </Router>

  )
} export default App