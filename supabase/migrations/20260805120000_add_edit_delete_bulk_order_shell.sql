-- Add notes to the progress view so Edit Shipment can prefill it (it was
-- already on bulk_order_shells, just never surfaced through the view).
create or replace view public.bulk_order_shell_progress_view
with (security_invoker = true) as
select
  s.id,
  s.supplier_id,
  sup.name as supplier_name,
  s.device_name,
  s.storage,
  s.color,
  s.quantity_expected,
  s.date_arrived,
  s.status,
  count(d.id) as linked_count,
  s.unit_cost,
  s.unit_cost * s.quantity_expected as amount_payable,
  s.supplier_payment_status,
  s.supplier_paid_at,
  s.notes
from public.bulk_order_shells s
left join public.suppliers sup on sup.id = s.supplier_id
left join public.devices d on d.bulk_order_shell_id = s.id
group by s.id, sup.name;

-- Admin-only correction for a pending shipment's own fields — mirrors
-- edit_supplier_defective_record's supplier-name resolution pattern.
-- Admin gating happens in the UI (Pending Shipments only ever shows this
-- action to admins), same as every other edit/delete in this app.
create function public.edit_bulk_order_shell(
  p_id uuid,
  p_supplier_name text,
  p_device_name text,
  p_storage text,
  p_color text,
  p_quantity_expected int,
  p_unit_cost numeric,
  p_date_arrived timestamptz,
  p_notes text
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_supplier_id uuid;
begin
  if p_supplier_name is null or p_supplier_name = '' then
    v_supplier_id := null;
  else
    select id into v_supplier_id from public.suppliers where name = p_supplier_name;
  end if;

  update public.bulk_order_shells
  set supplier_id = v_supplier_id,
      device_name = p_device_name,
      storage = p_storage,
      color = p_color,
      quantity_expected = p_quantity_expected,
      unit_cost = p_unit_cost,
      date_arrived = p_date_arrived,
      notes = p_notes
  where id = p_id;
end;
$$;

-- Deleting a shell doesn't touch any devices already linked to it — those
-- are real logged inventory, not placeholders, so they're detached (not
-- deleted) rather than losing real stock over a shipment-record cleanup.
create function public.delete_bulk_order_shell(p_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  update public.devices set bulk_order_shell_id = null where bulk_order_shell_id = p_id;
  delete from public.bulk_order_shells where id = p_id;
end;
$$;
