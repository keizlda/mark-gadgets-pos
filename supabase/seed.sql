-- Minimal seed data to test the Sales History migration.
-- Run in the Supabase SQL Editor. Safe to run once; re-running creates duplicates
-- (there's no unique constraint stopping that here, so just don't run it twice).

insert into public.suppliers (name, contact_info)
values ('iStudio Philippines', '09171234567');

insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, selling_price)
select '070926-031', 'iPhone 16 Pro', 'iPhones', '256GB', 'Natural Titanium', 'Sold', s.id, 68990
from public.suppliers s where s.name = 'iStudio Philippines';

insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, selling_price)
select '070926-015', 'iPhone 15', 'iPhones', '128GB', 'Pink', 'Sold', s.id, 48990
from public.suppliers s where s.name = 'iStudio Philippines';

with new_sale as (
  insert into public.sales (customer_name, customer_phone, payment_method, total_amount, status, sold_at)
  values ('Juan Dela Cruz', '0917 123 4567', 'GCash', 68990, 'Completed', now())
  returning id
)
insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
select new_sale.id, d.id, 68990, 1
from new_sale, public.devices d
where d.batch_code = '070926-031';

with new_sale as (
  insert into public.sales (customer_name, customer_phone, payment_method, total_amount, status, sold_at)
  values ('Mark Santos', '0998 765 4321', 'Cash', 48990, 'Completed', now() - interval '1 day')
  returning id
)
insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
select new_sale.id, d.id, 48990, 1
from new_sale, public.devices d
where d.batch_code = '070926-015';

-- Customer Returns test data — a return against the iPhone 16 Pro sale above.
insert into public.customer_returns (sale_item_id, reason, status, refund_amount, returned_at)
select si.id, 'Defective Unit (Volume button)', 'Approved', 68990, now()
from public.sale_items si
join public.devices d on d.id = si.device_id
where d.batch_code = '070926-031';
