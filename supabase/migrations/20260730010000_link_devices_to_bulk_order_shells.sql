-- How many units have been linked back to each shipment shell so far — used
-- by Add Device's "Link to Pending Shipment" dropdown and the All Devices
-- progress display.
create view public.bulk_order_shell_progress_view
with (security_invoker = true) as
select
  s.id,
  s.supplier_id,
  s.device_name,
  s.storage,
  s.color,
  s.quantity_expected,
  s.date_arrived,
  s.status,
  count(d.id) as linked_count
from public.bulk_order_shells s
left join public.devices d on d.bulk_order_shell_id = s.id
group by s.id;

-- Folds in the "report as Supplier Defective" record creation that used to
-- be a separate follow-up call from Add Device. p_bulk_order_shell_id/
-- p_date_arrived link this unit back to an overnight shipment placeholder
-- (see bulk_order_shells) — both optional, unrelated to a device's normal
-- date_added.
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

  return v_device_id;
end;
$$;
