-- Adds supplier name to the progress view for the All Devices "Pending
-- Shipments" display. Dropped and recreated rather than "create or
-- replace" — that only allows appending columns at the end, and
-- supplier_name sits in the middle of the existing column list.
drop view if exists public.bulk_order_shell_progress_view;

create view public.bulk_order_shell_progress_view
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
  count(d.id) as linked_count
from public.bulk_order_shells s
left join public.suppliers sup on sup.id = s.supplier_id
left join public.devices d on d.bulk_order_shell_id = s.id
group by s.id, sup.name;
