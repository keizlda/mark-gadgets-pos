import { useState } from "react";
import { X, AlertTriangle } from "lucide-react";

// Staff can read a bulk order's remarks; only admin gets the textarea to
// change them — same view/edit split used for Remove buttons elsewhere
// (e.g. ExpenseCategoryModal), just applied to a single field instead of
// a list.
function RemarksModal({ order, isAdmin, onSave, onClose }) {
  const [notes, setNotes] = useState(order.notes || "");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const handleSave = async () => {
    setError("");
    setSubmitting(true);
    try {
      await onSave(notes.trim());
      onClose();
    } catch (err) {
      setError(err.message || "Failed to save remarks. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl w-full max-w-md shadow-xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-gray-100">
          <div>
            <p className="font-semibold text-gray-800">Remarks</p>
            <p className="text-xs text-gray-400">
              {order.customer} · {order.date}
            </p>
          </div>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-4 space-y-3">
          {error && (
            <div className="bg-red-50 border border-red-100 rounded-lg p-3 flex items-start gap-2">
              <AlertTriangle size={15} className="text-red-500 mt-0.5 flex-shrink-0" />
              <p className="text-sm text-red-700">{error}</p>
            </div>
          )}

          {isAdmin ? (
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={4}
              placeholder="Add a remark for this bulk order..."
              autoFocus
              className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
            />
          ) : order.notes ? (
            <p className="text-sm text-gray-700 whitespace-pre-wrap">{order.notes}</p>
          ) : (
            <p className="text-sm text-gray-400">No remarks yet.</p>
          )}
        </div>

        <div className="px-5 py-4 border-t border-gray-100 flex justify-end gap-3">
          <button
            onClick={onClose}
            disabled={submitting}
            className="px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-60"
          >
            {isAdmin ? "Cancel" : "Close"}
          </button>
          {isAdmin && (
            <button
              onClick={handleSave}
              disabled={submitting}
              className="px-4 py-2 text-sm text-white bg-blue-600 rounded-lg hover:bg-blue-700 disabled:opacity-60"
            >
              {submitting ? "Saving..." : "Save"}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

export default RemarksModal;
