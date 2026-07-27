import { useState } from "react";
import { Search, Filter, Download, MoreVertical, ShoppingCart, Users, Clock, XCircle } from "lucide-react";
import { reservedDevices, salespersons } from "../../data/mockData";

const statusStyles = {
  Active: "bg-green-100 text-green-600",
  "Expiring Soon": "bg-orange-100 text-orange-600",
  Expired: "bg-red-100 text-red-600",
};

const daysLeftStyles = {
  Active: "text-green-500",
  "Expiring Soon": "text-orange-500",
  Expired: "text-red-500",
};

function daysLeftLabel(days) {
  if (days < 0) return "Expired";
  if (days === 0) return "Today";
  return `${days} day${days === 1 ? "" : "s"} left`;
}

function Reserved() {
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [customer, setCustomer] = useState("All");
  const [salesperson, setSalesperson] = useState("All");
  const [search, setSearch] = useState("");
  const [openMenu, setOpenMenu] = useState(null);

  const records = reservedDevices;
  const customers = [...new Set(records.map((r) => r.customer))];

  const totalValue = records
    .filter((r) => r.status !== "Expired")
    .reduce((sum, r) => sum + r.totalPrice, 0);

  const stats = [
    { label: "Total Reserved Devices", unit: "Units", value: records.length, icon: ShoppingCart, bg: "bg-blue-500", text: "text-blue-600" },
    { label: "Total Reserved Value", unit: "Estimated Value", value: `₱${totalValue.toLocaleString()}`, icon: Users, bg: "bg-green-500", text: "text-green-600" },
    { label: "Expiring Soon", unit: "Reservations", value: records.filter((r) => r.status === "Expiring Soon").length, icon: Clock, bg: "bg-orange-500", text: "text-orange-600" },
    { label: "Expired Reservations", unit: "Reservations", value: records.filter((r) => r.status === "Expired").length, icon: XCircle, bg: "bg-purple-500", text: "text-purple-600" },
  ];

  return (
    <div className="space-y-4">
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <p className="text-sm font-semibold text-gray-700 mb-4">Filters</p>
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
          <div>
            <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
              Date From
            </label>
            <input
              type="date"
              value={dateFrom}
              onChange={(e) => setDateFrom(e.target.value)}
              className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
              Date To
            </label>
            <input
              type="date"
              value={dateTo}
              onChange={(e) => setDateTo(e.target.value)}
              className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
              Customer
            </label>
            <select
              value={customer}
              onChange={(e) => setCustomer(e.target.value)}
              className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="All">All Customers</option>
              {customers.map((c) => (
                <option key={c} value={c}>{c}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
              Salesperson
            </label>
            <select
              value={salesperson}
              onChange={(e) => setSalesperson(e.target.value)}
              className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="All">All Salespersons</option>
              {salespersons.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
              Search (Batch Code / Serial Number / IMEI)
            </label>
            <div className="relative">
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Type batch code, serial number, or IMEI..."
                className="w-full pl-8 pr-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
        </div>
        <div className="flex justify-end gap-3 mt-4">
          <button className="px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50">
            Clear
          </button>
          <button className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-blue-600 rounded-lg hover:bg-blue-700">
            <Filter size={14} />
            Apply Filters
          </button>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {stats.map((s, i) => {
          const Icon = s.icon;
          return (
            <div key={i} className="bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3">
              <div className={`${s.bg} w-11 h-11 rounded-full flex items-center justify-center flex-shrink-0`}>
                <Icon size={18} className="text-white" />
              </div>
              <div>
                <p className="text-xs text-gray-500 mb-0.5">{s.label}</p>
                <p className={`text-xl font-bold leading-none ${s.text}`}>{s.value}</p>
                <p className="text-xs text-gray-400 mt-0.5">{s.unit}</p>
              </div>
            </div>
          );
        })}
      </div>

      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <div className="flex items-center justify-between mb-4">
          <p className="font-medium text-gray-800">
            Reserved Devices List <span className="text-gray-400 font-normal">({records.length})</span>
          </p>
          <button className="flex items-center gap-2 text-sm text-gray-600 border border-gray-200 px-3 py-1.5 rounded-lg hover:bg-gray-50">
            <Download size={14} />
            Export
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-400 border-b border-gray-100">
                <th className="pb-2 font-medium">Reservation ID</th>
                <th className="pb-2 font-medium">Date Reserved</th>
                <th className="pb-2 font-medium">Customer</th>
                <th className="pb-2 font-medium">Salesperson</th>
                <th className="pb-2 font-medium">Device</th>
                <th className="pb-2 font-medium">Serial Number / IMEI</th>
                <th className="pb-2 font-medium">Reserved Until</th>
                <th className="pb-2 font-medium">Status</th>
                <th className="pb-2 font-medium">Total Price</th>
                <th className="pb-2 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {records.map((row, index) => (
                <tr key={index} className="border-b border-gray-50 hover:bg-gray-50">
                  <td className="py-3">
                    <span className="text-blue-600 font-medium">{row.reservationId}</span>
                  </td>
                  <td className="py-3 text-gray-500">
                    <p>{row.dateReserved}</p>
                    <p className="text-xs text-gray-400">{row.time}</p>
                  </td>
                  <td className="py-3">
                    <p className="text-gray-800">{row.customer}</p>
                    <p className="text-xs text-gray-400">{row.phone}</p>
                  </td>
                  <td className="py-3 text-gray-600">{row.salesperson}</td>
                  <td className="py-3">
                    <p className="text-gray-800 font-medium">{row.device}</p>
                    <p className="text-xs text-gray-400">{row.storage} · {row.color}</p>
                  </td>
                  <td className="py-3 text-gray-500 text-xs">{row.serial}</td>
                  <td className="py-3">
                    <p className="text-gray-600">{row.reservedUntil}</p>
                    <p className={`text-xs ${daysLeftStyles[row.status]}`}>
                      ({daysLeftLabel(row.daysLeft)})
                    </p>
                  </td>
                  <td className="py-3">
                    <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${statusStyles[row.status]}`}>
                      {row.status}
                    </span>
                  </td>
                  <td className="py-3 text-gray-700">₱{row.totalPrice.toLocaleString()}</td>
                  <td className="py-3 text-right relative">
                    <button
                      onClick={() => setOpenMenu(openMenu === index ? null : index)}
                      className="text-gray-400 hover:text-gray-700 p-1"
                    >
                      <MoreVertical size={16} />
                    </button>
                    {openMenu === index && (
                      <div className="absolute right-6 top-8 bg-white border border-gray-200 rounded-lg shadow-md z-10 w-40 text-left">
                        <button className="block w-full text-left px-3 py-2 text-sm hover:bg-gray-50">View Details</button>
                        <button className="block w-full text-left px-3 py-2 text-sm hover:bg-gray-50">Convert to Sale</button>
                        <button className="block w-full text-left px-3 py-2 text-sm text-red-500 hover:bg-gray-50">Cancel Reservation</button>
                      </div>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="flex items-center justify-between mt-4 flex-wrap gap-3">
          <p className="text-xs text-gray-500">Showing 1 to {records.length} of {records.length} records</p>
          <div className="flex items-center gap-3">
            <select className="border border-gray-200 rounded-lg text-xs px-2 py-1.5">
              <option>10 per page</option>
              <option>20 per page</option>
            </select>
            <div className="flex items-center gap-1">
              <button className="p-1.5 border border-gray-200 rounded-lg text-gray-300" disabled>‹</button>
              <button className="w-7 h-7 text-xs rounded-lg bg-blue-600 text-white">1</button>
              <button className="p-1.5 border border-gray-200 rounded-lg text-gray-300" disabled>›</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Reserved;