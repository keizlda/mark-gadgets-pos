-- replace_return previously always sent the original unit to Supplier
-- Defective and never touched price_at_sale — fine for a broken-unit swap,
-- wrong for a "changed mind, wants a different model" swap: a perfectly
-- good unit doesn't belong in Supplier Defective, and a different model
-- almost never costs the same as the one it's replacing.
--
-- Now: the original unit's destination depends on the return reason
-- (Defective Unit / Not as Described -> Supplier Defective, everything
-- else -> back to Available for resale), and an optional p_new_price lets
-- staff set the swap's actual sale price instead of silently keeping the
-- old unit's price.
create or replace function public.replace_return(
  p_return_id uuid,
  p_original_device_id uuid,
  p_replacement_device_id uuid,
  p_reason text,
  p_new_price numeric default null
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_supplier_id uuid;
  v_sale_item_id uuid;
begin
  select sale_item_id into v_sale_item_id from public.customer_returns where id = p_return_id;

  update public.customer_returns
  set status = 'Replaced', replacement_device_id = p_replacement_device_id
  where id = p_return_id;

  if p_reason in ('Defective Unit', 'Not as Described') then
    select supplier_id into v_supplier_id from public.devices where id = p_original_device_id;

    update public.devices set status = 'Supplier Defective' where id = p_original_device_id;

    insert into public.supplier_defective_records (device_id, supplier_id, issue_description)
    values (p_original_device_id, v_supplier_id, p_reason);
  else
    update public.devices set status = 'Available' where id = p_original_device_id;
  end if;

  update public.devices set status = 'Sold' where id = p_replacement_device_id;

  -- Repoint the original sale's line item to the replacement unit, so its
  -- capital/profit are the ones from the unit the customer actually walked
  -- out with this time — otherwise the replacement's cost never appears
  -- anywhere in Sales History/Reports/Financial. price_at_sale updates too
  -- when a new price was given, so a model swap doesn't silently keep the
  -- old unit's price.
  update public.sale_items
  set device_id = p_replacement_device_id,
      price_at_sale = coalesce(p_new_price, price_at_sale)
  where id = v_sale_item_id;
end;
$$;
