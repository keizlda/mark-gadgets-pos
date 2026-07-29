import { supabase } from "../lib/supabaseClient";

// A shipment placeholder — logged the night a bulk shipment arrives (before
// staff have time to enter every individual unit), then linked from Add
// Device the next morning as each unit gets its own batch code.
export async function createBulkOrderShell({
  supplierName,
  deviceName,
  storage,
  color,
  quantityExpected,
  dateArrived,
  notes,
}) {
  let supplierId = null;
  if (supplierName) {
    const { data: supplier, error: supplierError } = await supabase
      .from("suppliers")
      .select("id")
      .eq("name", supplierName)
      .single();
    if (supplierError) throw supplierError;
    supplierId = supplier.id;
  }

  const { error } = await supabase.from("bulk_order_shells").insert({
    supplier_id: supplierId,
    device_name: deviceName,
    storage: storage || null,
    color: color || null,
    quantity_expected: quantityExpected,
    date_arrived: dateArrived,
    notes: notes || null,
  });
  if (error) throw error;
}

function mapShellProgress(s) {
  return {
    id: s.id,
    supplierName: s.supplier_name,
    deviceName: s.device_name,
    storage: s.storage,
    color: s.color,
    quantityExpected: s.quantity_expected,
    dateArrived: s.date_arrived,
    linkedCount: s.linked_count,
    status: s.status,
  };
}

// Pending shells with how many units have been linked to each so far — for
// Add Device's "Link to Pending Shipment" dropdown and the All Devices
// progress display.
export async function getPendingShellsWithProgress() {
  const { data, error } = await supabase
    .from("bulk_order_shell_progress_view")
    .select("*")
    .eq("status", "Pending")
    .order("date_arrived", { ascending: false });

  if (error) throw error;
  return data.map(mapShellProgress);
}

// Every shell (Pending and Completed) with its progress — used to group the
// All Devices table into one row per shipment (supplier + day) instead of
// one row per unit, when the "Bulk shipment units only" filter is on.
export async function getAllShellsWithProgress() {
  const { data, error } = await supabase
    .from("bulk_order_shell_progress_view")
    .select("*")
    .order("date_arrived", { ascending: false });

  if (error) throw error;
  return data.map(mapShellProgress);
}
