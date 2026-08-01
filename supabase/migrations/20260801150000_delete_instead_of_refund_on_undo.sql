-- Supersedes the "mark Refunded" approach from
-- 20260801130000_fix_device_status_edit_integrity.sql — clarified
-- requirement: an undone sale should disappear from Sales History/Reports/
-- Financial entirely, as if it had never been sold, not just be excluded
-- from totals while still sitting there tagged "Refunded". Also fixes a
-- real scoping bug in that first version: it marked the ENTIRE sale
-- Refunded, which for a Bulk order (multiple units, one sales row) would
-- have wiped out every other unit in that same order too, not just the one
-- device actually being edited.
--
-- Fix: delete the specific sale_item(s) for that device instead of
-- touching sales.status. A sale that's left with zero sale_items after
-- that (a single-item sale, or the last remaining item of a bulk one) gets
-- deleted too, so nothing orphaned is left behind. Siblings in a bulk
-- order that weren't touched are unaffected.
--
-- Also adds delete_sale_item — the same operation, callable directly from
-- a Sales History row's Delete action, without going through Edit Device.
--
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
  v_affected_sale_ids uuid[];
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

  -- Sold -> Available means the sale is being undone (taking the unit
  -- back into sellable stock), not a return — the sale_item for this
  -- device is deleted outright so it's gone from Sales History/Reports/
  -- Financial entirely, same as if it were never sold. Scoped to just
  -- this device's own sale_item(s), so a bulk order's other units are
  -- untouched.
  if v_previous_status = 'Sold' and p_status = 'Available' then
    select array_agg(distinct sale_id) into v_affected_sale_ids
    from public.sale_items where device_id = p_id;

    delete from public.sale_items where device_id = p_id;

    delete from public.sales
    where id = any(v_affected_sale_ids)
      and id not in (select distinct sale_id from public.sale_items);
  end if;

  -- Editing a Reserved device to any other status cancels the reservation
  -- behind it, so it doesn't stay Active against a device no longer held
  -- for anyone.
  if v_previous_status = 'Reserved' and p_status <> 'Reserved' then
    update public.reservations
    set status = 'Cancelled'
    where device_id = p_id and status in ('Active', 'Expiring Soon');
  end if;
end;
$$;

-- Deletes one unit's sale_item directly (Sales History's Delete action) —
-- same "undo this sale" operation as the Sold -> Available path above,
-- just triggered from Sales History instead of Edit Device. Frees the
-- device back to Available and cleans up the parent sale if this was its
-- last remaining item.
create function public.delete_sale_item(p_sale_item_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_device_id uuid;
  v_sale_id uuid;
begin
  select device_id, sale_id into v_device_id, v_sale_id
  from public.sale_items where id = p_sale_item_id;

  delete from public.sale_items where id = p_sale_item_id;

  update public.devices set status = 'Available' where id = v_device_id and status = 'Sold';

  delete from public.sales
  where id = v_sale_id
    and id not in (select distinct sale_id from public.sale_items);
end;
$$;
