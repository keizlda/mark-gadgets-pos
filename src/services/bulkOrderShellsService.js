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

// Pending shells with how many units have been linked to each so far — for
// Add Device's "Link to Pending Shipment" dropdown.
export async function getPendingShellsWithProgress() {
  const { data, error } = await supabase
    .from("bulk_order_shell_progress_view")
    .select("*")
    .eq("status", "Pending")
    .order("date_arrived", { ascending: false });

  if (error) throw error;

  return data.map((s) => ({
    id: s.id,
    deviceName: s.device_name,
    storage: s.storage,
    color: s.color,
    quantityExpected: s.quantity_expected,
    dateArrived: s.date_arrived,
    linkedCount: s.linked_count,
  }));
}
