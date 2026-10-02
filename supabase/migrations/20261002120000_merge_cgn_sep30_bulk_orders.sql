-- One-time correction: Supplier Payables > Bulk Buyers showed two separate
-- CGN bulk orders both dated 2026-09-30 (1 unit and 16 units) that should
-- have been a single order. Merges every line item onto the older of the
-- two sales rows, deletes the now-empty duplicate, and moves the surviving
-- order's date forward one day to 2026-10-01 as requested.
--
-- sale_items.sale_id is the only foreign key into sales(id) (on delete
-- cascade) — customer_returns points at sale_item_id instead, so repointing
-- sale_items here carries any existing return along with it automatically.
--
-- Safe to re-run: after the merge only one CGN/2026-09-30 row remains, so
-- the exactly-2 guard below makes every later run a no-op.
do $$
declare
  v_ids uuid[];
  v_survivor uuid;
  v_loser uuid;
  v_total numeric(12, 2);
  v_payment_status text;
  v_notes text;
begin
  select array_agg(id order by sold_at, created_at)
  into v_ids
  from public.sales
  where order_type = 'Bulk'
    and trim(customer_name) ilike 'cgn'
    and sold_at::date = '2026-09-30';

  if coalesce(array_length(v_ids, 1), 0) <> 2 then
    raise notice 'Expected exactly 2 CGN bulk orders dated 2026-09-30, found %. No changes made.',
      coalesce(array_length(v_ids, 1), 0);
    return;
  end if;

  if exists (
    select 1 from public.sales
    where id = any (v_ids) and (down_payment is not null or balance is not null)
  ) then
    raise exception 'One of the two CGN 2026-09-30 bulk orders has Skyro financing fields set — merge needs manual review, aborting.';
  end if;

  v_survivor := v_ids[1];
  v_loser := v_ids[2];

  update public.sale_items
  set sale_id = v_survivor
  where sale_id = v_loser;

  select s1.total_amount + s2.total_amount,
         case when s1.payment_status = 'Pending' or s2.payment_status = 'Pending' then 'Pending' else 'Paid' end,
         nullif(trim(both E' \n' from concat_ws(E'\n', s1.notes, s2.notes)), '')
  into v_total, v_payment_status, v_notes
  from public.sales s1, public.sales s2
  where s1.id = v_survivor and s2.id = v_loser;

  update public.sales
  set total_amount = v_total,
      payment_status = v_payment_status,
      notes = v_notes,
      sold_at = sold_at + interval '1 day'
  where id = v_survivor;

  delete from public.sales where id = v_loser;

  raise notice 'Merged sale % into % and moved its date to 2026-10-01.', v_loser, v_survivor;
end $$;
