import { useState } from "react";
import { Info, ClipboardList, Fingerprint, Eye, Calendar, Apple } from "lucide-react";
import { productCatalog, suppliers } from "../../data/mockData";

const statusOptions = [
  { label: "Available", color: "bg-green-500" },
  { label: "Reserved", color: "bg-orange-500" },
  { label: "Supplier Defective", color: "bg-red-500" },
];

function AddDevice() {
  const categories = Object.keys(productCatalog);

  const [form, setForm] = useState({
    category: "iPhone",
    model: "",
    color: "",
    storage: "",
    supplier: "",
    dateReceived: new Date().toISOString().slice(0, 10),
    batchCode: "",
    serial: "",
    imei: "",
    price: "",
    status: "Available",
    remarks: "",
  });

  const catalog = productCatalog[form.category];

  const update = (key, value) => setForm((f) => ({ ...f, [key]: value }));

  const handleCategoryChange = (category) => {
    setForm((f) => ({
      ...f,
      category,
      model: "",
      color: "",
      storage: "",
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("New device:", form);
    alert("Device saved (mock — no backend connected yet).");
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {/* Info banner */}
      <div className="bg-blue-50 border border-blue-100 rounded-xl p-4 flex items-start gap-3">
        <Info size={18} className="text-blue-500 mt-0.5 flex-shrink-0" />
        <div>
          <p className="text-sm font-medium text-blue-900">
            Register a new Apple device into the inventory.
          </p>
          <p className="text-xs text-blue-500">All fields marked with * are required.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Column 1: Device Information */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <div className="flex items-center gap-2 mb-4">
            <ClipboardList size={16} className="text-blue-500" />
            <p className="text-sm font-semibold text-gray-700">DEVICE INFORMATION</p>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Product Category <span className="text-red-500">*</span>
              </label>
              <select
                value={form.category}
                onChange={(e) => handleCategoryChange(e.target.value)}
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {categories.map((c) => <option key={c} value={c}>{c}</option>)}
              </select>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">Brand</label>
              <input
                type="text"
                value={catalog.brand}
                disabled
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 bg-gray-50 text-gray-400"
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Model <span className="text-red-500">*</span>
              </label>
              <select
                value={form.model}
                onChange={(e) => update("model", e.target.value)}
                required
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select model</option>
                {catalog.models.map((m) => <option key={m} value={m}>{m}</option>)}
              </select>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Color <span className="text-red-500">*</span>
              </label>
              <select
                value={form.color}
                onChange={(e) => update("color", e.target.value)}
                required
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select color</option>
                {catalog.colors.map((c) => <option key={c} value={c}>{c}</option>)}
              </select>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Storage <span className="text-red-500">*</span>
              </label>
              <select
                value={form.storage}
                onChange={(e) => update("storage", e.target.value)}
                required
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select storage</option>
                {catalog.storages.map((s) => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Supplier <span className="text-red-500">*</span>
              </label>
              <select
                value={form.supplier}
                onChange={(e) => update("supplier", e.target.value)}
                required
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select supplier</option>
                {suppliers.map((s) => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">Date Received</label>
              <div className="relative">
                <Calendar size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                <input
                  type="date"
                  value={form.dateReceived}
                  onChange={(e) => update("dateReceived", e.target.value)}
                  className="w-full border border-gray-200 rounded-lg text-sm pl-8 pr-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Column 2: Identification & Pricing */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <div className="flex items-center gap-2 mb-4">
            <Fingerprint size={16} className="text-blue-500" />
            <p className="text-sm font-semibold text-gray-700">IDENTIFICATION & PRICING</p>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Batch Code <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                value={form.batchCode}
                onChange={(e) => update("batchCode", e.target.value)}
                required
                placeholder="070926-001"
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p className="text-xs text-gray-400 mt-1">Format example: 070926-001</p>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Serial Number <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                value={form.serial}
                onChange={(e) => update("serial", e.target.value)}
                required
                placeholder="MY2Q3HN7XK"
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">IMEI (iPhone Only)</label>
              <input
                type="text"
                value={form.imei}
                onChange={(e) => update("imei", e.target.value)}
                placeholder="356742385923458"
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p className="text-xs text-gray-400 mt-1">15 digit IMEI number</p>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Base Selling Price <span className="text-red-500">*</span>
              </label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">₱</span>
                <input
                  type="number"
                  value={form.price}
                  onChange={(e) => update("price", e.target.value)}
                  required
                  placeholder="74990.00"
                  className="w-full border border-gray-200 rounded-lg text-sm pl-7 pr-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <p className="text-xs text-gray-400 mt-1">Enter the default/base selling price</p>
            </div>

            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">
                Initial Status <span className="text-red-500">*</span>
              </label>
              <select
                value={form.status}
                onChange={(e) => update("status", e.target.value)}
                className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {statusOptions.map((s) => <option key={s.label} value={s.label}>{s.label}</option>)}
              </select>
              <p className="text-xs text-gray-400 mt-1">Select the initial status of this device</p>
            </div>
          </div>
        </div>

        {/* Column 3: Product Preview */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <div className="flex items-center gap-2 mb-4">
            <Eye size={16} className="text-blue-500" />
            <p className="text-sm font-semibold text-gray-700">PRODUCT PREVIEW</p>
          </div>

          <div className="bg-gray-50 rounded-xl p-4 flex items-center gap-3 mb-4">
            <div className="w-16 h-16 bg-white rounded-lg border border-gray-200 flex items-center justify-center flex-shrink-0">
              <Apple size={28} className="text-gray-300" />
            </div>
            <div>
              <p className="text-sm font-semibold text-gray-800">{form.model || "—"}</p>
              <p className="text-xs text-gray-500">{form.storage || "—"}</p>
              <p className="text-xs text-gray-500">{form.color || "—"}</p>
            </div>
          </div>

          <div className="space-y-2.5 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-400">Category</span>
              <span className="text-gray-700">{form.category}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Model</span>
              <span className="text-gray-700">{form.model || "—"}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Color</span>
              <span className="text-gray-700">{form.color || "—"}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Storage</span>
              <span className="text-gray-700">{form.storage || "—"}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Batch Code</span>
              <span className="text-gray-700">{form.batchCode || "—"}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Serial Number</span>
              <span className="text-gray-700">{form.serial || "—"}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">IMEI</span>
              <span className="text-gray-700">{form.imei || "—"}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Base Price</span>
              <span className="text-gray-700">
                {form.price ? `₱${Number(form.price).toLocaleString()}` : "—"}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-400">Status</span>
              <span className="px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-600">
                {form.status}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Remarks */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <label className="block text-sm font-medium text-gray-700 mb-2">Remarks</label>
        <textarea
          value={form.remarks}
          onChange={(e) => update("remarks", e.target.value.slice(0, 255))}
          rows={3}
          placeholder="Enter any additional notes or remarks about this device..."
          className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
        />
        <p className="text-xs text-gray-400 text-right mt-1">{form.remarks.length} / 255</p>
      </div>

      {/* Footer actions */}
      <div className="flex justify-end gap-3">
        <button
          type="button"
          className="px-5 py-2.5 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
        >
          Cancel
        </button>
        <button
          type="submit"
          className="px-5 py-2.5 text-sm text-blue-600 border border-blue-200 rounded-lg hover:bg-blue-50"
        >
          Save & Add Another
        </button>
        <button
          type="submit"
          className="px-5 py-2.5 text-sm text-white bg-blue-600 rounded-lg hover:bg-blue-700"
        >
          Save Device
        </button>
      </div>
    </form>
  );
}

export default AddDevice;