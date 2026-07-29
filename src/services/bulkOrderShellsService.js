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
