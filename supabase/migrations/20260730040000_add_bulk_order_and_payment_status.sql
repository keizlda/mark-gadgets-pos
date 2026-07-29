-- A sale with more than 3 total units (summed across its sale_items) is
-- classified Bulk and starts Pending — bulk buyers usually pay by check,
-- which isn't confirmed the moment the sale is rung up. Lives here (not
-- per sale_item) since every unit in one sale shares this one sales row —
-- marking it Paid naturally reflects across every unit in the order.
alter table public.sales add column order_type text not null default 'Regular' check (order_type in ('Regular', 'Bulk'));
alter table public.sales add column payment_status text not null default 'Paid' check (payment_status in ('Paid', 'Pending'));

-- "Check" wasn't a valid payment method before — needed since bulk buyers
-- typically pay this way.
alter table public.sales drop constraint sales_payment_method_check;
alter table public.sales add constraint sales_payment_method_check
  check (payment_method in ('Cash', 'GCash', 'Credit Card', 'Bank Transfer', 'Check'));
