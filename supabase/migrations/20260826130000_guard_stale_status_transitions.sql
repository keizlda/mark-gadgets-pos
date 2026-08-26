-- System-wide audit after the replace_return incident found the same
-- root-cause pattern in four other places: an RPC changes a device's or
-- reservation's status without checking it's still in the state it
-- expects, so two staff acting on a stale, unrefreshed list (New Sale,
-- Reserved, New Reservation all fetch once and don't live-refresh) can
-- both succeed — silently double-selling a unit or reverting an
-- already-completed reservation. Each guarded update below now fails
-- loudly with a clear error instead of corrupting data quietly.

create or replace function public.process_sale(
  p_customer_name text,
  p_salesperson_id uuid,
  p_payment_method text,
  p_reference_number text,
  p_notes text,
  p_total_amount numeric,
  p_cart_items jsonb, -- [{"device_id": "...", "price": 123.45}, ...]
  p_down_payment numeric default null,
  p_balance numeric default null,
  p_force_bulk boolean default false
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_sale_id uuid;
  v_item jsonb;
  v_device_id uuid;
  v_item_count int;
  v_order_type text;
  v_payment_status text;
begin
  v_item_count := jsonb_array_length(p_cart_items);
  v_order_type := case when v_item_count > 3 or p_force_bulk then 'Bulk' else 'Regular' end;
  v_payment_status := case when v_item_count > 3 or p_force_bulk then 'Pending' else 'Paid' end;

  insert into public.sales (
    customer_name, salesperson_id, payment_method, reference_number, notes,
    total_amount, status, order_type, payment_status, down_payment, balance
  )
  values (
    p_customer_name, p_salesperson_id, p_payment_method, p_reference_number, p_notes,
    p_total_amount, 'Completed', v_order_type, v_payment_status, p_down_payment, p_balance
  )
  returning id into v_sale_id;

  for v_item in select * from jsonb_array_elements(p_cart_items)
  loop
    v_device_id := (v_item->>'device_id')::uuid;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, (v_item->>'price')::numeric, 1);

    update public.devices set status = 'Sold' where id = v_device_id and status = 'Available';
    if not found then
      raise exception 'One of these units is no longer available — it may have just been sold or reserved by someone else. Refresh and try again.';
    end if;
  end loop;

  return v_sale_id;
end;
$$;

create or replace function public.convert_reservation_to_sale(
  p_reservation_id uuid,
  p_device_id uuid,
  p_customer_name text,
  p_customer_phone text,
  p_total_price numeric,
  p_payment_method text,
  p_reference_number text,
  p_notes text,
  p_salesperson_id uuid
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_sale_id uuid;
begin
  update public.reservations set status = 'Converted' where id = p_reservation_id and status = 'Active';
  if not found then
    raise exception 'This reservation is no longer active — it may have already been converted or cancelled.';
  end if;

  insert into public.sales (customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, notes, status)
  values (p_customer_name, p_customer_phone, p_salesperson_id, p_payment_method, p_reference_number, p_total_price, p_notes, 'Completed')
  returning id into v_sale_id;

  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
  values (v_sale_id, p_device_id, p_total_price, 1);

  update public.devices set status = 'Sold' where id = p_device_id;

  return v_sale_id;
end;
$$;

create or replace function public.create_reservation(
  p_device_id uuid,
  p_customer_name text,
  p_customer_phone text,
  p_salesperson_id uuid,
  p_reserved_until timestamptz,
  p_total_price numeric,
  p_down_payment numeric
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_reservation_id uuid;
begin
  insert into public.reservations (device_id, customer_name, customer_phone, salesperson_id, reserved_until, total_price, down_payment, status)
  values (p_device_id, p_customer_name, p_customer_phone, p_salesperson_id, p_reserved_until, p_total_price, coalesce(p_down_payment, 0), 'Active')
  returning id into v_reservation_id;

  update public.devices set status = 'Reserved' where id = p_device_id and status = 'Available';
  if not found then
    raise exception 'This unit is no longer available to reserve — it may have just been sold or reserved by someone else. Refresh and try again.';
  end if;

  return v_reservation_id;
end;
$$;

create or replace function public.cancel_reservation(p_reservation_id uuid, p_device_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  update public.reservations set status = 'Cancelled' where id = p_reservation_id and status = 'Active';
  if not found then
    raise exception 'This reservation is no longer active — it may have already been converted or cancelled.';
  end if;

  update public.devices set status = 'Available' where id = p_device_id;
end;
$$;

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

  if v_previous_status = 'Sold' and p_status = 'Available' then
    select array_agg(distinct sale_id) into v_affected_sale_ids
    from public.sale_items where device_id = p_id;

    delete from public.customer_returns where sale_item_id in (select id from public.sale_items where device_id = p_id);

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
