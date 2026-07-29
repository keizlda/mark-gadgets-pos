-- When linking pushes a shell's logged count up to its quantity_expected,
-- the shell flips to Completed in the same atomic call — no separate
-- round trip after the insert that could leave a fully-logged shell stuck
-- showing Pending.
create or replace function public.add_device(
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
  p_date_arrived timestamptz default null
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

  insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, selling_price, notes, date_added, bulk_order_shell_id, date_arrived)
  values (p_batch_code, p_device_name, p_category, p_storage, p_color, p_status, v_supplier_id, p_price, p_notes, p_date_added, p_bulk_order_shell_id, p_date_arrived)
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
