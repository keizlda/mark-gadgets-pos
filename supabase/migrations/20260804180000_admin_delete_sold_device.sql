-- Lets an admin delete a device outright even if it's Sold (or has other
-- history) — the plain `delete from devices` AllDevices already used only
-- works for a device with no history at all, since sale_items/reservations/
-- supplier_defective_records all reference devices without cascading.
-- This cleans up that history first, then removes the device — same
-- sale/parent-sale cleanup as delete_sale_item, just followed through to
-- actually removing the unit instead of reverting it to Available.
--
-- Deliberately refuses to touch a unit that's currently out with a
-- customer as someone else's return replacement, or linked in the CGN
-- Ledger — deleting either would silently break traceability elsewhere
-- (see cgn_resales.device_id comment in this file).
create function public.admin_delete_device(p_device_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  if not exists (select 1 from public.devices where id = p_device_id) then
    raise exception 'Device not found';
  end if;

  if exists (select 1 from public.customer_returns where replacement_device_id = p_device_id) then
    raise exception 'This unit is on record as a replacement for a customer return — resolve that first.';
  end if;

  if exists (select 1 from public.cgn_resales where device_id = p_device_id) then
    raise exception 'This unit is linked in the CGN Ledger — unlink it in Financial first.';
  end if;

  delete from public.customer_returns
  where sale_item_id in (select id from public.sale_items where device_id = p_device_id);

  delete from public.sales
  where id in (select sale_id from public.sale_items where device_id = p_device_id)
    and id not in (select distinct sale_id from public.sale_items where device_id <> p_device_id);

  delete from public.sale_items where device_id = p_device_id;
  delete from public.supplier_defective_records where device_id = p_device_id;
  delete from public.reservations where device_id = p_device_id;

  delete from public.devices where id = p_device_id;
end;
$$;
