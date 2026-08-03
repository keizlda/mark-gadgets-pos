import { supabase } from "../lib/supabaseClient";

// CGN's own resale of units we already sold them — a separate business
// event from our own sales, tracked in its own table (see cgn_resales in
// schema.sql) rather than another devices/sales row.
export async function getCgnResales() {
  const { data, error } = await supabase
    .from("cgn_resales")
    .select("id, sale_date, device_name, capital, disposal_price, supplier_note, batch_code")
    .order("sale_date", { ascending: false });

  if (error) throw error;

  return data.map((r) => ({
    id: r.id,
    date: r.sale_date,
    deviceName: r.device_name,
    capital: r.capital,
    disposalPrice: r.disposal_price,
    profit: r.disposal_price - r.capital,
    supplierNote: r.supplier_note,
    batchCode: r.batch_code,
  }));
}

export async function addCgnResale({ date, deviceName, capital, disposalPrice, supplierNote, batchCode }) {
  const { error } = await supabase.from("cgn_resales").insert({
    sale_date: date,
    device_name: deviceName,
    capital,
    disposal_price: disposalPrice,
    supplier_note: supplierNote || null,
    batch_code: batchCode || null,
  });
  if (error) throw error;
}

export async function deleteCgnResale(id) {
  const { error } = await supabase.from("cgn_resales").delete().eq("id", id);
  if (error) throw error;
}
