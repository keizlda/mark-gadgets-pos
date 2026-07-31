-- Two more integrity gaps found in the same audit as
-- 20260801130000_fix_device_status_edit_integrity.sql:
--
-- 1. Starting a return (createReturn) only ever inserted a customer_returns
--    row — it never touched devices.status. The device stayed "Sold" the
--    whole time a return sat Pending, so "Customer Returned" was a status
--    value that existed in every dropdown/filter/badge in the app but was
--    never actually reachable through the real return flow.
--
-- 2. replace_return marked the replacement device "Sold" directly with no
--    sale_items row at all. That unit's purchase cost (capital) then never
--    appears anywhere in Sales History/Reports/Financial — it just
--    vanishes from all financial reporting, even though the business
--    really did spend that money and the customer really did walk out
--    with that unit. Fix: repoint the original sale_item's device_id to
--    the replacement unit (same sale, same price already paid — no cash
--    changed hands per this app's "no cash refunds" design — just now
--    correctly costed against the unit that actually left the store).
--
-- Run this in the Supabase SQL Editor.

create function public.create_return(p_sale_item_id uuid, p_reason text)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_device_id uuid;
begin
  select device_id into v_device_id from public.sale_items where id = p_sale_item_id;

  insert into public.customer_returns (sale_item_id, reason, status)
  values (p_sale_item_id, p_reason, 'Pending');

  update public.devices set status = 'Customer Returned' where id = v_device_id;
end;
$$;

create function public.reject_return(p_return_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_device_id uuid;
begin
  select device_id into v_device_id
  from public.sale_items
  where id = (select sale_item_id from public.customer_returns where id = p_return_id);

  update public.customer_returns set status = 'Rejected' where id = p_return_id;

  -- Customer keeps the unit after a rejected return, so it's still Sold —
  -- not left stuck at "Customer Returned" forever.
  update public.devices set status = 'Sold' where id = v_device_id;
end;
$$;

create or replace function public.replace_return(
  p_return_id uuid,
  p_original_device_id uuid,
  p_replacement_device_id uuid,
  p_reason text
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_supplier_id uuid;
  v_sale_item_id uuid;
begin
  select sale_item_id into v_sale_item_id from public.customer_returns where id = p_return_id;

  update public.customer_returns
  set status = 'Replaced', replacement_device_id = p_replacement_device_id
  where id = p_return_id;

  select supplier_id into v_supplier_id from public.devices where id = p_original_device_id;

  update public.devices set status = 'Supplier Defective' where id = p_original_device_id;

  insert into public.supplier_defective_records (device_id, supplier_id, issue_description)
  values (p_original_device_id, v_supplier_id, p_reason);

  update public.devices set status = 'Sold' where id = p_replacement_device_id;

  update public.sale_items set device_id = p_replacement_device_id where id = v_sale_item_id;
end;
$$;
