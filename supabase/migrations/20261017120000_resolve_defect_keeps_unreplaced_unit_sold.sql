-- Resolving a Supplier Defective record used to always put the unit back to
-- Available. That's right when the customer already got a replacement
-- (replace_return repointed their sale_item away from this unit, so it's
-- genuinely back in our stock), but wrong when the unit was put On Hold and
-- then fixed and handed back to the same customer — their sale_item still
-- points at it, so it should read Sold, not show up as sellable stock.
-- Three CGN XRs (041926-004/-006/-007) ended up Available this way.
--
-- Now: if a sale_item still points at the unit, Resolved means "fixed and
-- returned to that customer" — the unit goes to Sold and any On Hold return
-- on that sale_item is closed as Replaced with the same unit. Otherwise
-- (replaced already, or a defect caught before it was ever sold) it goes to
-- Available as before.
--
-- Same parameter list as before, so create or replace swaps it in place
-- rather than adding a second overload.

create or replace function public.update_supplier_defective_status(
  p_id uuid,
  p_status text,
  p_action_taken text,
  p_device_id uuid
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_previous_status text;
  v_current_device_status text;
  v_sale_item_id uuid;
begin
  select status into v_previous_status from public.supplier_defective_records where id = p_id;

  update public.supplier_defective_records
  set status = p_status, action_taken = p_action_taken
  where id = p_id;

  if p_device_id is not null then
    if p_status = 'Resolved' then
      select id into v_sale_item_id from public.sale_items where device_id = p_device_id limit 1;

      if v_sale_item_id is not null then
        update public.devices set status = 'Sold' where id = p_device_id;

        update public.customer_returns
        set status = 'Replaced', replacement_device_id = p_device_id
        where sale_item_id = v_sale_item_id and status = 'On Hold';
      else
        update public.devices set status = 'Available' where id = p_device_id;
      end if;
    elsif v_previous_status = 'Resolved' and p_status <> 'Resolved' then
      select status into v_current_device_status from public.devices where id = p_device_id;
      if v_current_device_status = 'Available' then
        update public.devices set status = 'Supplier Defective' where id = p_device_id;
      end if;
    end if;
  end if;
end;
$$;
