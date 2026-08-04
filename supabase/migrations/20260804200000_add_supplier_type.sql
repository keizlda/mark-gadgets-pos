-- Accessories/Repair Parts are sourced from different vendors than
-- iPhones/iPads/Apple Watches/MacBooks — this lets SupplierSelect show a
-- different list per category instead of one flat list for everything.
-- Nullable rather than not-null: null means "shows for every category" —
-- 'Walk-in' (a generic trade-in/purchase source, not a dedicated vendor)
-- gets that instead of being locked into one type it doesn't actually fit.
alter table public.suppliers
  add column supplier_type text check (supplier_type in ('Device', 'Accessory'));

update public.suppliers set supplier_type = 'Device' where name <> 'Walk-in';
