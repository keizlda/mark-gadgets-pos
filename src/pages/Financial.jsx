import { useState, useMemo, useEffect, useCallback } from "react";
import { Coins, Printer, Search, PiggyBank, TrendingUp, Wallet, Plus, Trash2, AlertTriangle, Boxes } from "lucide-react";
import { useServiceData } from "../hooks/useServiceData";
import { getSalesHistory } from "../services/salesService";
import { getAllDevices } from "../services/inventoryService";
import { getAllExpenses, addExpense, deleteExpense } from "../services/expensesService";
import { getCgnResales, addCgnResale, deleteCgnResale } from "../services/cgnResalesService";
import DateRangePicker from "../components/common/DateRangePicker";
import UnsoldUnitsModal from "../components/financial/UnsoldUnitsModal";
import ExpenseCategoryModal from "../components/financial/ExpenseCategoryModal";
import DeviceDetailsModal from "../components/inventory/DeviceDetailsModal";
import { useToast } from "../hooks/useToast";

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

function SummaryCard({ icon: Icon, iconBg, label, value, sub, valueClass, onClick }) {
  const Tag = onClick ? "button" : "div";
  return (
    <Tag
      type={onClick ? "button" : undefined}
      onClick={onClick}
      className={`flex items-center gap-4 bg-white rounded-xl border border-gray-200 p-5 w-full text-left ${
        onClick ? "hover:border-purple-300 hover:shadow-sm transition-colors cursor-pointer" : ""
      }`}
    >
      <div className={`h-14 w-14 rounded-full flex items-center justify-center shrink-0 ${iconBg}`}>
        <Icon size={22} />
      </div>
      <div>
        <p className="text-xs font-medium text-gray-500 tracking-wide">{label}</p>
        <p className={`text-2xl font-bold leading-tight ${valueClass}`}>{value}</p>
        <p className="text-xs text-gray-400">{sub}</p>
      </div>
    </Tag>
  );
}

const initialRange = getPresetRange("Monthly");

function Financial() {
  const showToast = useToast();
  const salesHistory = useServiceData(getSalesHistory, []);
  const allDevices = useServiceData(getAllDevices, []);

  const [reportType, setReportType] = useState("Monthly");
  const [dateFrom, setDateFrom] = useState(initialRange.from);
  const [dateTo, setDateTo] = useState(initialRange.to);
  const [generatedRange, setGeneratedRange] = useState(initialRange);

  const [showUnsoldUnits, setShowUnsoldUnits] = useState(false);
  const [viewDevice, setViewDevice] = useState(null);
  const [expenseModalCategory, setExpenseModalCategory] = useState(null); // null | "General" | "Cargo" | "Prulife" | "Personal"
  const [ledgerView, setLedgerView] = useState("store"); // "store" | "cgn"

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
  const [expenseCategory, setExpenseCategory] = useState("General");
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

  // CGN is the admin's other branch — every sale made to them (bulk or
  // individual) gets its own ledger here, on top of the regular one above,
  // so the admin can see what was sold to CGN specifically without it
  // being buried in the full sales list. Matched on the same customer
  // name field the sale was rung up under, case/whitespace-insensitive.
  const cgnRows = useMemo(
    () => rows.filter((r) => r.customer && r.customer.trim().toLowerCase() === "cgn"),
    [rows]
  );
  const cgnTotals = useMemo(() => {
    const totalCapital = cgnRows.reduce((sum, r) => sum + (r.purchasePrice ?? 0), 0);
    const totalDisposal = cgnRows.reduce((sum, r) => sum + r.total, 0);
    const totalNetProfit = cgnRows.reduce((sum, r) => sum + (r.netProfit ?? 0), 0);
    return { totalCapital, totalDisposal, totalNetProfit };
  }, [cgnRows]);

  // CGN's own resale of those same units to their own customers — a
  // separate business event, tracked in its own table (not devices/sales,
  // since the unit already left our inventory when we sold it to CGN).
  const [cgnResales, setCgnResales] = useState([]);
  const loadCgnResales = useCallback(() => {
    getCgnResales().then(setCgnResales);
  }, []);
  useEffect(() => {
    loadCgnResales();
  }, [loadCgnResales]);

  const cgnResaleTotals = useMemo(() => {
    const totalCapital = cgnResales.reduce((sum, r) => sum + r.capital, 0);
    const totalDisposal = cgnResales.reduce((sum, r) => sum + r.disposalPrice, 0);
    const totalProfit = cgnResales.reduce((sum, r) => sum + r.profit, 0);
    return { totalCapital, totalDisposal, totalProfit };
  }, [cgnResales]);

  // Both legs of the CGN business — what we sold them (wholesale) and what
  // they resold it for (retail) — combined into one ledger and one profit
  // figure, since both are the admin's own money either way.
  const combinedCgnEntries = useMemo(() => {
    const soldToCgn = cgnRows.map((r) => ({
      key: `sale-${r.saleItemId}`,
      date: r.date,
      sortDate: new Date(r.date),
      batchCode: r.batchCode,
      unit: [r.device, r.storage, r.color].filter(Boolean).join(" · "),
      capital: r.purchasePrice,
      soldFor: r.total,
      profit: r.netProfit,
      ref: r.supplier || "—",
      stage: "Sold to CGN",
    }));
    const cgnResold = cgnResales.map((r) => ({
      key: `resale-${r.id}`,
      id: r.id,
      date: r.date,
      sortDate: new Date(r.date),
      batchCode: "—",
      unit: r.deviceName,
      capital: r.capital,
      soldFor: r.disposalPrice,
      profit: r.profit,
      ref: r.supplierNote || "—",
      stage: "CGN Resale",
    }));
    return [...soldToCgn, ...cgnResold].sort((a, b) => b.sortDate - a.sortDate);
  }, [cgnRows, cgnResales]);

  const combinedCgnTotals = useMemo(
    () => ({
      totalCapital: cgnTotals.totalCapital + cgnResaleTotals.totalCapital,
      totalDisposal: cgnTotals.totalDisposal + cgnResaleTotals.totalDisposal,
      totalNetProfit: cgnTotals.totalNetProfit + cgnResaleTotals.totalProfit,
    }),
    [cgnTotals, cgnResaleTotals]
  );

  const [resaleDate, setResaleDate] = useState(toISODate(new Date()));
  const [resaleDeviceName, setResaleDeviceName] = useState("");
  const [resaleCapital, setResaleCapital] = useState("");
  const [resaleDisposal, setResaleDisposal] = useState("");
  const [resaleSupplierNote, setResaleSupplierNote] = useState("");
  const [resaleError, setResaleError] = useState("");
  const [submittingResale, setSubmittingResale] = useState(false);

  const handleAddCgnResale = async (e) => {
    e.preventDefault();
    if (!resaleDeviceName.trim() || !resaleCapital || !resaleDisposal) return;
    setResaleError("");
    setSubmittingResale(true);
    try {
      await addCgnResale({
        date: resaleDate,
        deviceName: resaleDeviceName.trim(),
        capital: Number(resaleCapital),
        disposalPrice: Number(resaleDisposal),
        supplierNote: resaleSupplierNote.trim(),
      });
      setResaleDeviceName("");
      setResaleCapital("");
      setResaleDisposal("");
      setResaleSupplierNote("");
      loadCgnResales();
    } catch (err) {
      setResaleError(err.message || "Failed to add resale entry. Please try again.");
    } finally {
      setSubmittingResale(false);
    }
  };

  const handleRemoveCgnResale = async (id) => {
    try {
      await deleteCgnResale(id);
      loadCgnResales();
    } catch (err) {
      showToast(err.message || "Failed to remove resale entry. Please try again.", "error");
    }
  };

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

  // Cargo (shipping/rider/courier), Prulife (life insurance premiums), and
  // Personal (owner's personal draws) are tracked as their own categories so
  // each gets its own total instead of being buried in the lump Expenses
  // figure — but they're still real costs, so they still come off Net Profit.
  const expensesByCategory = useMemo(
    () => ({
      General: filteredExpenses.filter(
        (e) => e.category !== "Cargo" && e.category !== "Prulife" && e.category !== "Personal"
      ),
      Cargo: filteredExpenses.filter((e) => e.category === "Cargo"),
      Prulife: filteredExpenses.filter((e) => e.category === "Prulife"),
      Personal: filteredExpenses.filter((e) => e.category === "Personal"),
    }),
    [filteredExpenses]
  );
  const generalExpenses = expensesByCategory.General;
  const cargoExpenses = expensesByCategory.Cargo;
  const prulifeExpenses = expensesByCategory.Prulife;
  const personalExpenses = expensesByCategory.Personal;
  const totalExpenses = generalExpenses.reduce((sum, e) => sum + e.amount, 0);
  const totalCargo = cargoExpenses.reduce((sum, e) => sum + e.amount, 0);
  const totalPrulife = prulifeExpenses.reduce((sum, e) => sum + e.amount, 0);
  const totalPersonal = personalExpenses.reduce((sum, e) => sum + e.amount, 0);
  // Split so "CGN Profit" below can carry the full combined CGN business
  // (what we made selling to them + what they made reselling) without
  // double-counting the wholesale-to-CGN leg, which totals.totalNetProfit
  // already includes as part of the whole store's sales.
  const storeOnlyProfit = totals.totalNetProfit - cgnTotals.totalNetProfit;
  const netProfitAfterExpenses =
    storeOnlyProfit + combinedCgnTotals.totalNetProfit - totalExpenses - totalCargo - totalPrulife - totalPersonal;

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
        category: expenseCategory,
      });
      setExpenseDesc("");
      setExpenseAmount("");
      setExpenseCategory("General");
      loadExpenses();
    } catch (err) {
      setExpenseError(err.message || "Failed to add expense. Please try again.");
    } finally {
      setSubmittingExpense(false);
    }
  };

  // Lets admin add an expense straight from the Cargo/Prulife (or Expenses)
  // breakdown modal, already scoped to that category, instead of backing out
  // to the main form and re-picking it from the dropdown.
  const handleAddExpenseFromModal = async ({ date, description, amount, category }) => {
    await addExpense({ date, description, amount, adminOnly: true, category });
    loadExpenses();
  };

  const handleRemoveExpense = async (id) => {
    try {
      await deleteExpense(id);
      loadExpenses();
    } catch (err) {
      showToast(err.message || "Failed to remove expense. Please try again.", "error");
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

          <div className="flex border border-gray-200 rounded-lg overflow-hidden">
            <button
              type="button"
              onClick={() => setLedgerView("store")}
              className={`px-4 py-2.5 text-sm font-medium ${
                ledgerView === "store" ? "bg-blue-600 text-white" : "bg-white text-gray-600 hover:bg-gray-50"
              }`}
            >
              Store Ledger
            </button>
            <button
              type="button"
              onClick={() => setLedgerView("cgn")}
              className={`px-4 py-2.5 text-sm font-medium border-l border-gray-200 ${
                ledgerView === "cgn" ? "bg-blue-600 text-white" : "bg-white text-gray-600 hover:bg-gray-50"
              }`}
            >
              CGN Ledger
            </button>
          </div>
        </div>
      </div>

      {/* Summary cards — switch with the Store/CGN ledger toggle so they
          never show a different scope than the table below them. */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 print:hidden">
        <SummaryCard
          icon={Wallet}
          iconBg="bg-gray-100 text-gray-600"
          label={ledgerView === "cgn" ? "CGN CAPITAL" : "TOTAL CAPITAL"}
          value={peso(ledgerView === "cgn" ? combinedCgnTotals.totalCapital : totals.totalCapital)}
          sub="Total Cost of Units Sold"
          valueClass="text-gray-700"
        />
        <SummaryCard
          icon={PiggyBank}
          iconBg="bg-blue-50 text-blue-600"
          label={ledgerView === "cgn" ? "CGN DISPOSAL PRICE" : "TOTAL DISPOSAL PRICE"}
          value={peso(ledgerView === "cgn" ? combinedCgnTotals.totalDisposal : totals.totalDisposal)}
          sub="Total Amount Sold For"
          valueClass="text-blue-600"
        />
        <SummaryCard
          icon={TrendingUp}
          iconBg="bg-green-50 text-green-600"
          label={ledgerView === "cgn" ? "CGN NET PROFIT" : "TOTAL NET PROFIT"}
          value={peso(ledgerView === "cgn" ? combinedCgnTotals.totalNetProfit : totals.totalNetProfit)}
          sub="Disposal Price minus Capital"
          valueClass="text-green-600"
        />
      </div>

      {/* Ledger table — toggled between the full store ledger and the CGN
          one via the Store Ledger/CGN Ledger buttons above. The CGN view
          merges both legs of that business into one table: units we sold
          to CGN (wholesale) and what CGN resold them for to their own
          customers (retail) — a "Stage" column tells the two apart. */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <p className="font-bold text-gray-800 mb-4">
          {ledgerView === "cgn" ? "CGN Ledger" : "Unit Financial Ledger"}
        </p>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-500 bg-gray-50">
                <th className="px-3 py-2.5 font-medium rounded-l-lg">#</th>
                <th className="px-3 py-2.5 font-medium">Date</th>
                <th className="px-3 py-2.5 font-medium">Batch Code</th>
                <th className="px-3 py-2.5 font-medium">Unit / Model / Gb / Color</th>
                <th className="px-3 py-2.5 font-medium text-right">Capital</th>
                <th className="px-3 py-2.5 font-medium text-right">
                  {ledgerView === "cgn" ? "Sold For" : "Disposal Price"}
                </th>
                <th className="px-3 py-2.5 font-medium text-right">Net Profit</th>
                <th className="px-3 py-2.5 font-medium">{ledgerView === "cgn" ? "Stage" : "Supplier"}</th>
                {ledgerView === "cgn" && <th className="px-3 py-2.5 font-medium rounded-r-lg text-right">Remove</th>}
                {ledgerView !== "cgn" && <th className="px-3 py-2.5 font-medium rounded-r-lg"></th>}
              </tr>
            </thead>
            <tbody>
              {(ledgerView === "cgn" ? combinedCgnEntries : rows).length === 0 ? (
                <tr>
                  <td colSpan={9} className="py-8 text-center text-gray-400">
                    {ledgerView === "cgn"
                      ? "No CGN activity for the selected date range."
                      : "No sold units found for the selected date range."}
                  </td>
                </tr>
              ) : ledgerView === "cgn" ? (
                combinedCgnEntries.map((row, index) => (
                  <tr key={row.key} className="border-b border-gray-50 last:border-0">
                    <td className="px-3 py-3 text-gray-500">{index + 1}</td>
                    <td className="px-3 py-3 text-gray-700 whitespace-nowrap">{row.date}</td>
                    <td className="px-3 py-3 text-gray-700 whitespace-nowrap">{row.batchCode}</td>
                    <td className="px-3 py-3 text-gray-800 font-medium">{row.unit}</td>
                    <td className="px-3 py-3 text-right text-gray-700">
                      {row.capital != null ? peso(row.capital) : "—"}
                    </td>
                    <td className="px-3 py-3 text-right text-gray-800">{peso(row.soldFor)}</td>
                    <td
                      className={`px-3 py-3 text-right font-medium ${
                        row.profit == null ? "text-gray-400" : row.profit < 0 ? "text-red-500" : "text-green-600"
                      }`}
                    >
                      {row.profit != null ? peso(row.profit) : "—"}
                    </td>
                    <td className="px-3 py-3 whitespace-nowrap">
                      <span
                        className={`px-2 py-0.5 rounded-full text-xs font-medium ${
                          row.stage === "CGN Resale" ? "bg-teal-100 text-teal-700" : "bg-blue-100 text-blue-700"
                        }`}
                      >
                        {row.stage}
                      </span>
                    </td>
                    <td className="px-3 py-3 text-right">
                      {row.id && (
                        <button
                          onClick={() => handleRemoveCgnResale(row.id)}
                          className="text-gray-400 hover:text-red-500 p-1"
                        >
                          <Trash2 size={14} />
                        </button>
                      )}
                    </td>
                  </tr>
                ))
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
                    <td></td>
                  </tr>
                ))
              )}
            </tbody>
            <tfoot>
              <tr className="bg-gray-50 font-bold text-gray-800">
                <td className="px-3 py-3 rounded-l-lg" colSpan={4}>TOTAL</td>
                <td className="px-3 py-3 text-right">
                  {peso(ledgerView === "cgn" ? combinedCgnTotals.totalCapital : totals.totalCapital)}
                </td>
                <td className="px-3 py-3 text-right">
                  {peso(ledgerView === "cgn" ? combinedCgnTotals.totalDisposal : totals.totalDisposal)}
                </td>
                <td className="px-3 py-3 text-right text-green-600">
                  {peso(ledgerView === "cgn" ? combinedCgnTotals.totalNetProfit : totals.totalNetProfit)}
                </td>
                <td className="px-3 py-3 rounded-r-lg" colSpan={2}></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>

      {/* Add a CGN resale entry — CGN's own resale of a unit to their end
          customer, from CGN's own report. Feeds straight into the merged
          ledger above. Only relevant while viewing the CGN ledger. */}
      {ledgerView === "cgn" && (
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <p className="font-bold text-gray-800 mb-1">Add CGN Resale Entry</p>
          <p className="text-xs text-gray-400 mb-4">
            Record what CGN resold a unit for to their own customer — shows up in the ledger above as "CGN Resale".
          </p>

          {resaleError && (
            <div className="flex items-start gap-2 bg-red-50 border border-red-100 rounded-lg px-3 py-2 mt-4">
              <AlertTriangle size={15} className="text-red-500 mt-0.5 flex-shrink-0" />
              <p className="text-sm text-red-700">{resaleError}</p>
            </div>
          )}

          <form onSubmit={handleAddCgnResale} className="flex flex-wrap items-end gap-3 mt-4">
            <div>
              <label className="block text-xs font-medium text-gray-500 mb-1.5">Date</label>
              <input
                type="date"
                value={resaleDate}
                onChange={(e) => setResaleDate(e.target.value)}
                className="w-40 border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="flex-1 min-w-[180px]">
              <label className="block text-xs font-medium text-gray-500 mb-1.5">Unit</label>
              <input
                type="text"
                value={resaleDeviceName}
                onChange={(e) => setResaleDeviceName(e.target.value)}
                placeholder="e.g. iPhone 11 128GB Purple"
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-500 mb-1.5">Capital</label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">₱</span>
                <input
                  type="number"
                  value={resaleCapital}
                  onChange={(e) => setResaleCapital(e.target.value)}
                  placeholder="0.00"
                  className="w-28 border border-gray-200 rounded-lg text-sm pl-7 pr-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-500 mb-1.5">Resold For</label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">₱</span>
                <input
                  type="number"
                  value={resaleDisposal}
                  onChange={(e) => setResaleDisposal(e.target.value)}
                  placeholder="0.00"
                  className="w-28 border border-gray-200 rounded-lg text-sm pl-7 pr-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-500 mb-1.5">Ref (Optional)</label>
              <input
                type="text"
                value={resaleSupplierNote}
                onChange={(e) => setResaleSupplierNote(e.target.value)}
                placeholder="e.g. S 06.22"
                className="w-28 border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <button
              type="submit"
              disabled={submittingResale}
              className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 disabled:opacity-60"
            >
              <Plus size={14} />
              {submittingResale ? "Adding..." : "Add"}
            </button>
          </form>
        </div>
      )}

      {/* Expenses — every entry, all categories, includes both what staff
          logged on Reports and what's logged here (entries added from this
          page are marked Admin Only and stay hidden from Reports). */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <p className="font-bold text-gray-800 mb-4 print:hidden">Expenses</p>

        {/* The raw line-item list is a screen thing — the printed report
            just needs the totals, which the breakdown below already covers. */}
        <div className="overflow-x-auto print:hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-500 bg-gray-50">
                <th className="px-3 py-2.5 font-medium rounded-l-lg">Date</th>
                <th className="px-3 py-2.5 font-medium">Description</th>
                <th className="px-3 py-2.5 font-medium text-right">Amount</th>
                <th className="px-3 py-2.5 font-medium rounded-r-lg text-right">Remove</th>
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
                  <td className="px-3 py-3 text-gray-800 font-medium">
                    {e.description}
                    {e.category === "Cargo" && (
                      <span className="ml-2 px-1.5 py-0.5 rounded text-[10px] font-medium bg-amber-100 text-amber-700 align-middle">
                        Cargo
                      </span>
                    )}
                    {e.category === "Prulife" && (
                      <span className="ml-2 px-1.5 py-0.5 rounded text-[10px] font-medium bg-indigo-100 text-indigo-700 align-middle">
                        Prulife
                      </span>
                    )}
                    {e.category === "Personal" && (
                      <span className="ml-2 px-1.5 py-0.5 rounded text-[10px] font-medium bg-pink-100 text-pink-700 align-middle">
                        Personal
                      </span>
                    )}
                    {e.adminOnly && (
                      <span className="ml-2 px-1.5 py-0.5 rounded text-[10px] font-medium bg-gray-100 text-gray-500 align-middle">
                        Admin Only
                      </span>
                    )}
                  </td>
                  <td className="px-3 py-3 text-red-500 text-right">-{peso(e.amount)}</td>
                  <td className="px-3 py-3 text-right">
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
                <td className="px-3 py-3 text-right text-red-500">
                  -{peso(totalExpenses + totalCargo + totalPrulife + totalPersonal)}
                </td>
                <td className="px-3 py-3 rounded-r-lg"></td>
              </tr>
            </tfoot>
          </table>
        </div>

        <p className="font-semibold text-gray-700 mt-6 mb-3 print:hidden">Add Expense</p>

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
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1.5">Category</label>
            <select
              value={expenseCategory}
              onChange={(e) => setExpenseCategory(e.target.value)}
              className="w-32 border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="General">General</option>
              <option value="Cargo">Cargo</option>
              <option value="Prulife">Prulife</option>
              <option value="Personal">Personal</option>
            </select>
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

        {/* Breakdown, below the form — mirrors the shop's own spreadsheet
            summary format: Profit, then each deduction, then the bottom line.
            A fixed-width column keeps every value flush regardless of how
            long its label is. */}
        <div className="mt-6 pt-4 border-t border-gray-100 flex justify-end">
          <div className="w-full max-w-xs space-y-1">
            <div className="flex justify-between text-sm text-gray-600 px-2 py-1.5">
              <span>Store Profit</span>
              <span className="font-medium tabular-nums">{peso(storeOnlyProfit)}</span>
            </div>
            <div className="flex justify-between text-sm text-teal-600 px-2 py-1.5">
              <span>CGN Profit</span>
              <span className="font-medium tabular-nums">{peso(combinedCgnTotals.totalNetProfit)}</span>
            </div>
            <button
              type="button"
              onClick={() => setExpenseModalCategory("General")}
              className="flex justify-between w-full text-sm text-red-500 px-2 py-1.5 rounded-lg hover:bg-red-50"
            >
              <span>Expenses</span>
              <span className="font-medium tabular-nums">-{peso(totalExpenses)}</span>
            </button>
            <button
              type="button"
              onClick={() => setExpenseModalCategory("Cargo")}
              className="flex justify-between w-full text-sm text-amber-600 px-2 py-1.5 rounded-lg hover:bg-amber-50"
            >
              <span>Cargo</span>
              <span className="font-medium tabular-nums">-{peso(totalCargo)}</span>
            </button>
            <button
              type="button"
              onClick={() => setExpenseModalCategory("Prulife")}
              className="flex justify-between w-full text-sm text-indigo-600 px-2 py-1.5 rounded-lg hover:bg-indigo-50"
            >
              <span>Prulife</span>
              <span className="font-medium tabular-nums">-{peso(totalPrulife)}</span>
            </button>
            <button
              type="button"
              onClick={() => setExpenseModalCategory("Personal")}
              className="flex justify-between w-full text-sm text-pink-600 px-2 py-1.5 rounded-lg hover:bg-pink-50"
            >
              <span>Personal</span>
              <span className="font-medium tabular-nums">-{peso(totalPersonal)}</span>
            </button>
            <div
              className={`flex justify-between text-base font-bold px-2 py-2 mt-1 border-t border-gray-100 ${
                netProfitAfterExpenses < 0 ? "text-red-500" : "text-gray-800"
              }`}
            >
              <span>Net Profit</span>
              <span className="tabular-nums">{peso(netProfitAfterExpenses)}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Inventory On Hand — a snapshot of what's still unsold right now,
          independent of the date range above. Only meaningful for the
          longer-horizon report types, not a single day/week/month. */}
      {(reportType === "Quarterly" || reportType === "Annually") && (
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <p className="font-bold text-gray-800 mb-1">Inventory On Hand (Unsold Units)</p>
          <p className="text-xs text-gray-400 mb-4">
            Current snapshot — every unit not yet Sold, regardless of the date range above. Its capital is
            carried into the Expenses summary above as its own line, not added to profit.
          </p>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <SummaryCard
              icon={Boxes}
              iconBg="bg-purple-50 text-purple-600"
              label="UNITS IN STOCK"
              value={unsoldTotals.count}
              sub="Not yet Sold — click to view"
              valueClass="text-purple-600"
              onClick={() => setShowUnsoldUnits(true)}
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

      {/* Note */}
      <div className="flex items-start gap-2 bg-blue-50 border border-blue-100 rounded-xl px-4 py-3 text-sm text-blue-700 print:hidden">
        <span className="font-medium">Note:</span>
        <span>
          Capital comes from each unit's recorded purchase price — units added before that field existed show "—"
          until backfilled via Edit Device.
        </span>
      </div>

      {showUnsoldUnits && (
        <UnsoldUnitsModal
          units={unsoldUnits}
          onClose={() => setShowUnsoldUnits(false)}
          onView={(device) => {
            setShowUnsoldUnits(false);
            setViewDevice(device);
          }}
        />
      )}

      {viewDevice && <DeviceDetailsModal device={viewDevice} onClose={() => setViewDevice(null)} />}

      {expenseModalCategory && (
        <ExpenseCategoryModal
          category={expenseModalCategory}
          entries={expensesByCategory[expenseModalCategory]}
          isAdmin
          onRemove={handleRemoveExpense}
          onAdd={handleAddExpenseFromModal}
          onClose={() => setExpenseModalCategory(null)}
        />
      )}
    </div>
  );
}

export default Financial;
