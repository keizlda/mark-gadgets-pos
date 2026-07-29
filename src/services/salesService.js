import { supabase } from "../lib/supabaseClient";
import { formatDate, formatTime } from "../utils/datetime";

export async function getSalesHistory() {
  const { data, error } = await supabase.from("sale_items").select(`
    id,
    price_at_sale,
    quantity,
    sales:sale_id (
      customer_name,
      customer_phone,
      payment_method,
      status,
      sold_at,
      profiles:salesperson_id ( name )
    ),
    devices:device_id (
      id,
      batch_code,
      device_name,
      category,
      storage,
      color,
      status
    )
  `);

  if (error) throw error;

  return data
    .slice()
    .sort((a, b) => new Date(b.sales?.sold_at) - new Date(a.sales?.sold_at))
    .map((item) => ({
      saleItemId: item.id,
      deviceId: item.devices?.id,
      batchCode: item.devices?.batch_code,
      date: formatDate(item.sales?.sold_at),
      time: formatTime(item.sales?.sold_at),
      customer: item.sales?.customer_name,
      phone: item.sales?.customer_phone,
      device: item.devices?.device_name,
      category: item.devices?.category,
      storage: item.devices?.storage,
      color: item.devices?.color,
      salesperson: item.sales?.profiles?.name,
      payment: item.sales?.payment_method,
      total: item.price_at_sale * item.quantity,
      // The device's own status wins when it's since been returned — the
      // sale itself is still "Completed" (no refund happened), but this row
      // represents that specific unit, which is no longer with the customer.
      // A replaced return sends the original unit straight to Supplier
      // Defective, so that status also counts as "Returned" here.
      status:
        item.devices?.status === "Customer Returned" || item.devices?.status === "Supplier Defective"
          ? "Returned"
          : item.sales?.status,
    }));
}

// cartItems: [{ id (device uuid), price }]. Each cart line is one specific
// serialized device, so quantity per line item is always 1. Runs as a single
// atomic RPC (see process_sale in schema.sql) so a dropped connection can't
// leave a sale recorded with its devices still "Available".
export async function processSale({ customerName, paymentMethod, referenceNumber, notes, discount, cartItems }) {
  const {
    data: { session },
  } = await supabase.auth.getSession();

  const subtotal = cartItems.reduce((sum, item) => sum + item.price, 0);
  const total = Math.max(0, subtotal - (Number(discount) || 0));

  const { error } = await supabase.rpc("process_sale", {
    p_customer_name: customerName || null,
    p_salesperson_id: session?.user?.id || null,
    p_payment_method: paymentMethod,
    p_reference_number: referenceNumber || null,
    p_notes: notes || null,
    p_total_amount: total,
    p_cart_items: cartItems.map((item) => ({ device_id: item.id, price: item.price })),
  });
  if (error) throw error;
}

// Most recent sale date for a device, if it's ever been sold — used by
// Device Details to show "Date Sold" without joining sales onto every
// device in the main list.
export async function getDeviceSaleDate(deviceId) {
  const { data, error } = await supabase
    .from("sale_items")
    .select("sales:sale_id ( sold_at )")
    .eq("device_id", deviceId);

  if (error) throw error;

  const dates = data.map((d) => d.sales?.sold_at).filter(Boolean);
  if (dates.length === 0) return null;
  return dates.sort((a, b) => new Date(b) - new Date(a))[0];
}

export async function getSalesThisMonth() {
  const { data, error } = await supabase
    .from("sales_by_month_view")
    .select("month, sales, month_start")
    .order("month_start");

  if (error) throw error;

  return data.map(({ month, sales }) => ({ month, sales }));
}
