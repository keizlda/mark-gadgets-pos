import { useState } from "react";
import { Smartphone, CheckCircle2, ShoppingBag, Wrench, RotateCcw, AlertTriangle, ChevronDown } from "lucide-react";

function InventoryStats({ total, available, breakdown, reserved, defective, returned, lowStock }) {
  const [showBreakdown, setShowBreakdown] = useState(false);

  // Total Devices / Available are clickable — they count devices only, and
  // open a breakdown with Accessories and Repair Parts tallied separately.
  const stats = [
    { icon: Smartphone, label: "Total Devices", unit: "Units", value: total, bg: "bg-blue-500", text: "text-blue-600", expandable: true },
    { icon: CheckCircle2, label: "Available", unit: "Units", value: available, bg: "bg-green-500", text: "text-green-600", expandable: true },
    { icon: ShoppingBag, label: "Reserved", unit: "Units", value: reserved, bg: "bg-orange-500", text: "text-orange-600" },
    { icon: Wrench, label: "Supplier Defective", unit: "Units", value: defective, bg: "bg-red-500", text: "text-red-600" },
    { icon: RotateCcw, label: "Returned", unit: "Unit", value: returned, bg: "bg-purple-500", text: "text-purple-600" },
    { icon: AlertTriangle, label: "Low Stock", unit: "Models", value: lowStock, bg: "bg-yellow-500", text: "text-yellow-600" },
  ];

  return (
    <div className="space-y-3">
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
        {stats.map((s, i) => {
          const Icon = s.icon;
          const content = (
            <>
              <div className={`${s.bg} w-11 h-11 rounded-full flex items-center justify-center flex-shrink-0`}>
                <Icon size={18} className="text-white" />
              </div>
              <div className="flex-1 text-left">
                <p className="text-xs text-gray-500 mb-0.5">{s.label}</p>
                <p className={`text-xl font-bold leading-none ${s.text}`}>{s.value}</p>
                <p className="text-xs text-gray-400 mt-0.5">{s.unit}</p>
              </div>
              {s.expandable && (
                <ChevronDown
                  size={16}
                  className={`text-gray-400 transition-transform ${showBreakdown ? "rotate-180" : ""}`}
                />
              )}
            </>
          );
          return s.expandable ? (
            <button
              key={i}
              type="button"
              onClick={() => setShowBreakdown((v) => !v)}
              aria-expanded={showBreakdown}
              className={`bg-white rounded-xl border p-4 flex items-center gap-3 hover:bg-gray-50 ${
                showBreakdown ? "border-blue-300" : "border-gray-200"
              }`}
            >
              {content}
            </button>
          ) : (
            <div key={i} className="bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3">
              {content}
            </div>
          );
        })}
      </div>

      {showBreakdown && (
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <table className="w-full max-w-md text-sm">
            <thead>
              <tr className="text-left text-gray-500">
                <th className="pb-2 font-medium">Category</th>
                <th className="pb-2 font-medium text-right">Total</th>
                <th className="pb-2 font-medium text-right">Available</th>
              </tr>
            </thead>
            <tbody>
              {breakdown.map((row) => (
                <tr key={row.label} className="border-t border-gray-100">
                  <td className="py-2 text-gray-800 font-medium">{row.label}</td>
                  <td className="py-2 text-right text-blue-600 font-semibold">{row.total}</td>
                  <td className="py-2 text-right text-green-600 font-semibold">{row.available}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default InventoryStats;
