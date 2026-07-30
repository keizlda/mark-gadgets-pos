-- Reverts 20260731080000 — Supplier Payables stays a pure paid/unpaid
-- guide for admin, marking a shipment Paid no longer creates an expense.
delete from public.expenses where bulk_order_shell_id is not null;
alter table public.expenses drop column bulk_order_shell_id;

create or replace function public.mark_bulk_order_shell_paid(p_id uuid)
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

create or replace function public.mark_bulk_order_shell_unpaid(p_id uuid)
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
