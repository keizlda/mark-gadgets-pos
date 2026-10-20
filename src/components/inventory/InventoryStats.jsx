import { useState } from "react";
import {
  Smartphone,
  CheckCircle2,
  ShoppingBag,
  Wrench,
  RotateCcw,
  AlertTriangle,
  ChevronDown,
  Headphones,
  Cpu,
} from "lucide-react";

const BREAKDOWN_ICONS = { Devices: Smartphone, Accessories: Headphones, "Repair Parts": Cpu };

function InventoryStats({ total, available, breakdown, reserved, defective, returned, lowStock }) {
  // Which card's breakdown is open — "total", "available", or null. Only
  // the clicked card's breakdown shows, never both at once.
  const [expanded, setExpanded] = useState(null);

  // Total Devices / Available are clickable — they count devices only, and
  // open a breakdown with Accessories and Repair Parts tallied separately.
  const stats = [
    { key: "total", icon: Smartphone, label: "Total Devices", unit: "Units", value: total, bg: "bg-blue-500", text: "text-blue-600" },
    { key: "available", icon: CheckCircle2, label: "Available", unit: "Units", value: available, bg: "bg-green-500", text: "text-green-600" },
    { icon: ShoppingBag, label: "Reserved", unit: "Units", value: reserved, bg: "bg-orange-500", text: "text-orange-600" },
    { icon: Wrench, label: "Supplier Defective", unit: "Units", value: defective, bg: "bg-red-500", text: "text-red-600" },
    { icon: RotateCcw, label: "Returned", unit: "Unit", value: returned, bg: "bg-purple-500", text: "text-purple-600" },
    { icon: AlertTriangle, label: "Low Stock", unit: "Models", value: lowStock, bg: "bg-yellow-500", text: "text-yellow-600" },
  ];
  const openStat = stats.find((s) => s.key && s.key === expanded);

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
              {s.key && (
                <ChevronDown
                  size={16}
                  className={`text-gray-400 transition-transform ${expanded === s.key ? "rotate-180" : ""}`}
                />
              )}
            </>
          );
          return s.key ? (
            <button
              key={i}
              type="button"
              onClick={() => setExpanded((k) => (k === s.key ? null : s.key))}
              aria-expanded={expanded === s.key}
              className={`bg-white rounded-xl border p-4 flex items-center gap-3 hover:bg-gray-50 ${
                expanded === s.key ? "border-blue-300" : "border-gray-200"
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

      {openStat && (
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          {breakdown.map((row) => {
            const Icon = BREAKDOWN_ICONS[row.label];
            return (
              <div key={row.label} className="bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3">
                <div className={`${openStat.bg} w-11 h-11 rounded-full flex items-center justify-center flex-shrink-0`}>
                  <Icon size={18} className="text-white" />
                </div>
                <div>
                  <p className="text-xs text-gray-500 mb-0.5">
                    {row.label} · {openStat.key === "total" ? "Total" : "Available"}
                  </p>
                  <p className={`text-xl font-bold leading-none ${openStat.text}`}>
                    {openStat.key === "total" ? row.total : row.available}
                  </p>
                  <p className="text-xs text-gray-400 mt-0.5">Units</p>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

export default InventoryStats;
