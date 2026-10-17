-- One-time correction: Supplier Payables > Bulk Buyers showed two separate
-- KIM bulk orders dated 2026-10-17 — the main 58-unit order
-- (376c38e7-379a-4344-bd17-5df9e02d82c6) and a separate 1-unit order for
-- an iPhone 18 Pro Max (₱103,000) that should have been part of it. Moves
-- that line item onto the main order, adds its total, and deletes the
-- now-empty separate sale. Same approach as
-- 20261002120000_merge_cgn_sep30_bulk_orders.sql.
--
-- sale_items.sale_id is the only foreign key into sales(id) (on delete
-- cascade) — customer_returns points at sale_item_id, so any return on the
-- moved line item comes along with it.
--
-- Safe to re-run: once merged, no other KIM bulk order remains for that
-- day, so the exactly-1 guard below makes every later run a no-op.
do $$
declare
  v_survivor uuid := '376c38e7-379a-4344-bd17-5df9e02d82c6';
  v_ids uuid[];
  v_loser uuid;
begin
  if not exists (select 1 from public.sales where id = v_survivor) then
    raise exception 'Main KIM order % not found — aborting.', v_survivor;
  end if;

  select array_agg(id)
  into v_ids
  from public.sales
  where order_type = 'Bulk'
    and trim(customer_name) ilike 'kim'
    and (sold_at at time zone 'Asia/Manila')::date = date '2026-10-17'
    and id <> v_survivor;

  if coalesce(array_length(v_ids, 1), 0) <> 1 then
    raise notice 'Expected exactly 1 other KIM bulk order dated 2026-10-17, found %. No changes made.',
      coalesce(array_length(v_ids, 1), 0);
    return;
  end if;

  v_loser := v_ids[1];

  if (select count(*) from public.sale_items where sale_id = v_loser) <> 1 then
    raise exception 'The separate KIM order does not have exactly 1 unit — merge needs manual review, aborting.';
  end if;

  if exists (
    select 1 from public.sales
    where id = v_loser and (down_payment is not null or balance is not null)
  ) then
    raise exception 'The separate KIM order has financing fields set — merge needs manual review, aborting.';
  end if;

  update public.sale_items
  set sale_id = v_survivor
  where sale_id = v_loser;

  update public.sales s
  set total_amount = s.total_amount + l.total_amount,
      notes = nullif(trim(both E' \n' from concat_ws(E'\n', s.notes, l.notes)), '')
  from public.sales l
  where s.id = v_survivor and l.id = v_loser;

  delete from public.sales where id = v_loser;

  raise notice 'Merged sale % into %.', v_loser, v_survivor;
end $$;
