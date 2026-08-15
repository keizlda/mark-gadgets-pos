-- Resolving a return today is one atomic step (replace_return): pick a
-- replacement and send the original to Supplier Defective happen
-- together. If no replacement exists yet, staff can't do either — the
-- original unit sits stuck instead of actually going back to the
-- supplier. This splits that into two steps with a status in between:
-- "On Hold" (original unit already routed, no replacement chosen yet)
-- until stock arrives and staff completes it.
alter table public.customer_returns drop constraint customer_returns_status_check;
alter table public.customer_returns
  add constraint customer_returns_status_check
  check (status in ('Pending', 'Replaced', 'Rejected', 'On Hold'));

-- Routes the original unit immediately (same reason-based routing as
-- replace_return: Defective Unit / Not as Described -> Supplier
-- Defective, everything else -> back to Available) without requiring a
-- replacement to be picked yet.
create function public.hold_return_for_restock(
  p_return_id uuid,
  p_original_device_id uuid
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_reason text;
  v_supplier_id uuid;
begin
  select reason into v_reason from public.customer_returns where id = p_return_id;

  update public.customer_returns
  set status = 'On Hold'
  where id = p_return_id;

  if v_reason in ('Defective Unit', 'Not as Described') then
    select supplier_id into v_supplier_id from public.devices where id = p_original_device_id;

    update public.devices set status = 'Supplier Defective' where id = p_original_device_id;

    insert into public.supplier_defective_records (device_id, supplier_id, issue_description)
    values (p_original_device_id, v_supplier_id, v_reason);
  else
    update public.devices set status = 'Available' where id = p_original_device_id;
  end if;
end;
$$;

-- Finishes an On Hold return once a replacement is available. The
-- original unit was already routed in hold_return_for_restock, so this
-- only handles the replacement side — the same sale-repointing/price
-- logic as replace_return, minus the original-device routing.
create function public.complete_held_return(
  p_return_id uuid,
  p_replacement_device_id uuid,
  p_new_price numeric default null
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_sale_item_id uuid;
begin
  select sale_item_id into v_sale_item_id from public.customer_returns where id = p_return_id;

  update public.customer_returns
  set status = 'Replaced', replacement_device_id = p_replacement_device_id
  where id = p_return_id;

  update public.devices set status = 'Sold' where id = p_replacement_device_id;

  update public.sale_items
  set device_id = p_replacement_device_id,
      price_at_sale = coalesce(p_new_price, price_at_sale)
  where id = v_sale_item_id;
end;
$$;
