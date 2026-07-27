import { Search, Filter } from "lucide-react";
import { deviceCategories, deviceStorages, deviceColors } from "../../data/mockData";

function FilterBar({ filters, setFilters, onApply, onClear }) {
  const statuses = ["Available", "Sold", "Reserved", "Customer Returned", "Supplier Defective", "Returned"];

  const update = (key, value) => setFilters({ ...filters, [key]: value });

  return (
    <div className="bg-white rounded-xl border border-gray-200 p-5">
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
        <div>
          <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
            Search Device (Batch Code / Serial Number / IMEI)
          </label>
          <div className="relative">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              value={filters.search}
              onChange={(e) => update("search", e.target.value)}
              placeholder="Type batch code, serial number, or IMEI..."
              className="w-full pl-8 pr-3 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>

        <div>
          <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
            Category
          </label>
          <select
            value={filters.category}
            onChange={(e) => update("category", e.target.value)}
            className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="All">All Categories</option>
            {deviceCategories.map((c) => <option key={c} value={c}>{c}</option>)}
          </select>
        </div>

        <div>
          <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
            Status
          </label>
          <select
            value={filters.status}
            onChange={(e) => update("status", e.target.value)}
            className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="All">All Status</option>
            {statuses.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>

        <div>
          <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
            Storage
          </label>
          <select
            value={filters.storage}
            onChange={(e) => update("storage", e.target.value)}
            className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="All">All Storage</option>
            {deviceStorages.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>

        <div>
          <label className="flex items-end min-h-[2.25rem] text-xs font-medium text-gray-500 mb-1.5">
            Color
          </label>
          <select
            value={filters.color}
            onChange={(e) => update("color", e.target.value)}
            className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="All">All Colors</option>
            {deviceColors.map((c) => <option key={c} value={c}>{c}</option>)}
          </select>
        </div>
      </div>

      <div className="flex justify-end gap-3 mt-4">
        <button
          onClick={onClear}
          className="px-4 py-2 text-sm text-gray-600 border border-gray-200 rounded-lg hover:bg-gray-50"
        >
          Clear
        </button>
        <button
          onClick={onApply}
          className="flex items-center gap-2 px-4 py-2 text-sm text-white bg-blue-600 rounded-lg hover:bg-blue-700"
        >
          <Filter size={14} />
          Apply Filters
        </button>
      </div>
    </div>
  );
}

export default FilterBar;