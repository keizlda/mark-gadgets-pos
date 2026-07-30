-- Marking a bulk shipment Paid is a real cash outflow — it should show up
-- as an expense on the day it's paid, not just flip a status flag.
-- bulk_order_shell_id lets the reverse (Mark as Unpaid) find and remove the
-- exact expense it created, without a fragile description-text match.
alter table public.expenses add column bulk_order_shell_id uuid references public.bulk_order_shells (id);

-- Same signature as before (p_id uuid) — create-or-replace genuinely
-- replaces here, no overload risk.
create or replace function public.mark_bulk_order_shell_paid(p_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_unit_cost numeric;
  v_quantity_expected int;
  v_device_name text;
  v_supplier_name text;
begin
  update public.bulk_order_shells
  set supplier_payment_status = 'Paid', supplier_paid_at = now()
  where id = p_id;

  select s.unit_cost, s.quantity_expected, s.device_name, sup.name
    into v_unit_cost, v_quantity_expected, v_device_name, v_supplier_name
  from public.bulk_order_shells s
  left join public.suppliers sup on sup.id = s.supplier_id
  where s.id = p_id;

  -- No unit_cost recorded yet means no amount to log — still marks Paid,
  -- just can't reflect it as an expense until a cost is entered.
  if v_unit_cost is not null then
    insert into public.expenses (expense_date, description, amount, admin_only, bulk_order_shell_id)
    values (
      current_date,
      'Supplier payment - ' || coalesce(v_supplier_name, 'Unknown supplier') || ' - ' || v_device_name,
      v_unit_cost * v_quantity_expected,
      true,
      p_id
    );
  end if;
end;
$$;

-- Mirrors the same reversal pattern used for supplier defective records —
-- correcting a mistaken Mark as Paid removes the expense it created too,
-- not just the status flag.
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

  delete from public.expenses where bulk_order_shell_id = p_id;
end;
$$;
