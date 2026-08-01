-- Lets an admin correct a sale after the fact from Sales History — customer
-- info, the price this specific unit sold for, notes, financing/reference
-- detail, and the sale/received dates. Payment method itself and which
-- device was sold stay locked (changing either is really a delete + a new
-- sale, not an edit).
--
-- customer_name/phone/notes/reference_number/down_payment/balance/sold_at
-- all live once per sale (not per unit) — editing any of them from one row
-- of a Bulk order updates every sibling row in that same order, since
-- they all share the same sales record. price_at_sale and date_added are
-- per-device, so only the specific unit being edited is touched.
--
-- total_amount is recalculated from every sale_item under that sale after
-- the price update, so a Bulk order's total stays correct even though only
-- one of its units changed.
--
-- Run this in the Supabase SQL Editor.

create function public.edit_sale(
  p_sale_item_id uuid,
  p_customer_name text,
  p_customer_phone text,
  p_notes text,
  p_reference_number text,
  p_down_payment numeric,
  p_balance numeric,
  p_price_at_sale numeric,
  p_sold_at timestamptz,
  p_date_added timestamptz
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_sale_id uuid;
  v_device_id uuid;
begin
  select sale_id, device_id into v_sale_id, v_device_id
  from public.sale_items where id = p_sale_item_id;

  update public.sale_items
  set price_at_sale = p_price_at_sale
  where id = p_sale_item_id;

  update public.sales
  set customer_name = p_customer_name,
      customer_phone = p_customer_phone,
      notes = p_notes,
      reference_number = p_reference_number,
      down_payment = p_down_payment,
      balance = p_balance,
      sold_at = p_sold_at,
      total_amount = (
        select sum(price_at_sale * quantity) from public.sale_items where sale_id = v_sale_id
      )
  where id = v_sale_id;

  update public.devices
  set date_added = p_date_added
  where id = v_device_id;
end;
$$;

grant execute on function public.edit_sale(uuid, text, text, text, text, numeric, numeric, numeric, timestamptz, timestamptz) to authenticated;
