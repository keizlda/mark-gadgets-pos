import { useState } from "react";
import { Search, Download, MoreVertical } from "lucide-react";
import { salesHistory } from "../../data/mockData";

const statusStyles = {
  Completed: "bg-green-100 text-green-600",
  Refunded: "bg-red-100 text-red-600",
};

function SalesHistory() {
  const [search, setSearch] = useState("");
  const [openMenu, setOpenMenu] = useState(null);

  const filtered = salesHistory.filter(
    (s) =>
      s.orderId.toLowerCase().includes(search.toLowerCase()) ||
      s.customer.toLowerCase().includes(search.toLowerCase()) ||
      s.device.toLowerCase().includes(search.toLowerCase())
  );

  const totalSales = salesHistory
    .filter((s) => s.status === "Completed")
    .reduce((sum, s) => sum + s.total, 0);

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <p className="text-xs text-gray-500">Total Sales</p>
          <p className="text-xl font-bold text-gray-800">₱{totalSales.toLocaleString()}</p>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <p className="text-xs text-gray-500">Total Orders</p>
          <p className="text-xl font-bold text-gray-800">{salesHistory.length}</p>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <p className="text-xs text-gray-500">Refunded Orders</p>
          <p className="text-xl font-bold text-red-500">
            {salesHistory.filter((s) => s.status === "Refunded").length}
          </p>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <div className="flex items-center justify-between mb-4 flex-wrap gap-3">
          <p className="font-medium text-gray-800">
            Sales History <span className="text-gray-400 font-normal">({filtered.length})</span>
          </p>
          <div className="flex gap-3">
            <div className="relative">
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search order, customer, device..."
                className="pl-8 pr-3 py-2 border border-gray-200 rounded-lg text-sm w-64 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <button className="flex items-center gap-2 text-sm text-gray-600 border border-gray-200 px-3 py-1.5 rounded-lg hover:bg-gray-50">
              <Download size={14} />
              Export
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-400 border-b border-gray-100">
                <th className="pb-2 font-medium">Order ID</th>
                <th className="pb-2 font-medium">Date</th>
                <th className="pb-2 font-medium">Customer</th>
                <th className="pb-2 font-medium">Device</th>
                <th className="pb-2 font-medium">Salesperson</th>
                <th className="pb-2 font-medium">Payment</th>
                <th className="pb-2 font-medium">Total</th>
                <th className="pb-2 font-medium">Status</th>
                <th className="pb-2 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={9} className="py-8 text-center text-gray-400">No sales found.</td>
                </tr>
              ) : (
                filtered.map((row, index) => (
                  <tr key={index} className="border-b border-gray-50 hover:bg-gray-50">
                    <td className="py-3 text-blue-600 font-medium">{row.orderId}</td>
                    <td className="py-3 text-gray-500">
                      <p>{row.date}</p>
                      <p className="text-xs text-gray-400">{row.time}</p>
                    </td>
                    <td className="py-3">
                      <p className="text-gray-800">{row.customer}</p>
                      <p className="text-xs text-gray-400">{row.phone}</p>
                    </td>
                    <td className="py-3">
                      <p className="text-gray-800 font-medium">{row.device}</p>
                      <p className="text-xs text-gray-400">{row.storage} · {row.color}</p>
                    </td>
                    <td className="py-3 text-gray-600">{row.salesperson}</td>
                    <td className="py-3 text-gray-600">{row.payment}</td>
                    <td className="py-3 text-gray-700">₱{row.total.toLocaleString()}</td>
                    <td className="py-3">
                      <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${statusStyles[row.status]}`}>
                        {row.status}
                      </span>
                    </td>
                    <td className="py-3 text-right relative">
                      <button
                        onClick={() => setOpenMenu(openMenu === index ? null : index)}
                        className="text-gray-400 hover:text-gray-700 p-1"
                      >
                        <MoreVertical size={16} />
                      </button>
                      {openMenu === index && (
                        <div className="absolute right-6 top-8 bg-white border border-gray-200 rounded-lg shadow-md z-10 w-36 text-left">
                          <button className="block w-full text-left px-3 py-2 text-sm hover:bg-gray-50">View Receipt</button>
                          <button className="block w-full text-left px-3 py-2 text-sm text-red-500 hover:bg-gray-50">Process Refund</button>
                        </div>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

export default SalesHistory;