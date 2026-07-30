-- Admin needs to see how much is owed to each supplier for a bulk shipment
-- and track whether it's been paid. Owed amount is based on what was
-- agreed/ordered (unit_cost * quantity_expected), not how many units have
-- actually been logged into the system so far — the supplier is owed for
-- the whole shipment regardless of how far staff have gotten entering units.
alter table public.bulk_order_shells add column unit_cost numeric(12, 2);
alter table public.bulk_order_shells add column supplier_payment_status text not null default 'Unpaid';
alter table public.bulk_order_shells add column supplier_paid_at timestamptz;

alter table public.bulk_order_shells
  add constraint bulk_order_shells_supplier_payment_status_check
  check (supplier_payment_status in ('Unpaid', 'Paid'));
alter table public.bulk_order_shells
  add constraint bulk_order_shells_unit_cost_check
  check (unit_cost is null or unit_cost >= 0);

-- create-or-replace can only append columns to a view, never reorder or
-- insert them in the middle (42P16) — the new columns go at the end.
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
  s.supplier_paid_at
from public.bulk_order_shells s
left join public.suppliers sup on sup.id = s.supplier_id
left join public.devices d on d.bulk_order_shell_id = s.id
group by s.id, sup.name;

create function public.mark_bulk_order_shell_paid(p_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  update public.bulk_order_shells
  set supplier_payment_status = 'Paid', supplier_paid_at = now()
  where id = p_id;
end;
$$;

-- Mirrors the "un-resolve" pattern already used for supplier defective
-- records — corrects a mistaken Mark as Paid without losing history on the
-- shell itself.
create function public.mark_bulk_order_shell_unpaid(p_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  update public.bulk_order_shells
  set supplier_payment_status = 'Unpaid', supplier_paid_at = null
  where id = p_id;
end;
$$;
