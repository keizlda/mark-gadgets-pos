-- Repair parts (LCDs, batteries) and accessories (cases, chargers, etc.)
-- are sellable stock too, tracked the same way as phones — one batch code
-- per unit, same Add Device/New Sale/Financial flow. 'Accessories' was
-- already an allowed category but never exposed in the UI catalog;
-- 'Repair Parts' is new.
alter table public.devices drop constraint devices_category_check;
alter table public.devices add constraint devices_category_check
  check (category in ('iPhones', 'iPads', 'Apple Watches', 'MacBooks', 'Accessories', 'Repair Parts'));
