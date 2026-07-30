import { useState, useMemo, useEffect, useCallback } from "react";
import { Coins, Printer, Search, PiggyBank, TrendingUp, Wallet, Plus, Trash2, AlertTriangle, Boxes } from "lucide-react";
import { useServiceData } from "../hooks/useServiceData";
import { getSalesHistory } from "../services/salesService";
import { getAllDevices } from "../services/inventoryService";
import { getAllExpenses, addExpense, deleteExpense } from "../services/expensesService";
import DateRangePicker from "../components/common/DateRangePicker";

const REPORT_TYPES = ["Daily", "Weekly", "Monthly", "Quarterly", "Annually", "Custom Range"];

// Anything not yet Sold — capital still sitting in the business one way or
// another, whether it's sellable stock, held for a customer, or stuck in a
// defective/return pipeline.
const UNSOLD_STATUSES = ["Available", "Reserved", "Supplier Defective", "Customer Returned", "Returned"];

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
  if (type === "Quarterly") {
    const quarterStartMonth = Math.floor(today.getMonth() / 3) * 3;
    const quarterStart = new Date(today.getFullYear(), quarterStartMonth, 1);
    return { from: toISODate(quarterStart), to: toISODate(today) };
  }
  if (type === "Annually") {
    const yearStart = new Date(today.getFullYear(), 0, 1);
    return { from: toISODate(yearStart), to: toISODate(today) };
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
  const allDevices = useServiceData(getAllDevices, []);

  const [reportType, setReportType] = useState("Monthly");
  const [dateFrom, setDateFrom] = useState(initialRange.from);
  const [dateTo, setDateTo] = useState(initialRange.to);
  const [generatedRange, setGeneratedRange] = useState(initialRange);

  const [expenses, setExpenses] = useState([]);
  const loadExpenses = useCallback(() => {
    getAllExpenses().then(setExpenses);
  }, []);
  useEffect(() => {
    loadExpenses();
  }, [loadExpenses]);

  const [expenseDate, setExpenseDate] = useState(toISODate(new Date()));
  const [expenseDesc, setExpenseDesc] = useState("");
  const [expenseAmount, setExpenseAmount] = useState("");
  const [expenseError, setExpenseError] = useState("");
  const [submittingExpense, setSubmittingExpense] = useState(false);

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

  // Same expenses staff log from Reports — this is one shared table, not a
  // separate admin-only ledger, so whatever staff have entered shows up
  // here automatically and comes off the bottom line.
  const filteredExpenses = useMemo(() => {
    const from = generatedRange.from ? new Date(generatedRange.from) : null;
    const to = generatedRange.to ? new Date(generatedRange.to) : null;
    return expenses.filter((e) => {
      const d = new Date(e.date);
      return (!from || d >= from) && (!to || d <= to);
    });
  }, [expenses, generatedRange]);

  const totalExpenses = filteredExpenses.reduce((sum, e) => sum + e.amount, 0);
  const netProfitAfterExpenses = totals.totalNetProfit - totalExpenses;

  // A present-moment snapshot of stock still on hand — not scoped to the
  // selected date range, since "what's tied up in unsold inventory right
  // now" doesn't depend on which period the sales/expenses report covers.
  const unsoldUnits = useMemo(
    () => allDevices.filter((d) => UNSOLD_STATUSES.includes(d.status)),
    [allDevices]
  );
  const unsoldTotals = useMemo(() => {
    const totalCapital = unsoldUnits.reduce((sum, d) => sum + (d.purchasePrice ?? 0), 0);
    return { count: unsoldUnits.length, totalCapital };
  }, [unsoldUnits]);

  const handleAddExpense = async (e) => {
    e.preventDefault();
    if (!expenseDesc.trim() || !expenseAmount) return;
    setExpenseError("");
    setSubmittingExpense(true);
    try {
      await addExpense({
        date: expenseDate,
        description: expenseDesc.trim(),
        amount: Number(expenseAmount),
        adminOnly: true,
      });
      setExpenseDesc("");
      setExpenseAmount("");
      loadExpenses();
    } catch (err) {
      setExpenseError(err.message || "Failed to add expense. Please try again.");
    } finally {
      setSubmittingExpense(false);
    }
  };

  const handleRemoveExpense = async (id) => {
    try {
      await deleteExpense(id);
      loadExpenses();
    } catch (err) {
      alert(err.message || "Failed to remove expense. Please try again.");
    }
  };

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

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 print:hidden">
        <SummaryCard
          icon={Wallet}
          iconBg="bg-red-50 text-red-500"
          label="TOTAL EXPENSES"
          value={peso(totalExpenses)}
          sub="Logged for this period"
          valueClass="text-red-500"
        />
        <SummaryCard
          icon={Coins}
          iconBg={netProfitAfterExpenses < 0 ? "bg-red-50 text-red-500" : "bg-green-50 text-green-600"}
          label="NET PROFIT AFTER EXPENSES"
          value={peso(netProfitAfterExpenses)}
          sub="Net Profit minus Expenses"
          valueClass={netProfitAfterExpenses < 0 ? "text-red-500" : "text-green-600"}
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

      {/* Inventory On Hand — a snapshot of what's still unsold right now,
          independent of the date range above. Only meaningful for the
          longer-horizon report types, not a single day/week/month. */}
      {(reportType === "Quarterly" || reportType === "Annually") && (
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <p className="font-bold text-gray-800 mb-1">Inventory On Hand (Unsold Units)</p>
          <p className="text-xs text-gray-400 mb-4">
            Current snapshot — every unit not yet Sold, regardless of the date range above.
          </p>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <SummaryCard
              icon={Boxes}
              iconBg="bg-purple-50 text-purple-600"
              label="UNITS IN STOCK"
              value={unsoldTotals.count}
              sub="Not yet Sold"
              valueClass="text-purple-600"
            />
            <SummaryCard
              icon={Wallet}
              iconBg="bg-gray-100 text-gray-600"
              label="CAPITAL TIED UP"
              value={peso(unsoldTotals.totalCapital)}
              sub="Cost basis of unsold stock"
              valueClass="text-gray-700"
            />
          </div>
        </div>
      )}

      {/* Expenses — includes both what staff logged on Reports and what's
          logged here; entries added from this page are marked Admin Only
          and stay hidden from Reports. */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <p className="font-bold text-gray-800 mb-4">Expenses</p>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-500 bg-gray-50">
                <th className="px-3 py-2.5 font-medium rounded-l-lg">Date</th>
                <th className="px-3 py-2.5 font-medium">Description</th>
                <th className="px-3 py-2.5 font-medium text-right">Amount</th>
                <th className="px-3 py-2.5 font-medium rounded-r-lg text-right print:hidden">Remove</th>
              </tr>
            </thead>
            <tbody>
              {filteredExpenses.length === 0 ? (
                <tr>
                  <td colSpan={4} className="py-6 text-center text-gray-400">
                    No expenses recorded for this period.
                  </td>
                </tr>
              ) : filteredExpenses.map((e) => (
                <tr key={e.id} className="border-b border-gray-50 last:border-0">
                  <td className="px-3 py-3 text-gray-700 whitespace-nowrap">{e.date}</td>
                  <td className="px-3 py-3 text-gray-700">
                    {e.description}
                    {e.adminOnly && (
                      <span className="ml-2 px-1.5 py-0.5 rounded text-[10px] font-medium bg-gray-100 text-gray-500 align-middle">
                        Admin Only
                      </span>
                    )}
                  </td>
                  <td className="px-3 py-3 text-red-500 text-right">-{peso(e.amount)}</td>
                  <td className="px-3 py-3 text-right print:hidden">
                    <button
                      onClick={() => handleRemoveExpense(e.id)}
                      className="text-gray-400 hover:text-red-500 p-1"
                    >
                      <Trash2 size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr className="bg-gray-50 font-bold text-gray-800">
                <td className="px-3 py-3 rounded-l-lg" colSpan={2}>TOTAL EXPENSES</td>
                <td className="px-3 py-3 text-right text-red-500">-{peso(totalExpenses)}</td>
                <td className="px-3 py-3 rounded-r-lg"></td>
              </tr>
            </tfoot>
          </table>
        </div>

        {expenseError && (
          <div className="flex items-start gap-2 bg-red-50 border border-red-100 rounded-lg px-3 py-2 mt-4 print:hidden">
            <AlertTriangle size={15} className="text-red-500 mt-0.5 flex-shrink-0" />
            <p className="text-sm text-red-700">{expenseError}</p>
          </div>
        )}

        <form onSubmit={handleAddExpense} className="flex flex-wrap items-end gap-3 mt-4 print:hidden">
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Date</label>
            <input
              type="date"
              value={expenseDate}
              onChange={(e) => setExpenseDate(e.target.value)}
              className="w-40 border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div className="flex-1 min-w-[180px]">
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Description</label>
            <input
              type="text"
              value={expenseDesc}
              onChange={(e) => setExpenseDesc(e.target.value)}
              placeholder="e.g. Electricity bill"
              className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Amount</label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">₱</span>
              <input
                type="number"
                value={expenseAmount}
                onChange={(e) => setExpenseAmount(e.target.value)}
                placeholder="0.00"
                className="w-32 border border-gray-200 rounded-lg text-sm pl-7 pr-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
          <button
            type="submit"
            disabled={submittingExpense}
            className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 disabled:opacity-60"
          >
            <Plus size={14} />
            {submittingExpense ? "Adding..." : "Add Expense"}
          </button>
        </form>

        <div className="mt-6 pt-4 border-t border-gray-100 space-y-1.5 text-right">
          <div className="flex justify-end gap-6 text-sm text-gray-600">
            <span>Total Net Profit</span>
            <span className="w-32">{peso(totals.totalNetProfit)}</span>
          </div>

          {/* Each expense broken out, not just the lump total, so it's clear
              what's actually being deducted and who logged it. */}
          {filteredExpenses.map((e) => (
            <div key={e.id} className="flex justify-end gap-6 text-xs text-gray-400">
              <span>
                {e.description}
                {e.adminOnly && <span className="ml-1 text-gray-300">(Admin Only)</span>}
              </span>
              <span className="w-32 text-red-400">-{peso(e.amount)}</span>
            </div>
          ))}

          <div className="flex justify-end gap-6 text-sm text-red-500 pt-1.5 border-t border-gray-100">
            <span>Total Expenses</span>
            <span className="w-32">-{peso(totalExpenses)}</span>
          </div>
          <div className="flex justify-end gap-6 text-base font-bold text-gray-800 pt-1.5 border-t border-gray-100">
            <span>Net Profit After Expenses</span>
            <span className="w-32">{peso(netProfitAfterExpenses)}</span>
          </div>
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
