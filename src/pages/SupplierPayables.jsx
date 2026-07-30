import { useState, useEffect, useCallback, useMemo } from "react";
import { Wallet, Info } from "lucide-react";
import { getSupplierPayables } from "../services/bulkOrderShellsService";
import MarkPaymentModal from "../components/payables/MarkPaymentModal";

const statusStyles = {
  Unpaid: "bg-orange-100 text-orange-600",
  Paid: "bg-green-100 text-green-600",
};

const filterOptions = ["All", "Unpaid", "Paid"];

function SupplierPayables() {
  const [shells, setShells] = useState([]);
  const loadShells = useCallback(() => {
    getSupplierPayables().then(setShells);
  }, []);
  useEffect(() => {
    loadShells();
  }, [loadShells]);

  const [statusFilter, setStatusFilter] = useState("All");
  const [paymentAction, setPaymentAction] = useState(null); // { shell, action }

  const filtered = useMemo(() => {
    if (statusFilter === "All") return shells;
    return shells.filter((s) => s.supplierPaymentStatus === statusFilter);
  }, [shells, statusFilter]);

  const totalOutstanding = useMemo(() => {
    return shells
      .filter((s) => s.supplierPaymentStatus === "Unpaid")
      .reduce((sum, s) => sum + (Number(s.amountPayable) || 0), 0);
  }, [shells]);

  const handleUpdated = () => {
    setPaymentAction(null);
    loadShells();
  };

  return (
    <div className="space-y-4">
      <div className="bg-blue-50 border border-blue-100 rounded-xl p-4 flex items-start gap-3">
        <Info size={18} className="text-blue-500 mt-0.5 flex-shrink-0" />
        <p className="text-sm text-blue-900">
          What's owed to each supplier for a bulk shipment — based on the agreed quantity and unit cost, not just
          how many units have been individually logged so far.
        </p>
      </div>

      <div className="bg-white rounded-xl border border-gray-200 p-5 flex items-center gap-4">
        <div className="bg-red-500 w-11 h-11 rounded-full flex items-center justify-center flex-shrink-0">
          <Wallet size={20} className="text-white" />
        </div>
        <div>
          <p className="text-2xl font-bold text-gray-800 leading-none">
            ₱{totalOutstanding.toLocaleString(undefined, { maximumFractionDigits: 2 })}
          </p>
          <p className="text-xs text-gray-400 mt-1">Total Outstanding (Unpaid shipments)</p>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <div className="flex items-center justify-between mb-4 flex-wrap gap-3">
          <p className="font-medium text-gray-800">Bulk Shipments</p>
          <div className="flex gap-1.5">
            {filterOptions.map((opt) => (
              <button
                key={opt}
                onClick={() => setStatusFilter(opt)}
                className={`px-3 py-1.5 rounded-lg text-xs font-medium border ${
                  statusFilter === opt
                    ? "border-blue-500 bg-blue-50 text-blue-600"
                    : "border-gray-200 text-gray-500 hover:bg-gray-50"
                }`}
              >
                {opt}
              </button>
            ))}
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-400 border-b border-gray-100">
                <th className="pb-2 font-medium">Supplier</th>
                <th className="pb-2 font-medium">Device Model</th>
                <th className="pb-2 font-medium">Variant</th>
                <th className="pb-2 font-medium">Qty Expected</th>
                <th className="pb-2 font-medium">Unit Cost</th>
                <th className="pb-2 font-medium">Amount Payable</th>
                <th className="pb-2 font-medium">Date Arrived</th>
                <th className="pb-2 font-medium">Status</th>
                <th className="pb-2 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={9} className="py-8 text-center text-gray-400">
                    No bulk shipments found.
                  </td>
                </tr>
              ) : (
                filtered.map((s) => (
                  <tr key={s.id} className="border-b border-gray-50 hover:bg-gray-50">
                    <td className="py-3 text-gray-700">{s.supplierName || "—"}</td>
                    <td className="py-3 text-gray-800 font-medium">{s.deviceName}</td>
                    <td className="py-3 text-gray-600">
                      {[s.storage, s.color].filter(Boolean).join(" · ") || "—"}
                    </td>
                    <td className="py-3 text-gray-600">{s.quantityExpected}</td>
                    <td className="py-3 text-gray-600">
                      {s.unitCost != null ? `₱${Number(s.unitCost).toLocaleString()}` : "—"}
                    </td>
                    <td className="py-3 text-gray-800 font-medium">
                      {s.amountPayable != null ? `₱${Number(s.amountPayable).toLocaleString()}` : "—"}
                    </td>
                    <td className="py-3 text-gray-500">{s.dateArrived?.slice(0, 10)}</td>
                    <td className="py-3">
                      <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${statusStyles[s.supplierPaymentStatus]}`}>
                        {s.supplierPaymentStatus}
                      </span>
                    </td>
                    <td className="py-3 text-right">
                      {s.supplierPaymentStatus === "Paid" ? (
                        <button
                          onClick={() => setPaymentAction({ shell: s, action: "unpay" })}
                          className="text-sm text-orange-600 border border-orange-200 px-3 py-1.5 rounded-lg hover:bg-orange-50"
                        >
                          Mark as Unpaid
                        </button>
                      ) : (
                        <button
                          onClick={() => setPaymentAction({ shell: s, action: "pay" })}
                          className="text-sm text-green-600 border border-green-200 px-3 py-1.5 rounded-lg hover:bg-green-50"
                        >
                          Mark as Paid
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {paymentAction && (
        <MarkPaymentModal
          shell={paymentAction.shell}
          action={paymentAction.action}
          onClose={() => setPaymentAction(null)}
          onUpdated={handleUpdated}
        />
      )}
    </div>
  );
}

export default SupplierPayables;
