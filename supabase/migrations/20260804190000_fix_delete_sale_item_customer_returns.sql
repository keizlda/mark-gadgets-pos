-- delete_sale_item never cleared a customer_returns row filed against the
-- sale_item it was about to delete, so it failed with a foreign-key
-- violation on customer_returns_sale_item_id_fkey for any unit that had
-- ever had a return filed on it. Undoing the sale now undoes that return
-- too, same fix as admin_delete_device got for the same underlying gap.
create or replace function public.delete_sale_item(p_sale_item_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_device_id uuid;
  v_sale_id uuid;
begin
  select device_id, sale_id into v_device_id, v_sale_id
  from public.sale_items where id = p_sale_item_id;

  delete from public.customer_returns where sale_item_id = p_sale_item_id;

  delete from public.sale_items where id = p_sale_item_id;

  update public.devices set status = 'Available' where id = v_device_id and status = 'Sold';

  delete from public.sales
  where id = v_sale_id
    and id not in (select distinct sale_id from public.sale_items);
end;
$$;
