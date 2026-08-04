-- Lets staff manually mark a sale as Bulk regardless of unit count (e.g. a
-- single-unit wholesale sale) — previously Bulk was only ever inferred from
-- more than 3 cart items. A changed parameter list creates a second
-- overload rather than replacing the old one, so the old 9-arg signature is
-- dropped explicitly before recreating it with the new parameter.
drop function if exists public.process_sale(text, uuid, text, text, text, numeric, jsonb, numeric, numeric);

create function public.process_sale(
  p_customer_name text,
  p_salesperson_id uuid,
  p_payment_method text,
  p_reference_number text,
  p_notes text,
  p_total_amount numeric,
  p_cart_items jsonb, -- [{"device_id": "...", "price": 123.45}, ...]
  p_down_payment numeric default null,
  p_balance numeric default null,
  p_force_bulk boolean default false
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_sale_id uuid;
  v_item jsonb;
  v_device_id uuid;
  v_item_count int;
  v_order_type text;
  v_payment_status text;
begin
  v_item_count := jsonb_array_length(p_cart_items);
  v_order_type := case when v_item_count > 3 or p_force_bulk then 'Bulk' else 'Regular' end;
  v_payment_status := case when v_item_count > 3 or p_force_bulk then 'Pending' else 'Paid' end;

  insert into public.sales (
    customer_name, salesperson_id, payment_method, reference_number, notes,
    total_amount, status, order_type, payment_status, down_payment, balance
  )
  values (
    p_customer_name, p_salesperson_id, p_payment_method, p_reference_number, p_notes,
    p_total_amount, 'Completed', v_order_type, v_payment_status, p_down_payment, p_balance
  )
  returning id into v_sale_id;

  for v_item in select * from jsonb_array_elements(p_cart_items)
  loop
    v_device_id := (v_item->>'device_id')::uuid;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, (v_item->>'price')::numeric, 1);

    update public.devices set status = 'Sold' where id = v_device_id;
  end loop;

  return v_sale_id;
end;
$$;
