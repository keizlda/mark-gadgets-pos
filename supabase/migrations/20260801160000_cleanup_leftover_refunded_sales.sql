-- One-time cleanup: if update_device (20260801130000) already ran on your
-- database before this fix, any Sold -> Available edit you tested with it
-- left a sale sitting in the database tagged status = 'Refunded' instead of
-- being deleted. 20260801150000 stopped filtering those out (since the new
-- design deletes rows outright instead of hiding them), so those old test
-- rows are now visibly showing up again. This deletes them for good.
--
-- Safe to run even if you have no Refunded rows — it just does nothing.
-- Run this in the Supabase SQL Editor, after 20260801150000.

-- A sale_item being wiped out here may still have a customer_returns row
-- pointing at it (sale_item_id is a not-null FK) if that specific unit had
-- a return tracked against it before its whole order got wrongly marked
-- Refunded by the old bug. The sale is being erased as if it never
-- happened, so any return tracked against it goes with it.
delete from public.customer_returns
where sale_item_id in (
  select si.id from public.sale_items si
  join public.sales s on s.id = si.sale_id
  where s.status = 'Refunded'
);

delete from public.sale_items
where sale_id in (select id from public.sales where status = 'Refunded');

delete from public.sales
where status = 'Refunded';
