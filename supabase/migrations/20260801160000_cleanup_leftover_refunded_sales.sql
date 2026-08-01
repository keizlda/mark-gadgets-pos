-- One-time cleanup: if update_device (20260801130000) already ran on your
-- database before this fix, any Sold -> Available edit you tested with it
-- left a sale sitting in the database tagged status = 'Refunded' instead of
-- being deleted. 20260801150000 stopped filtering those out (since the new
-- design deletes rows outright instead of hiding them), so those old test
-- rows are now visibly showing up again. This deletes them for good.
--
-- Safe to run even if you have no Refunded rows — it just does nothing.
-- Run this in the Supabase SQL Editor, after 20260801150000.

delete from public.sale_items
where sale_id in (select id from public.sales where status = 'Refunded');

delete from public.sales
where status = 'Refunded';
