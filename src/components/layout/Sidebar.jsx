import { NavLink } from "react-router-dom";
import {
  LayoutDashboard,
  Package,
  ShoppingCart,
  RotateCcw,
  FileText,
  Settings,
  LogOut,
  ChevronDown,
} from "lucide-react";
import { useState } from "react";

function Sidebar() {
  const [inventoryOpen, setInventoryOpen] = useState(true);
  const [salesOpen, setSalesOpen] = useState(true);
  const [afterSalesOpen, setAfterSalesOpen] = useState(true);

  const linkClass = ({ isActive }) =>
    `flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm transition-colors ${
      isActive
        ? "bg-blue-600 text-white"
        : "text-gray-300 hover:bg-gray-800 hover:text-white"
    }`;

  const subLinkClass = ({ isActive }) =>
    `flex items-center gap-3 pl-11 pr-4 py-2 rounded-lg text-sm transition-colors ${
      isActive
        ? "bg-blue-600 text-white"
        : "text-gray-400 hover:bg-gray-800 hover:text-white"
    }`;

  return (
    <aside className="w-64 h-screen bg-[#161616] flex flex-col fixed left-0 top-0 border-r border-gray-800">
      {/* Logo */}
      <div className="px-5 py-5 border-b border-gray-800">
        <h1 className="text-white font-bold text-lg leading-tight">
          MARK GADGETS
        </h1>
        <p className="text-gray-500 text-xs">POS & INVENTORY SYSTEM</p>
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto py-4 px-3 space-y-1">
        <NavLink to="/" end className={linkClass}>
          <LayoutDashboard size={18} />
          Dashboard
        </NavLink>

        {/* Inventory group */}
        <div>
          <button
            onClick={() => setInventoryOpen(!inventoryOpen)}
            className="flex items-center justify-between w-full px-4 py-2.5 rounded-lg text-sm text-gray-300 hover:bg-gray-800 hover:text-white transition-colors"
          >
            <span className="flex items-center gap-3">
              <Package size={18} />
              Inventory
            </span>
            <ChevronDown
              size={16}
              className={`transition-transform ${
                inventoryOpen ? "rotate-180" : ""
              }`}
            />
          </button>
          {inventoryOpen && (
            <div className="mt-1 space-y-1">
              <NavLink to="/inventory/all" className={subLinkClass}>
                All Devices
              </NavLink>
              <NavLink to="/inventory/add" className={subLinkClass}>
                Add Device
              </NavLink>
              <NavLink to="/inventory/supplier-defective" className={subLinkClass}>
                Supplier Defective
              </NavLink>
              <NavLink to="/inventory/reserved" className={subLinkClass}>
                Reserved
              </NavLink>
              <NavLink to="/inventory/low-stock" className={subLinkClass}>
                Low Stock
              </NavLink>
            </div>
          )}
        </div>

        {/* Sales group */}
        <div>
          <button
            onClick={() => setSalesOpen(!salesOpen)}
            className="flex items-center justify-between w-full px-4 py-2.5 rounded-lg text-sm text-gray-300 hover:bg-gray-800 hover:text-white transition-colors"
          >
            <span className="flex items-center gap-3">
              <ShoppingCart size={18} />
              Sales
            </span>
            <ChevronDown
              size={16}
              className={`transition-transform ${
                salesOpen ? "rotate-180" : ""
              }`}
            />
          </button>
          {salesOpen && (
            <div className="mt-1 space-y-1">
              <NavLink to="/sales/new" className={subLinkClass}>
                New Sale
              </NavLink>
              <NavLink to="/sales/history" className={subLinkClass}>
                Sales History
              </NavLink>
            </div>
          )}
        </div>

        {/* After Sales group */}
        <div>
          <button
            onClick={() => setAfterSalesOpen(!afterSalesOpen)}
            className="flex items-center justify-between w-full px-4 py-2.5 rounded-lg text-sm text-gray-300 hover:bg-gray-800 hover:text-white transition-colors"
          >
            <span className="flex items-center gap-3">
              <RotateCcw size={18} />
              After Sales
            </span>
            <ChevronDown
              size={16}
              className={`transition-transform ${
                afterSalesOpen ? "rotate-180" : ""
              }`}
            />
          </button>
          {afterSalesOpen && (
            <div className="mt-1 space-y-1">
              <NavLink to="/after-sales/customer-returns" className={subLinkClass}>
                Customer Returns
              </NavLink>
              <NavLink to="/after-sales/return-history" className={subLinkClass}>
                Return History
              </NavLink>
            </div>
          )}
        </div>

        <NavLink to="/reports" className={linkClass}>
          <FileText size={18} />
          Reports
        </NavLink>
      </nav>

      {/* Bottom */}
      <div className="px-3 py-4 border-t border-gray-800 space-y-1">
        <NavLink to="/settings" className={linkClass}>
          <Settings size={18} />
          Settings
        </NavLink>
        <button className="flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm text-gray-300 hover:bg-gray-800 hover:text-white w-full transition-colors">
          <LogOut size={18} />
          Logout
        </button>
      </div>
    </aside>
  );
}

export default Sidebar;