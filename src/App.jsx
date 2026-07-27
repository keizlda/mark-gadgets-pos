import { BrowserRouter, Routes, Route } from "react-router-dom";
import Sidebar from "./components/layout/Sidebar";
import Topbar from "./components/layout/Topbar";
import Dashboard from "./pages/Dashboard";
import Inventory from "./pages/Inventory";
import Sales from "./pages/Sales";
import Reports from "./pages/Reports";
import Settings from "./pages/Settings";

function App() {
  return (
    <BrowserRouter>
      <div className="bg-gray-50 min-h-screen">
        <Sidebar />
        <Topbar />
        <main className="ml-64 pt-16 p-6">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/inventory/*" element={<Inventory />} />
            <Route path="/sales/*" element={<Sales />} />
            <Route path="/reports" element={<Reports />} />
            <Route path="/settings" element={<Settings />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}

export default App;