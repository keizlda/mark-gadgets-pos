-- Fixes a real data-integrity bug: editing a device's status directly
-- (Edit Device) had zero awareness of anything else referencing that
-- device. Concretely:
--   1. Selling a unit, then editing it back to "Available", left the
--      original sale still showing (and counting toward revenue) in Sales
--      History/Reports/Financial — the device looked unsold and sold at
--      the same time.
--   2. Editing a device away from "Reserved" never cancelled the backing
--      reservation row, leaving it "Active" against a device that's no
--      longer actually held for anyone.
--
-- Fix: when update_device sees status go Sold -> Available specifically
-- (not Sold -> Customer Returned/Supplier Defective — those are real
-- returns that intentionally still count as revenue per this app's
-- "no cash refunds" design), it marks the device's completed sale(s) as
-- Refunded instead of leaving them looking Completed. The 'Refunded'
-- sales.status value and its exclusion from totals already existed in
-- SalesHistory.jsx — it was simply never triggered anywhere. Financial
-- and Reports get the same exclusion added in this same change (in the
-- app code, not this file).
--
-- Same signature as before (no new parameters), so this is a plain
-- create-or-replace — no overload-drop needed.
-- Run this in the Supabase SQL Editor.

create or replace function public.update_device(
  p_id uuid,
  p_batch_code text,
  p_device_name text,
  p_category text,
  p_storage text,
  p_color text,
  p_status text,
  p_supplier_name text,
  p_price numeric,
  p_notes text,
  p_issue_description text default null,
  p_purchase_price numeric default null,
  p_condition text default null
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_supplier_id uuid;
  v_previous_status text;
begin
  select status into v_previous_status from public.devices where id = p_id;

  if p_supplier_name is null or p_supplier_name = '' then
    v_supplier_id := null;
  else
    select id into v_supplier_id from public.suppliers where name = p_supplier_name;
  end if;

  update public.devices
  set batch_code = p_batch_code,
      device_name = p_device_name,
      category = p_category,
      storage = p_storage,
      color = p_color,
      status = p_status,
      supplier_id = v_supplier_id,
      selling_price = p_price,
      purchase_price = p_purchase_price,
      condition = p_condition,
      notes = p_notes
  where id = p_id;

  if p_status = 'Supplier Defective' and v_previous_status <> 'Supplier Defective' and p_issue_description is not null then
    insert into public.supplier_defective_records (device_id, supplier_id, issue_description)
    values (p_id, v_supplier_id, p_issue_description);
  end if;

  -- Bug fix: Sold -> Available means the sale is being undone (taking the
  -- unit back into sellable stock), not a return — refund the sale so it
  -- stops counting as revenue instead of silently persisting.
  if v_previous_status = 'Sold' and p_status = 'Available' then
    update public.sales
    set status = 'Refunded'
    where status = 'Completed'
      and id in (select sale_id from public.sale_items where device_id = p_id);
  end if;

  -- Bug fix: editing a Reserved device to any other status never
  -- cancelled the reservation behind it, leaving an orphaned Active
  -- reservation pointing at a device no longer actually held for anyone.
  if v_previous_status = 'Reserved' and p_status <> 'Reserved' then
    update public.reservations
    set status = 'Cancelled'
    where device_id = p_id and status in ('Active', 'Expiring Soon');
  end if;
end;
$$;
