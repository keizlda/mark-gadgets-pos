import { Search, Plus, ShoppingCart, RotateCcw, FileText } from "lucide-react";
import StatCard from "../components/dashboard/StatCard";
import SalesChart from "../components/dashboard/SalesChart";
import InventoryDonut from "../components/dashboard/InventoryDonut";
import LowStockAlerts from "../components/dashboard/LowStockAlerts";
import RecentActivityTable from "../components/dashboard/RecentActivityTable";
import { statCards } from "../data/mockData";

function Dashboard() {
  return (
    <div className="space-y-6">
      {/* Search bar */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <p className="text-sm font-medium text-gray-700 mb-3">
          Search Device (Batch Code / Serial Number / IMEI)
        </p>
        <div className="relative">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Type batch code, serial number, or IMEI..."
            className="w-full pl-9 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>

      {/* Stat cards */}
      <div className="flex gap-4 flex-wrap">
        {statCards.map((card, index) => (
          <StatCard key={index} {...card} />
        ))}
      </div>

      {/* Action buttons */}
      <div className="flex gap-3">
        <button className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-blue-700">
          <Plus size={16} />
          Add Device
        </button>
        <button className="flex items-center gap-2 bg-blue-500 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-blue-600">
          <ShoppingCart size={16} />
          New Sale
        </button>
        <button className="flex items-center gap-2 bg-purple-500 text-white px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-purple-600">
          <RotateCcw size={16} />
          Customer Return
        </button>
        <button className="flex items-center gap-2 bg-white border border-gray-200 text-gray-700 px-4 py-2.5 rounded-lg text-sm font-medium hover:bg-gray-50">
          <FileText size={16} />
          View Reports
        </button>
      </div>

      {/* Charts + alerts row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <SalesChart />
        <InventoryDonut />
        <LowStockAlerts />
      </div>

      {/* Recent activity */}
      <RecentActivityTable />
    </div>
  );
}

export default Dashboard;