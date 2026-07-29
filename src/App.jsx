import { BrowserRouter, Routes, Route, Outlet } from "react-router-dom";
import Sidebar from "./components/layout/Sidebar";
import Topbar from "./components/layout/Topbar";
import RequireAuth from "./components/auth/RequireAuth";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Inventory from "./pages/Inventory";
import Sales from "./pages/Sales";
import AfterSales from "./pages/AfterSales";
import Reports from "./pages/Reports";

function AppLayout() {
  return (
    <div className="bg-gray-50 min-h-screen">
      <div className="print:hidden">
        <Sidebar />
        <Topbar />
      </div>
      <main className="ml-64 pt-16 p-6 print:ml-0 print:pt-0 print:p-0">
        <Outlet />
      </main>
    </div>
  );
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route element={<RequireAuth><AppLayout /></RequireAuth>}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/inventory/*" element={<Inventory />} />
          <Route path="/sales/*" element={<Sales />} />
          <Route path="/after-sales/*" element={<AfterSales />} />
          <Route path="/reports" element={<Reports />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;