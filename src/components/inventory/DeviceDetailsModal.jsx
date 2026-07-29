import { useState, useEffect } from "react";
import { X } from "lucide-react";
import { getDeviceSaleDate } from "../../services/salesService";
import { formatDate, formatTime } from "../../utils/datetime";

const statusStyles = {
  Sold: "bg-blue-100 text-blue-600",
  Reserved: "bg-orange-100 text-orange-600",
  Available: "bg-green-100 text-green-600",
  "Customer Returned": "bg-purple-100 text-purple-600",
  "Supplier Defective": "bg-red-100 text-red-600",
  Returned: "bg-purple-100 text-purple-600",
};

function Row({ label, children }) {
  return (
    <div className="flex justify-between gap-4 py-2 border-b border-gray-50 last:border-0">
      <span className="text-sm text-gray-500">{label}</span>
      <span className="text-sm text-gray-800 text-right">{children}</span>
    </div>
  );
}

function DeviceDetailsModal({ device, onClose }) {
  const [saleDate, setSaleDate] = useState(undefined); // undefined = loading, null = never sold

  useEffect(() => {
    if (!device) return;
    setSaleDate(undefined);
    getDeviceSaleDate(device.id).then(setSaleDate);
  }, [device]);

  if (!device) return null;

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl w-full max-w-md shadow-xl">
        <div className="flex items-center justify-between px-5 py-4 border-b border-gray-100">
          <p className="font-semibold text-gray-800">Device Details</p>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
            <X size={18} />
          </button>
        </div>

        <div className="px-5 py-4">
          <Row label="Batch Code">{device.batchCode}</Row>
          <Row label="Device">{device.device}</Row>
          <Row label="Category">{device.category}</Row>
          <Row label="Storage">{device.storage || "—"}</Row>
          <Row label="Color">{device.color || "—"}</Row>
          <Row label="Supplier">{device.supplier || "—"}</Row>
          <Row label="Selling Price">₱{Number(device.price || 0).toLocaleString()}</Row>
          {device.purchasePrice != null && (
            <Row label="Purchase Price">₱{Number(device.purchasePrice).toLocaleString()}</Row>
          )}
          <Row label="Status">
            <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${statusStyles[device.status] || ""}`}>
              {device.status}
            </span>
          </Row>
          <Row label="Date Sold">
            {saleDate === undefined ? "Loading..." : saleDate ? `${formatDate(saleDate)} ${formatTime(saleDate)}` : "—"}
          </Row>
          <Row label="Date Added">
            {device.dateAdded} <span className="text-gray-400">{device.time}</span>
          </Row>
          {device.notes && <Row label="Notes">{device.notes}</Row>}
        </div>

        <div className="px-5 py-4 border-t border-gray-100 flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}

export default DeviceDetailsModal;
