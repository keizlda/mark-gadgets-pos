-- A Replace Return repoints sale_items.device_id to the replacement unit,
-- so the same sale_item can legitimately represent a different physical
-- device after a swap. The original unique(sale_item_id) constraint
-- assumed a sale_item could only ever be returned once, ever — so once
-- that first return resolved, staff could never start a return on that
-- line item again, even for a completely different unit now sitting on
-- it. Replaces the plain unique constraint with a partial unique index
-- that only blocks a SECOND ACTIVE (Pending/On Hold) return, allowing the
-- same sale_item to go through the whole return cycle again later.
alter table public.customer_returns drop constraint customer_returns_sale_item_id_key;

create unique index customer_returns_one_active_per_sale_item
  on public.customer_returns (sale_item_id)
  where status in ('Pending', 'On Hold');
