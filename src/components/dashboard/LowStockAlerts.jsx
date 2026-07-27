import { AlertTriangle, ChevronRight } from "lucide-react";
import { lowStockAlerts } from "../../data/mockData";

function LowStockAlerts() {
  return (
    <div className="bg-white rounded-xl border border-gray-200 p-5">
      <div className="flex items-center gap-2 mb-4">
        <AlertTriangle size={16} className="text-red-500" />
        <p className="text-sm font-medium text-gray-700">Low Stock Alerts</p>
      </div>

      <div className="space-y-3">
        {lowStockAlerts.map((item, index) => (
          <div key={index} className="bg-red-50 rounded-lg p-3">
            <p className="text-sm font-medium text-gray-800">{item.name}</p>
            <p className="text-xs text-gray-500">{item.variant}</p>
            <p className="text-xs text-red-500 mt-1">{item.left} unit(s) left</p>
          </div>
        ))}
      </div>

      <button className="flex items-center gap-1 text-blue-600 text-sm mt-4 hover:underline">
        View all low stock items
        <ChevronRight size={14} />
      </button>
    </div>
  );
}

export default LowStockAlerts;