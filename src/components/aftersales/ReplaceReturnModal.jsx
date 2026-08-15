import { useState, useEffect, useMemo } from "react";
import { X, AlertTriangle } from "lucide-react";
import { getAvailableDevicesForReplacement, getAvailableDevicesForSale } from "../../services/inventoryService";
import { replaceReturn, completeHeldReturn } from "../../services/returnsService";
import { matchesQuery } from "../../utils/search";

const OTHER_UNIT = "__other__";

// mode "replace": Pending -> Replaced in one step (original unit routed
// now). mode "complete": On Hold -> Replaced (original unit was already
// routed back when it went on hold, so there's nothing left to route).
function ReplaceReturnModal({ record, onClose, onReplaced, mode = "replace" }) {
  const [candidates, setCandidates] = useState([]);
  const [candidatesLoaded, setCandidatesLoaded] = useState(false);
  const [replacementId, setReplacementId] = useState("");

  const [otherDevices, setOtherDevices] = useState([]);
  const [otherSearch, setOtherSearch] = useState("");
  const [otherDeviceId, setOtherDeviceId] = useState("");

  const [newPrice, setNewPrice] = useState("");
  const [priceTouched, setPriceTouched] = useState(false);

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    getAvailableDevicesForReplacement(record.device).then((list) => {
      setCandidates(list);
      setCandidatesLoaded(true);
    });
  }, [record.device]);

  useEffect(() => {
    if (replacementId === OTHER_UNIT && otherDevices.length === 0) {
      getAvailableDevicesForSale().then(setOtherDevices);
    }
  }, [replacementId, otherDevices.length]);

  const filteredOtherDevices = useMemo(() => {
    return otherDevices.filter((d) => matchesQuery(d.product, otherSearch) || matchesQuery(d.batchCode, otherSearch));
  }, [otherDevices, otherSearch]);

  const selectedOtherDevice = otherDevices.find((d) => d.id === otherDeviceId);
  const selectedCandidate = candidates.find((c) => c.id === replacementId);
  const goesToSupplierDefective = record ? ["Defective Unit", "Not as Described"].includes(record.reason) : false;

  // Prefill the price from whichever replacement was just picked, but only
  // until staff actually edits it — otherwise every re-render would stomp
  // a manual override back to the device's list price.
  useEffect(() => {
    if (priceTouched) return;
    const suggested = selectedOtherDevice?.price ?? selectedCandidate?.price;
    if (suggested != null) setNewPrice(String(suggested));
  }, [selectedOtherDevice, selectedCandidate, priceTouched]);

  if (!record) return null;

  const resolvedReplacementId = replacementId === OTHER_UNIT ? otherDeviceId : replacementId;
  const parsedPrice = Number(newPrice);

  const handleConfirm = async () => {
    if (!resolvedReplacementId) {
      setError("Select a replacement unit.");
      return;
    }
    if (!newPrice || Number.isNaN(parsedPrice) || parsedPrice <= 0) {
      setError("Enter a valid sale price for the replacement.");
      return;
    }
    setError("");
    setSubmitting(true);
    try {
      if (mode === "complete") {
        await completeHeldReturn(record.id, resolvedReplacementId, parsedPrice);
      } else {
        await replaceReturn(record.id, record.deviceId, resolvedReplacementId, record.reason, parsedPrice);
      }
      onReplaced();
    } catch (err) {
      setError(err.message || "Failed to replace return. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl w-full max-w-md shadow-xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-gray-100">
          <p className="font-semibold text-gray-800">
            {mode === "complete" ? "Complete Replacement" : "Replace Return"}
          </p>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-4 space-y-4 max-h-[70vh] overflow-y-auto">
          <p className="text-sm text-gray-600">
            {record.batchCode} · {record.device} · {record.customer}
          </p>

          {error && (
            <div className="bg-red-50 border border-red-100 rounded-lg p-3 flex items-start gap-2">
              <AlertTriangle size={15} className="text-red-500 mt-0.5 flex-shrink-0" />
              <p className="text-sm text-red-700">{error}</p>
            </div>
          )}

          <div>
            <label className="block text-xs font-medium text-gray-600 mb-1.5">
              Available {record.device} units
            </label>
            <select
              value={replacementId}
              onChange={(e) => {
                setReplacementId(e.target.value);
                setOtherDeviceId("");
              }}
              className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Select a unit</option>
              {candidates.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.batchCode} — {c.storage} · {c.color}
                  {c.price != null ? ` · ₱${c.price.toLocaleString()}` : ""}
                </option>
              ))}
              <option value={OTHER_UNIT}>Other unit (different model)</option>
            </select>
            {candidatesLoaded && candidates.length === 0 && replacementId !== OTHER_UNIT && (
              <p className="text-xs text-red-500 mt-1.5">
                No available {record.device} units in stock right now — pick "Other unit (different model)" instead.
              </p>
            )}
          </div>

          {replacementId === OTHER_UNIT && (
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">
                Replace with a different model
              </label>
              {selectedOtherDevice ? (
                <div className="flex items-center justify-between border border-blue-200 bg-blue-50 rounded-lg px-3 py-2">
                  <div>
                    <p className="text-sm font-medium text-gray-800">{selectedOtherDevice.product}</p>
                    <p className="text-xs text-gray-500">
                      {selectedOtherDevice.batchCode} · {selectedOtherDevice.storage} · {selectedOtherDevice.color} · ₱
                      {selectedOtherDevice.price.toLocaleString()}
                    </p>
                  </div>
                  <button
                    onClick={() => setOtherDeviceId("")}
                    className="text-xs text-blue-600 hover:underline"
                  >
                    Change
                  </button>
                </div>
              ) : (
                <>
                  <input
                    type="text"
                    value={otherSearch}
                    onChange={(e) => setOtherSearch(e.target.value)}
                    placeholder="Search available devices..."
                    className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 mb-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <div className="border border-gray-200 rounded-lg max-h-40 overflow-y-auto divide-y divide-gray-50">
                    {filteredOtherDevices.length === 0 ? (
                      <p className="text-sm text-gray-400 px-3 py-3">No available devices found.</p>
                    ) : (
                      filteredOtherDevices.map((d) => (
                        <button
                          key={d.id}
                          onClick={() => setOtherDeviceId(d.id)}
                          className="w-full text-left px-3 py-2 hover:bg-gray-50"
                        >
                          <p className="text-sm text-gray-800">{d.product}</p>
                          <p className="text-xs text-gray-400">
                            {d.batchCode} · {d.storage} · {d.color} · ₱{d.price.toLocaleString()}
                          </p>
                        </button>
                      ))
                    )}
                  </div>
                </>
              )}
            </div>
          )}

          {resolvedReplacementId && (
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1.5">
                Sale Price for Replacement
              </label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-gray-400">₱</span>
                <input
                  type="number"
                  value={newPrice}
                  onChange={(e) => {
                    setNewPrice(e.target.value);
                    setPriceTouched(true);
                  }}
                  min="0"
                  step="0.01"
                  className="w-full pl-7 pr-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              {record.originalPrice != null && (
                <p className="text-xs text-gray-400 mt-1.5">
                  Original sale price was ₱{record.originalPrice.toLocaleString()}.
                </p>
              )}
            </div>
          )}

          {mode === "complete" ? (
            <p className="text-xs text-gray-400">
              The original unit ({record.batchCode}) was already routed when this return went on hold.
            </p>
          ) : (
            <p className="text-xs text-gray-400">
              {goesToSupplierDefective
                ? `The returned unit (${record.batchCode}) will be sent to Supplier Defective automatically.`
                : `The returned unit (${record.batchCode}) will go back to Available stock — "${record.reason}" isn't a defect.`}
            </p>
          )}
        </div>

        <div className="px-5 py-4 border-t border-gray-100 flex justify-end gap-3">
          <button
            onClick={onClose}
            disabled={submitting}
            className="px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50 disabled:opacity-60"
          >
            Cancel
          </button>
          <button
            onClick={handleConfirm}
            disabled={submitting || !resolvedReplacementId || !newPrice || Number.isNaN(parsedPrice) || parsedPrice <= 0}
            className="px-4 py-2 text-sm text-white bg-blue-600 rounded-lg hover:bg-blue-700 disabled:opacity-60"
          >
            {submitting ? "Saving..." : mode === "complete" ? "Complete Replacement" : "Replace Return"}
          </button>
        </div>
      </div>
    </div>
  );
}

export default ReplaceReturnModal;
