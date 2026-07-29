import { useState, useEffect, useCallback } from "react";
import {
  Search,
  Download,
  MoreVertical,
  Filter,
  Wallet,
  CreditCard,
  TrendingUp,
  ChevronLeft,
  ChevronRight,
  PackageCheck,
} from "lucide-react";
import { downloadCsv } from "../../utils/csv";
import { useServiceData } from "../../hooks/useServiceData";
import { getSalesHistory, updateSalePaymentStatus } from "../../services/salesService";
import { getPaymentMethods } from "../../services/referenceService";
import { getDeviceById } from "../../services/inventoryService";
import InitiateReturnModal from "../../components/sales/InitiateReturnModal";
import DeviceDetailsModal from "../../components/inventory/DeviceDetailsModal";
import DateRangePicker from "../../components/common/DateRangePicker";

const csvColumns = [
  { label: "Batch Code", value: (r) => r.batchCode },
  { label: "Date", value: (r) => r.date },
  { label: "Time", value: (r) => r.time },
  { label: "Customer", value: (r) => r.customer },
  { label: "Phone", value: (r) => r.phone },
  { label: "Device", value: (r) => r.device },
  { label: "Storage", value: (r) => r.storage },
  { label: "Color", value: (r) => r.color },
  { label: "Salesperson", value: (r) => r.salesperson },
  { label: "Payment Method", value: (r) => r.payment },
  { label: "Total", value: (r) => r.total },
  { label: "Status", value: (r) => r.status },
  { label: "Order Type", value: (r) => r.orderType },
  { label: "Payment Status", value: (r) => r.paymentStatus },
];

const statusStyles = {
  Completed: "bg-green-100 text-green-600",
  Returned: "bg-purple-100 text-purple-600",
  Refunded: "bg-red-100 text-red-600",
};

const paymentStyles = {
  Cash: "bg-green-50 text-green-600",
  GCash: "bg-sky-50 text-sky-600",
  "Credit Card": "bg-blue-50 text-blue-600",
  "Bank Transfer": "bg-violet-50 text-violet-600",
  Check: "bg-amber-50 text-amber-600",
};

const paymentStatusStyles = {
  Paid: "bg-green-100 text-green-600",
  Pending: "bg-orange-100 text-orange-600",
};

function SalesHistory() {
  const [salesHistory, setSalesHistory] = useState([]);
  const loadSalesHistory = useCallback(() => {
    getSalesHistory().then(setSalesHistory);
  }, []);
  useEffect(() => {
    loadSalesHistory();
  }, [loadSalesHistory]);

  const paymentMethods = useServiceData(getPaymentMethods, []);

  const [dateRange, setDateRange] = useState();
  const [payment, setPayment] = useState("All");
  const [paymentStatus, setPaymentStatus] = useState("All");
  const [search, setSearch] = useState("");
  const [appliedSearch, setAppliedSearch] = useState("");
  const [openMenu, setOpenMenu] = useState(null);
  const [pageSize, setPageSize] = useState(10);
  const [page, setPage] = useState(1);
  const [returnRecord, setReturnRecord] = useState(null);
  const [returnStarted, setReturnStarted] = useState(false);
  const [unitInfoDevice, setUnitInfoDevice] = useState(null);
  const [markingPaidId, setMarkingPaidId] = useState(null);

  const handleMarkAsPaid = async (row) => {
    setOpenMenu(null);
    setMarkingPaidId(row.saleId);
    try {
      await updateSalePaymentStatus(row.saleId, "Paid");
      loadSalesHistory();
    } catch (err) {
      alert(err.message || "Failed to update payment status. Please try again.");
    } finally {
      setMarkingPaidId(null);
    }
  };

  const handleViewUnitInfo = async (row) => {
    setOpenMenu(null);
    try {
      const device = await getDeviceById(row.deviceId);
      setUnitInfoDevice(device);
    } catch (err) {
      alert(err.message || "Failed to load unit info. Please try again.");
    }
  };

  const filtered = salesHistory.filter((s) => {
    if (payment !== "All" && s.payment !== payment) return false;
    if (paymentStatus !== "All" && s.paymentStatus !== paymentStatus) return false;
    if (
      appliedSearch &&
      !s.batchCode.toLowerCase().includes(appliedSearch.toLowerCase()) &&
      !s.customer.toLowerCase().includes(appliedSearch.toLowerCase())
    )
      return false;
    if (dateRange?.from || dateRange?.to) {
      const saleDate = new Date(s.date);
      if (dateRange.from && saleDate < dateRange.from) return false;
      if (dateRange.to && saleDate > dateRange.to) return false;
    }
    return true;
  });

  const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));
  const paged = filtered.slice((page - 1) * pageSize, page * pageSize);

  // "Returned" still counts toward revenue — no cash refunds happen, the
  // customer just walked out with a different (replacement) unit.
  const completed = salesHistory.filter((s) => s.status !== "Refunded");
  const totalSales = completed.reduce((sum, s) => sum + s.total, 0);
  const avgSale = completed.length ? Math.round(totalSales / completed.length) : 0;

  const handleApply = () => {
    setAppliedSearch(search);
    setPage(1);
  };

  const handleClear = () => {
    setDateRange(undefined);
    setPayment("All");
    setPaymentStatus("All");
    setSearch("");
    setAppliedSearch("");
    setPage(1);
  };

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <p className="text-sm font-medium text-gray-700 mb-4">Filters</p>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Date Range</label>
            <DateRangePicker value={dateRange} onChange={setDateRange} />
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Payment Method</label>
            <select
              value={payment}
              onChange={(e) => setPayment(e.target.value)}
              className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="All">All</option>
              {paymentMethods.map((p) => (
                <option key={p} value={p}>{p}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Payment Status</label>
            <select
              value={paymentStatus}
              onChange={(e) => setPaymentStatus(e.target.value)}
              className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="All">All</option>
              <option value="Paid">Paid</option>
              <option value="Pending">Pending</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Search Batch Code / Customer</label>
            <div className="relative">
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search batch code or customer name..."
                className="w-full pl-8 pr-3 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-4">
          <button
            onClick={handleClear}
            className="px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
          >
            Clear
          </button>
          <button
            onClick={handleApply}
            className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-blue-600 rounded-lg hover:bg-blue-700"
          >
            <Filter size={14} />
            Apply Filters
          </button>
        </div>
      </div>

      {/* Summary cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3.5">
          <div className="h-11 w-11 rounded-full bg-blue-500 flex items-center justify-center shrink-0">
            <Wallet size={18} className="text-white" />
          </div>
          <div>
            <p className="text-xs text-gray-400">Total Sales</p>
            <p className="text-xl font-bold text-gray-800 leading-tight">₱{totalSales.toLocaleString()}</p>
            <p className="text-xs text-gray-400">{completed.length} Transactions</p>
          </div>
        </div>

        <div className="bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3.5">
          <div className="h-11 w-11 rounded-full bg-green-500 flex items-center justify-center shrink-0">
            <CreditCard size={18} className="text-white" />
          </div>
          <div>
            <p className="text-xs text-gray-400">Completed Orders</p>
            <p className="text-xl font-bold text-gray-800 leading-tight">{completed.length}</p>
            <p className="text-xs text-gray-400">Orders</p>
          </div>
        </div>

        <div className="bg-white rounded-xl border border-gray-200 p-4 flex items-center gap-3.5">
          <div className="h-11 w-11 rounded-full bg-orange-500 flex items-center justify-center shrink-0">
            <TrendingUp size={18} className="text-white" />
          </div>
          <div>
            <p className="text-xs text-gray-400">Average Sale</p>
            <p className="text-xl font-bold text-gray-800 leading-tight">₱{avgSale.toLocaleString()}</p>
            <p className="text-xs text-gray-400">Per Transaction</p>
          </div>
        </div>
      </div>

      {/* Transactions table */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <div className="flex items-center justify-between mb-4 flex-wrap gap-3">
          <p className="font-medium text-gray-800">Sales Transactions</p>
          <button
            onClick={() => downloadCsv("sales-history.csv", filtered, csvColumns)}
            className="flex items-center gap-2 text-sm text-gray-600 border border-gray-200 px-3 py-1.5 rounded-lg hover:bg-gray-50"
          >
            <Download size={14} />
            Export
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-400 border-b border-gray-100">
                <th className="pb-2 font-medium">Batch Code</th>
                <th className="pb-2 font-medium">Date &amp; Time</th>
                <th className="pb-2 font-medium">Customer</th>
                <th className="pb-2 font-medium">Device</th>
                <th className="pb-2 font-medium">Total Amount</th>
                <th className="pb-2 font-medium">Payment Method</th>
                <th className="pb-2 font-medium">Salesperson</th>
                <th className="pb-2 font-medium">Status</th>
                <th className="pb-2 font-medium">Payment Status</th>
                <th className="pb-2 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {paged.length === 0 ? (
                <tr>
                  <td colSpan={10} className="py-8 text-center text-gray-400">No sales found.</td>
                </tr>
              ) : (
                paged.map((row, index) => (
                  <tr key={row.batchCode} className="border-b border-gray-50 hover:bg-gray-50">
                    <td className="py-3 text-blue-600 font-medium whitespace-nowrap">{row.batchCode}</td>
                    <td className="py-3 text-gray-500 whitespace-nowrap">
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
                    <td className="py-3 text-gray-700 font-medium">₱{row.total.toLocaleString()}</td>
                    <td className="py-3">
                      <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${paymentStyles[row.payment] || "bg-gray-100 text-gray-600"}`}>
                        {row.payment}
                      </span>
                    </td>
                    <td className="py-3 text-gray-600">{row.salesperson}</td>
                    <td className="py-3">
                      <div className="flex items-center gap-1.5 flex-wrap">
                        <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${statusStyles[row.status]}`}>
                          {row.status}
                        </span>
                        {row.orderType === "Bulk" && (
                          <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-indigo-100 text-indigo-600">
                            <PackageCheck size={11} />
                            Bulk Order
                          </span>
                        )}
                      </div>
                    </td>
                    <td className="py-3">
                      <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${paymentStatusStyles[row.paymentStatus] || "bg-gray-100 text-gray-600"}`}>
                        {row.paymentStatus}
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
                        <div className="absolute right-6 top-8 bg-white border border-gray-200 rounded-lg shadow-md z-10 w-40 text-left">
                          <button
                            onClick={() => handleViewUnitInfo(row)}
                            className="block w-full text-left px-3 py-2 text-sm hover:bg-gray-50"
                          >
                            Unit Info
                          </button>
                          {row.paymentStatus === "Pending" && (
                            <button
                              onClick={() => handleMarkAsPaid(row)}
                              disabled={markingPaidId === row.saleId}
                              className="block w-full text-left px-3 py-2 text-sm text-green-600 hover:bg-gray-50 disabled:opacity-60"
                            >
                              {markingPaidId === row.saleId ? "Updating..." : "Mark as Paid"}
                            </button>
                          )}
                          {row.status === "Returned" ? (
                            <p className="px-3 py-2 text-xs text-gray-400">Already returned</p>
                          ) : (
                            <button
                              onClick={() => { setReturnRecord(row); setOpenMenu(null); }}
                              className="block w-full text-left px-3 py-2 text-sm text-red-500 hover:bg-gray-50"
                            >
                              Return
                            </button>
                          )}
                        </div>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3 pt-4 mt-2 border-t border-gray-100">
          <p className="text-xs text-gray-400">
            Showing {filtered.length === 0 ? 0 : (page - 1) * pageSize + 1} to{" "}
            {Math.min(page * pageSize, filtered.length)} of {filtered.length} transactions
          </p>
          <div className="flex items-center gap-3">
            <select
              value={pageSize}
              onChange={(e) => {
                setPageSize(Number(e.target.value));
                setPage(1);
              }}
              className="text-xs text-gray-600 border border-gray-200 rounded-lg px-2.5 py-1.5 focus:outline-none"
            >
              <option value={10}>10 per page</option>
              <option value={25}>25 per page</option>
              <option value={50}>50 per page</option>
            </select>
            <div className="flex items-center gap-1">
              <button
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page === 1}
                className="h-7 w-7 flex items-center justify-center rounded-md border border-gray-200 text-gray-400 hover:bg-gray-50 disabled:opacity-40"
              >
                <ChevronLeft size={14} />
              </button>
              {Array.from({ length: totalPages }, (_, i) => i + 1).map((p) => (
                <button
                  key={p}
                  onClick={() => setPage(p)}
                  className={`h-7 w-7 flex items-center justify-center rounded-md text-xs font-medium ${
                    page === p ? "bg-blue-600 text-white" : "text-gray-500 hover:bg-gray-50"
                  }`}
                >
                  {p}
                </button>
              ))}
              <button
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
                className="h-7 w-7 flex items-center justify-center rounded-md border border-gray-200 text-gray-400 hover:bg-gray-50 disabled:opacity-40"
              >
                <ChevronRight size={14} />
              </button>
            </div>
          </div>
        </div>
      </div>

      {returnStarted && (
        <div className="flex items-start gap-2 bg-green-50 border border-green-100 rounded-xl px-4 py-3 text-sm text-green-700">
          Return started — resolve it with a replacement unit from After Sales &gt; Customer Returns.
        </div>
      )}

      {returnRecord && (
        <InitiateReturnModal
          record={returnRecord}
          onClose={() => setReturnRecord(null)}
          onCreated={() => {
            setReturnRecord(null);
            setReturnStarted(true);
          }}
        />
      )}

      {unitInfoDevice && (
        <DeviceDetailsModal device={unitInfoDevice} onClose={() => setUnitInfoDevice(null)} />
      )}
    </div>
  );
}

export default SalesHistory;