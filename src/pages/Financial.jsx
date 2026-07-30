import { useState, useMemo } from "react";
import { Coins, Printer, Search, PiggyBank, TrendingUp, Wallet } from "lucide-react";
import { useServiceData } from "../hooks/useServiceData";
import { getSalesHistory } from "../services/salesService";
import DateRangePicker from "../components/common/DateRangePicker";

const REPORT_TYPES = ["Daily", "Weekly", "Monthly", "Custom Range"];

const peso = (n) =>
  "₱" + n.toLocaleString("en-PH", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const toISODate = (d) => {
  const offset = d.getTimezoneOffset();
  return new Date(d.getTime() - offset * 60000).toISOString().slice(0, 10);
};

// Returns null for "Custom Range" — the user picks the dates manually in that case.
function getPresetRange(type) {
  const today = new Date();
  if (type === "Daily") {
    return { from: toISODate(today), to: toISODate(today) };
  }
  if (type === "Weekly") {
    const weekAgo = new Date(today);
    weekAgo.setDate(weekAgo.getDate() - 6);
    return { from: toISODate(weekAgo), to: toISODate(today) };
  }
  if (type === "Monthly") {
    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
    return { from: toISODate(monthStart), to: toISODate(today) };
  }
  return null;
}

function SummaryCard({ icon: Icon, iconBg, label, value, sub, valueClass }) {
  return (
    <div className="flex items-center gap-4 bg-white rounded-xl border border-gray-200 p-5">
      <div className={`h-14 w-14 rounded-full flex items-center justify-center shrink-0 ${iconBg}`}>
        <Icon size={22} />
      </div>
      <div>
        <p className="text-xs font-medium text-gray-500 tracking-wide">{label}</p>
        <p className={`text-2xl font-bold leading-tight ${valueClass}`}>{value}</p>
        <p className="text-xs text-gray-400">{sub}</p>
      </div>
    </div>
  );
}

const initialRange = getPresetRange("Monthly");

function Financial() {
  const salesHistory = useServiceData(getSalesHistory, []);

  const [reportType, setReportType] = useState("Monthly");
  const [dateFrom, setDateFrom] = useState(initialRange.from);
  const [dateTo, setDateTo] = useState(initialRange.to);
  const [generatedRange, setGeneratedRange] = useState(initialRange);

  // Only sold units have a Disposal Price/realized profit — matches how the
  // admin's own spreadsheet is structured (one row per unit actually sold).
  const rows = useMemo(() => {
    const from = generatedRange.from ? new Date(generatedRange.from + "T00:00:00") : null;
    const to = generatedRange.to ? new Date(generatedRange.to + "T00:00:00") : null;
    return salesHistory.filter((s) => {
      const saleDate = new Date(s.date);
      return (!from || saleDate >= from) && (!to || saleDate <= to);
    });
  }, [generatedRange, salesHistory]);

  const totals = useMemo(() => {
    const totalCapital = rows.reduce((sum, r) => sum + (r.purchasePrice ?? 0), 0);
    const totalDisposal = rows.reduce((sum, r) => sum + r.total, 0);
    const totalNetProfit = rows.reduce((sum, r) => sum + (r.netProfit ?? 0), 0);
    return { totalCapital, totalDisposal, totalNetProfit };
  }, [rows]);

  const handleReportTypeChange = (type) => {
    setReportType(type);
    const preset = getPresetRange(type);
    if (preset) {
      setDateFrom(preset.from);
      setDateTo(preset.to);
    }
  };

  const handleGenerate = () => {
    setGeneratedRange({ from: dateFrom, to: dateTo });
  };

  const customRange = {
    from: dateFrom ? new Date(`${dateFrom}T00:00:00`) : undefined,
    to: dateTo ? new Date(`${dateTo}T00:00:00`) : undefined,
  };

  const handleCustomRangeChange = (range) => {
    setDateFrom(range?.from ? toISODate(range.from) : "");
    setDateTo(range?.to ? toISODate(range.to) : "");
    setReportType("Custom Range");
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="space-y-4">
      {/* Print-only header */}
      <div className="hidden print:block mb-2">
        <h1 className="text-xl font-bold text-gray-900">Mark Gadgets — Financial Report</h1>
        <p className="text-sm text-gray-600">
          {reportType} · {generatedRange.from} to {generatedRange.to}
        </p>
      </div>

      {/* Header */}
      <div className="flex items-center justify-between print:hidden">
        <div className="flex items-center gap-2.5">
          <Coins size={22} className="text-gray-700" />
          <h1 className="text-xl font-bold text-gray-800">Financial</h1>
        </div>
        <button
          onClick={handlePrint}
          className="flex items-center gap-2 text-sm text-gray-700 border border-gray-200 bg-white px-4 py-2 rounded-lg hover:bg-gray-50"
        >
          <Printer size={15} />
          Print Report
        </button>
      </div>

      {/* Controls */}
      <div className="bg-white rounded-xl border border-gray-200 p-5 print:hidden">
        <div className="flex flex-wrap items-end gap-4">
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Report Type</label>
            <select
              value={reportType}
              onChange={(e) => handleReportTypeChange(e.target.value)}
              className="w-44 border border-gray-200 rounded-lg text-sm px-3 py-2.5 text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {REPORT_TYPES.map((t) => (
                <option key={t}>{t}</option>
              ))}
            </select>
          </div>

          <div className="w-64">
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Date Range</label>
            <DateRangePicker value={customRange} onChange={handleCustomRangeChange} />
          </div>

          <button
            onClick={handleGenerate}
            className="flex items-center gap-2 px-5 py-2.5 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700"
          >
            <Search size={15} />
            Generate Report
          </button>
        </div>
      </div>

      {/* Summary cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 print:hidden">
        <SummaryCard
          icon={Wallet}
          iconBg="bg-gray-100 text-gray-600"
          label="TOTAL CAPITAL"
          value={peso(totals.totalCapital)}
          sub="Total Cost of Units Sold"
          valueClass="text-gray-700"
        />
        <SummaryCard
          icon={PiggyBank}
          iconBg="bg-blue-50 text-blue-600"
          label="TOTAL DISPOSAL PRICE"
          value={peso(totals.totalDisposal)}
          sub="Total Amount Sold For"
          valueClass="text-blue-600"
        />
        <SummaryCard
          icon={TrendingUp}
          iconBg="bg-green-50 text-green-600"
          label="TOTAL NET PROFIT"
          value={peso(totals.totalNetProfit)}
          sub="Disposal Price minus Capital"
          valueClass="text-green-600"
        />
      </div>

      {/* Ledger table */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <p className="font-bold text-gray-800 mb-4">Unit Financial Ledger</p>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-500 bg-gray-50">
                <th className="px-3 py-2.5 font-medium rounded-l-lg">#</th>
                <th className="px-3 py-2.5 font-medium">Date Sold</th>
                <th className="px-3 py-2.5 font-medium">Batch Code</th>
                <th className="px-3 py-2.5 font-medium">Unit / Model / Gb / Color</th>
                <th className="px-3 py-2.5 font-medium text-right">Capital</th>
                <th className="px-3 py-2.5 font-medium text-right">Disposal Price</th>
                <th className="px-3 py-2.5 font-medium text-right">Net Profit</th>
                <th className="px-3 py-2.5 font-medium rounded-r-lg">Supplier</th>
              </tr>
            </thead>
            <tbody>
              {rows.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-8 text-center text-gray-400">
                    No sold units found for the selected date range.
                  </td>
                </tr>
              ) : (
                rows.map((row, index) => (
                  <tr key={row.saleItemId} className="border-b border-gray-50 last:border-0">
                    <td className="px-3 py-3 text-gray-500">{index + 1}</td>
                    <td className="px-3 py-3 text-gray-700 whitespace-nowrap">{row.date}</td>
                    <td className="px-3 py-3 text-gray-700 whitespace-nowrap">{row.batchCode}</td>
                    <td className="px-3 py-3 text-gray-800 font-medium">
                      {[row.device, row.storage, row.color].filter(Boolean).join(" · ")}
                    </td>
                    <td className="px-3 py-3 text-right text-gray-700">
                      {row.purchasePrice != null ? peso(row.purchasePrice) : "—"}
                    </td>
                    <td className="px-3 py-3 text-right text-gray-800">{peso(row.total)}</td>
                    <td
                      className={`px-3 py-3 text-right font-medium ${
                        row.netProfit == null ? "text-gray-400" : row.netProfit < 0 ? "text-red-500" : "text-green-600"
                      }`}
                    >
                      {row.netProfit != null ? peso(row.netProfit) : "—"}
                    </td>
                    <td className="px-3 py-3 text-gray-700 whitespace-nowrap">{row.supplier || "—"}</td>
                  </tr>
                ))
              )}
            </tbody>
            <tfoot>
              <tr className="bg-gray-50 font-bold text-gray-800">
                <td className="px-3 py-3 rounded-l-lg" colSpan={4}>TOTAL</td>
                <td className="px-3 py-3 text-right">{peso(totals.totalCapital)}</td>
                <td className="px-3 py-3 text-right">{peso(totals.totalDisposal)}</td>
                <td className="px-3 py-3 text-right text-green-600">{peso(totals.totalNetProfit)}</td>
                <td className="px-3 py-3 rounded-r-lg"></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>

      {/* Note */}
      <div className="flex items-start gap-2 bg-blue-50 border border-blue-100 rounded-xl px-4 py-3 text-sm text-blue-700 print:hidden">
        <span className="font-medium">Note:</span>
        <span>
          Capital comes from each unit's recorded purchase price — units added before that field existed show "—"
          until backfilled via Edit Device.
        </span>
      </div>
    </div>
  );
}

export default Financial;
