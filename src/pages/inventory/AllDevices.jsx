import { useState, useEffect, useCallback, useMemo } from "react";
import { Download, PackagePlus } from "lucide-react";
import InventoryStats from "../../components/inventory/InventoryStats";
import FilterBar from "../../components/inventory/FilterBar";
import DeviceTable from "../../components/inventory/DeviceTable";
import DeviceDetailsModal from "../../components/inventory/DeviceDetailsModal";
import EditDeviceModal from "../../components/inventory/EditDeviceModal";
import LogShipmentArrivalModal from "../../components/inventory/LogShipmentArrivalModal";
import PendingShipmentsCard from "../../components/inventory/PendingShipmentsCard";
import { downloadCsv } from "../../utils/csv";
import { getDeviceKind } from "../../utils/deviceKind";
import { useServiceData } from "../../hooks/useServiceData";
import { getAllDevices, getLowStockItems, deleteDevice } from "../../services/inventoryService";
import { getPendingShellsWithProgress } from "../../services/bulkOrderShellsService";

const csvColumns = [
  { label: "Batch Code", value: (r) => r.batchCode },
  { label: "Device", value: (r) => r.device },
  { label: "Category", value: (r) => r.category },
  { label: "Storage", value: (r) => r.storage },
  { label: "Color", value: (r) => r.color },
  { label: "Status", value: (r) => r.status },
  { label: "Date Added", value: (r) => r.dateAdded },
  { label: "Time", value: (r) => r.time },
];

function AllDevices() {
  const lowStockItems = useServiceData(getLowStockItems, []);

  const [allDevices, setAllDevices] = useState([]);
  const loadDevices = useCallback(() => {
    getAllDevices().then(setAllDevices);
  }, []);
  useEffect(() => {
    loadDevices();
  }, [loadDevices]);

  const [filters, setFilters] = useState({
    search: "",
    category: "All",
    status: "All",
    storage: "All",
    kind: "All",
    supplier: "All",
    bulkShipmentOnly: false,
  });
  const [appliedFilters, setAppliedFilters] = useState(filters);
  const [viewDevice, setViewDevice] = useState(null);
  const [editDevice, setEditDevice] = useState(null);
  const [showLogShipment, setShowLogShipment] = useState(false);

  const [pendingShells, setPendingShells] = useState([]);
  const loadPendingShells = useCallback(() => {
    getPendingShellsWithProgress().then(setPendingShells);
  }, []);
  useEffect(() => {
    loadPendingShells();
  }, [loadPendingShells]);

  const handleShipmentLogged = () => {
    setShowLogShipment(false);
    loadPendingShells();
    alert("Shipment logged. Link each unit to it from Add Device as they're entered.");
  };

  const handleEditSaved = () => {
    setEditDevice(null);
    loadDevices();
  };

  const handleDelete = async (device) => {
    if (!window.confirm(`Delete ${device.batchCode} — ${device.device}? This cannot be undone.`)) return;
    try {
      await deleteDevice(device.id);
      loadDevices();
    } catch (err) {
      if (err.code === "23503") {
        alert("Can't delete this device — it has sales, reservation, or return history. Consider changing its status instead.");
      } else {
        alert(err.message || "Failed to delete device. Please try again.");
      }
    }
  };

  const handleClear = () => {
    const cleared = {
      search: "",
      category: "All",
      status: "All",
      storage: "All",
      kind: "All",
      supplier: "All",
      bulkShipmentOnly: false,
    };
    setFilters(cleared);
    setAppliedFilters(cleared);
  };

  const kinds = useMemo(() => {
    return [...new Set(allDevices.map((d) => getDeviceKind(d.device)))].sort();
  }, [allDevices]);

  const filtered = useMemo(() => {
    return allDevices.filter((d) => {
      const f = appliedFilters;
      const matchesSearch =
        !f.search ||
        d.batchCode.toLowerCase().includes(f.search.toLowerCase()) ||
        d.device.toLowerCase().includes(f.search.toLowerCase());
      return (
        matchesSearch &&
        (f.category === "All" || d.category === f.category) &&
        (f.status === "All" || d.status === f.status) &&
        (f.storage === "All" || d.storage === f.storage) &&
        (f.kind === "All" || getDeviceKind(d.device) === f.kind) &&
        (f.supplier === "All" || d.supplier === f.supplier) &&
        (!f.bulkShipmentOnly || !!d.bulkOrderShellId)
      );
    });
  }, [appliedFilters, allDevices]);

  const stats = {
    total: allDevices.length,
    available: allDevices.filter((d) => d.status === "Available").length,
    reserved: allDevices.filter((d) => d.status === "Reserved").length,
    defective: allDevices.filter((d) => d.status === "Supplier Defective").length,
    returned: allDevices.filter((d) => d.status === "Returned" || d.status === "Customer Returned").length,
    lowStock: lowStockItems.length,
  };

  return (
    <div className="space-y-4">
      <FilterBar
        filters={filters}
        setFilters={setFilters}
        onApply={() => setAppliedFilters(filters)}
        onClear={handleClear}
        kinds={kinds}
      />

      <InventoryStats {...stats} />

      <PendingShipmentsCard shells={pendingShells} />

      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <div className="flex items-center justify-between mb-4">
          <p className="font-medium text-gray-800">Devices List</p>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setShowLogShipment(true)}
              className="flex items-center gap-2 text-sm text-gray-600 border border-gray-200 px-3 py-1.5 rounded-lg hover:bg-gray-50"
            >
              <PackagePlus size={14} />
              Log Shipment Arrival
            </button>
            <button
              onClick={() => downloadCsv("all-devices.csv", filtered, csvColumns)}
              className="flex items-center gap-2 text-sm text-gray-600 border border-gray-200 px-3 py-1.5 rounded-lg hover:bg-gray-50"
            >
              <Download size={14} />
              Export
            </button>
          </div>
        </div>

        <DeviceTable
          devices={filtered}
          onView={setViewDevice}
          onEdit={setEditDevice}
          onDelete={handleDelete}
        />
      </div>

      {viewDevice && <DeviceDetailsModal device={viewDevice} onClose={() => setViewDevice(null)} />}

      {editDevice && (
        <EditDeviceModal device={editDevice} onClose={() => setEditDevice(null)} onSaved={handleEditSaved} />
      )}

      {showLogShipment && (
        <LogShipmentArrivalModal onClose={() => setShowLogShipment(false)} onCreated={handleShipmentLogged} />
      )}
    </div>
  );
}

export default AllDevices;