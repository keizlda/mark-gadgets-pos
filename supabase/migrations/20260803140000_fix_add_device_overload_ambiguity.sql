-- add_device ended up with two overloads live in the database (with and
-- without p_condition) — the same "Could not choose the best candidate
-- function" problem the 20260731020000 migration already fixed once for
-- add_device/update_device, but the cleanup drop in
-- 20260731060000_add_device_condition.sql apparently didn't fully take for
-- add_device. Symptom: adding a device via the app returns no error and
-- shows "Device saved", but the row was never actually inserted, because
-- PostgREST can't resolve which overload to call.
--
-- Rather than guess the exact stale signature again, this drops every
-- existing overload of both functions dynamically, then recreates the one
-- correct current version of each (matching schema.sql).
do $$
declare
  rec record;
begin
  for rec in
    select oid::regprocedure as sig
    from pg_proc
    where proname in ('add_device', 'update_device')
      and pronamespace = 'public'::regnamespace
  loop
    execute format('drop function %s', rec.sig);
  end loop;
end $$;

create function public.add_device(
  p_batch_code text,
  p_device_name text,
  p_category text,
  p_storage text,
  p_color text,
  p_status text,
  p_supplier_name text,
  p_price numeric,
  p_notes text,
  p_date_added timestamptz,
  p_issue_description text default null,
  p_bulk_order_shell_id uuid default null,
  p_date_arrived timestamptz default null,
  p_purchase_price numeric default null,
  p_condition text default null
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_supplier_id uuid;
  v_device_id uuid;
  v_linked_count int;
  v_quantity_expected int;
begin
  if p_supplier_name is null or p_supplier_name = '' then
    v_supplier_id := null;
  else
    select id into v_supplier_id from public.suppliers where name = p_supplier_name;
  end if;

  insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, selling_price, purchase_price, condition, notes, date_added, bulk_order_shell_id, date_arrived)
  values (p_batch_code, p_device_name, p_category, p_storage, p_color, p_status, v_supplier_id, p_price, p_purchase_price, p_condition, p_notes, p_date_added, p_bulk_order_shell_id, p_date_arrived)
  returning id into v_device_id;

  if p_status = 'Supplier Defective' and p_issue_description is not null then
    insert into public.supplier_defective_records (device_id, supplier_id, issue_description)
    values (v_device_id, v_supplier_id, p_issue_description);
  end if;

  if p_bulk_order_shell_id is not null then
    select count(*) into v_linked_count from public.devices where bulk_order_shell_id = p_bulk_order_shell_id;
    select quantity_expected into v_quantity_expected from public.bulk_order_shells where id = p_bulk_order_shell_id;
    if v_linked_count >= v_quantity_expected then
      update public.bulk_order_shells set status = 'Completed' where id = p_bulk_order_shell_id;
    end if;
  end if;

  return v_device_id;
end;
$$;

create function public.update_device(
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

  if v_previous_status = 'Sold' and p_status = 'Available' then
    select array_agg(distinct sale_id) into v_affected_sale_ids
    from public.sale_items where device_id = p_id;

    delete from public.sale_items where device_id = p_id;

    delete from public.sales
    where id = any(v_affected_sale_ids)
      and id not in (select distinct sale_id from public.sale_items);
  end if;

  if v_previous_status = 'Reserved' and p_status <> 'Reserved' then
    update public.reservations
    set status = 'Cancelled'
    where device_id = p_id and status in ('Active', 'Expiring Soon');
  end if;
end;
$$;
