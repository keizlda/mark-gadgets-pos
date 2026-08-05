import { useState } from "react";
import { X, AlertTriangle } from "lucide-react";
import { editBulkOrderShell } from "../../services/bulkOrderShellsService";
import SupplierSelect from "./SupplierSelect";

// Local (not UTC) YYYY-MM-DD, for prefilling a <input type="date"> from a
// stored timestamptz — same reasoning as todayLocalDateString in
// utils/datetime.js, just for an arbitrary date instead of always today.
const toISODate = (d) => {
  const offset = d.getTimezoneOffset();
  return new Date(d.getTime() - offset * 60000).toISOString().slice(0, 10);
};

// Plain fields, no category/model cascade — bulk_order_shells never stored
// a category (that dropdown in Log Shipment only ever drove the catalog
// picker), so there's nothing to prefill it from here. SupplierSelect gets
// no category prop for the same reason — see its own comment on why that's
// the correct thing to do when there's no category context.
function EditShipmentArrivalModal({ shell, onClose, onSaved }) {
  const [form, setForm] = useState({
    supplierName: shell.supplierName || "",
    deviceName: shell.deviceName || "",
    storage: shell.storage || "",
    color: shell.color || "",
    quantityExpected: shell.quantityExpected ?? "",
    unitCost: shell.unitCost ?? "",
    dateArrived: toISODate(new Date(shell.dateArrived)),
    notes: shell.notes || "",
  });
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const update = (key, value) => setForm((f) => ({ ...f, [key]: value }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.deviceName.trim()) {
      setError("Enter a device name.");
      return;
    }
    if (!form.quantityExpected || Number(form.quantityExpected) <= 0) {
      setError("Enter how many units are expected.");
      return;
    }
    if (shell.linkedCount > Number(form.quantityExpected)) {
      setError(`${shell.linkedCount} unit(s) are already logged against this shipment — quantity expected can't go below that.`);
      return;
    }
    setError("");
    setSubmitting(true);
    try {
      await editBulkOrderShell({
        id: shell.id,
        supplierName: form.supplierName,
        deviceName: form.deviceName.trim(),
        storage: form.storage.trim(),
        color: form.color.trim(),
        quantityExpected: Number(form.quantityExpected),
        unitCost: form.unitCost === "" ? null : Number(form.unitCost),
        dateArrived: new Date(`${form.dateArrived}T00:00:00`).toISOString(),
        notes: form.notes.trim(),
      });
      onSaved();
    } catch (err) {
      setError(err.message || "Failed to save shipment. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl w-full max-w-lg shadow-xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-gray-100">
          <div>
            <p className="font-semibold text-gray-800">Edit Pending Shipment</p>
            <p className="text-xs text-gray-400">
              {shell.linkedCount}/{shell.quantityExpected} unit{shell.quantityExpected === 1 ? "" : "s"} already logged
            </p>
          </div>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
            <X size={18} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="px-5 py-4 space-y-4 max-h-[70vh] overflow-y-auto">
            {error && (
              <div className="bg-red-50 border border-red-100 rounded-lg p-3 flex items-start gap-2">
                <AlertTriangle size={15} className="text-red-500 mt-0.5 flex-shrink-0" />
                <p className="text-sm text-red-700">{error}</p>
              </div>
            )}

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">Supplier</label>
              <SupplierSelect value={form.supplierName} onChange={(v) => update("supplierName", v)} placeholder="None" />
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">
                Device Name <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                value={form.deviceName}
                onChange={(e) => update("deviceName", e.target.value)}
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1.5">
                  Color <span className="text-gray-400 font-normal">(optional — leave blank if mixed)</span>
                </label>
                <input
                  type="text"
                  value={form.color}
                  onChange={(e) => update("color", e.target.value)}
                  className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1.5">
                  Storage <span className="text-gray-400 font-normal">(optional)</span>
                </label>
                <input
                  type="text"
                  value={form.storage}
                  onChange={(e) => update("storage", e.target.value)}
                  className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1.5">
                  Quantity Expected <span className="text-red-500">*</span>
                </label>
                <input
                  type="number"
                  min="1"
                  value={form.quantityExpected}
                  onChange={(e) => update("quantityExpected", e.target.value)}
                  className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1.5">
                  Unit Cost (Capital) <span className="text-gray-400 font-normal">(optional)</span>
                </label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">₱</span>
                  <input
                    type="number"
                    value={form.unitCost}
                    onChange={(e) => update("unitCost", e.target.value)}
                    className="w-full border border-gray-200 rounded-lg text-sm pl-7 pr-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
              </div>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">
                Date Arrived <span className="text-red-500">*</span>
              </label>
              <input
                type="date"
                value={form.dateArrived}
                onChange={(e) => update("dateArrived", e.target.value)}
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">Notes</label>
              <textarea
                value={form.notes}
                onChange={(e) => update("notes", e.target.value)}
                rows={2}
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
              />
            </div>
          </div>

          <div className="px-5 py-4 border-t border-gray-100 flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              disabled={submitting}
              className="px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-60"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={submitting}
              className="px-4 py-2 text-sm text-white bg-blue-600 rounded-lg hover:bg-blue-700 disabled:opacity-60"
            >
              {submitting ? "Saving..." : "Save Changes"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default EditShipmentArrivalModal;
