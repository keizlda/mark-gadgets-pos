-- Repair parts (LCDs, batteries, etc.) use a different condition
-- vocabulary than phones — not "Pre-owned", but Brand New / a genuine
-- pulled Apple part / a used or aftermarket one. No app-side change needed
-- beyond this — Color/Storage become optional (nullable already) and the
-- UI simply stops asking for them on that category.
alter table public.devices drop constraint devices_condition_check;
alter table public.devices add constraint devices_condition_check
  check (condition in ('Brand New', 'Pre-owned', 'Genuine', 'Used'));
