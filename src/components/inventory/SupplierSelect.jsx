import { useState, useEffect, useCallback } from "react";
import { getSuppliers } from "../../services/referenceService";
import AddSupplierModal from "./AddSupplierModal";

const ADD_NEW = "__add_new__";

// Shared supplier <select> — lets staff add a brand-new supplier inline
// (owner picks up new suppliers occasionally) without leaving the form.
function SupplierSelect({ value, onChange, required = false, placeholder = "Select supplier" }) {
  const [suppliers, setSuppliers] = useState([]);
  const [showAddModal, setShowAddModal] = useState(false);

  const loadSuppliers = useCallback(() => {
    getSuppliers().then(setSuppliers);
  }, []);
  useEffect(() => {
    loadSuppliers();
  }, [loadSuppliers]);

  const handleChange = (e) => {
    if (e.target.value === ADD_NEW) {
      setShowAddModal(true);
      return;
    }
    onChange(e.target.value);
  };

  const handleAdded = (name) => {
    setShowAddModal(false);
    loadSuppliers();
    onChange(name);
  };

  return (
    <>
      <select
        value={value}
        onChange={handleChange}
        required={required}
        className="w-full border border-gray-200 rounded-lg text-sm px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        <option value="">{placeholder}</option>
        {suppliers.map((s) => <option key={s} value={s}>{s}</option>)}
        <option value={ADD_NEW}>+ Add New Supplier</option>
      </select>

      {showAddModal && (
        <AddSupplierModal onClose={() => setShowAddModal(false)} onAdded={handleAdded} />
      )}
    </>
  );
}

export default SupplierSelect;
