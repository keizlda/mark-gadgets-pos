-- admin_delete_device previously refused to delete a unit linked in the
-- CGN Ledger. Now it deletes that cgn_resales row along with the device
-- instead of blocking — the customer-return-replacement guard stays,
-- since nulling that reference would break a different customer's record.
create or replace function public.admin_delete_device(p_device_id uuid)
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

  delete from public.cgn_resales where device_id = p_device_id;

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
