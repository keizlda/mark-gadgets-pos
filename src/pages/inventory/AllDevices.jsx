import { useState, useMemo } from "react";
import { Download } from "lucide-react";
import InventoryStats from "../../components/inventory/InventoryStats";
import FilterBar from "../../components/inventory/FilterBar";
import DeviceTable from "../../components/inventory/DeviceTable";
import { allDevices } from "../../data/mockData";

function AllDevices() {
  const [filters, setFilters] = useState({
    search: "",
    category: "All",
    status: "All",
    storage: "All",
    color: "All",
  });
  const [appliedFilters, setAppliedFilters] = useState(filters);

  const handleClear = () => {
    const cleared = { search: "", category: "All", status: "All", storage: "All", color: "All" };
    setFilters(cleared);
    setAppliedFilters(cleared);
  };

  const filtered = useMemo(() => {
    return allDevices.filter((d) => {
      const f = appliedFilters;
      const matchesSearch =
        !f.search ||
        d.batchCode.toLowerCase().includes(f.search.toLowerCase()) ||
        d.serial.toLowerCase().includes(f.search.toLowerCase()) ||
        d.device.toLowerCase().includes(f.search.toLowerCase());
      return (
        matchesSearch &&
        (f.category === "All" || d.category === f.category) &&
        (f.status === "All" || d.status === f.status) &&
        (f.storage === "All" || d.storage === f.storage) &&
        (f.color === "All" || d.color === f.color)
      );
    });
  }, [appliedFilters]);

  const stats = {
    total: allDevices.length,
    available: allDevices.filter((d) => d.status === "Available").length,
    reserved: allDevices.filter((d) => d.status === "Reserved").length,
    defective: allDevices.filter((d) => d.status === "Supplier Defective").length,
    returned: allDevices.filter((d) => d.status === "Returned" || d.status === "Customer Returned").length,
    lowStock: 4,
  };

  return (
    <div className="space-y-4">
      <FilterBar
        filters={filters}
        setFilters={setFilters}
        onApply={() => setAppliedFilters(filters)}
        onClear={handleClear}
      />

      <InventoryStats {...stats} />

      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <div className="flex items-center justify-between mb-4">
          <p className="font-medium text-gray-800">Devices List</p>
          <button className="flex items-center gap-2 text-sm text-gray-600 border border-gray-200 px-3 py-1.5 rounded-lg hover:bg-gray-50">
            <Download size={14} />
            Export
          </button>
        </div>

        <DeviceTable devices={filtered} />
      </div>
    </div>
  );
}

export default AllDevices;