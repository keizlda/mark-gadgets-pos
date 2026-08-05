import { useState } from "react";
import { X, AlertTriangle } from "lucide-react";
import { updateSaleDate } from "../../services/salesService";

// Local (not UTC) YYYY-MM-DD, for prefilling a <input type="date"> from a
// stored timestamptz — see the identical helper in EditShipmentArrivalModal.
const toISODate = (d) => {
  const offset = d.getTimezoneOffset();
  return new Date(d.getTime() - offset * 60000).toISOString().slice(0, 10);
};

// Admin-only — moves an entire bulk order to a different date. sold_at
// lives once per sale, so every unit in the order (all sharing this
// saleId) moves together, same as marking the whole order Paid does.
function EditBulkOrderDateModal({ order, onClose, onSaved }) {
  const [date, setDate] = useState(toISODate(new Date(order.date)));
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!date) {
      setError("Select a date.");
      return;
    }
    setError("");
    setSubmitting(true);
    try {
      await updateSaleDate(order.saleId, new Date(`${date}T00:00:00`).toISOString());
      onSaved();
    } catch (err) {
      setError(err.message || "Failed to save date. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl w-full max-w-sm shadow-xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-gray-100">
          <div>
            <p className="font-semibold text-gray-800">Edit Order Date</p>
            <p className="text-xs text-gray-400">
              {order.customer} · {order.items.length} unit{order.items.length === 1 ? "" : "s"}
            </p>
          </div>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
            <X size={18} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="px-5 py-4 space-y-3">
            {error && (
              <div className="bg-red-50 border border-red-100 rounded-lg p-3 flex items-start gap-2">
                <AlertTriangle size={15} className="text-red-500 mt-0.5 flex-shrink-0" />
                <p className="text-sm text-red-700">{error}</p>
              </div>
            )}

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">Date</label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                autoFocus
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p className="text-xs text-gray-400 mt-1">
                Moves this whole order — and every unit in it — to show under this date in Reports, Financial, and
                Sales History.
              </p>
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
              {submitting ? "Saving..." : "Save"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default EditBulkOrderDateModal;
