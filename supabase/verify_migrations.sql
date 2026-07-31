-- Run this once and check the results against the expectations in the
-- comments — a one-shot way to confirm every migration actually landed,
-- instead of trusting memory of what was run and when.

-- 1. devices.condition — expect: check constraint containing
--    'Brand New','Pre-owned','Genuine','Used'
select conname, pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid = 'public.devices'::regclass and conname = 'devices_condition_check';

-- 2. devices.category — expect: check constraint containing
--    'iPhones','iPads','Apple Watches','MacBooks','Accessories','Repair Parts'
select conname, pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid = 'public.devices'::regclass and conname = 'devices_category_check';

-- 3. expenses — expect: admin_only present, bulk_order_shell_id ABSENT
select column_name, data_type
from information_schema.columns
where table_schema = 'public' and table_name = 'expenses'
order by ordinal_position;

-- 4. profiles.role — expect: check constraint containing 'admin','staff'
select conname, pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid = 'public.profiles'::regclass and conname = 'profiles_role_check';

-- 5. bulk_order_shells — expect: unit_cost, supplier_payment_status,
--    supplier_paid_at all present
select column_name, data_type
from information_schema.columns
where table_schema = 'public' and table_name = 'bulk_order_shells'
order by ordinal_position;

-- 6. add_device / update_device — expect EXACTLY ONE row each (one
--    overload). More than one row means a stale overload is still there.
select p.proname, pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname in ('add_device', 'update_device')
order by p.proname;

-- 7. mark_bulk_order_shell_paid / _unpaid — expect exactly one row each,
--    taking only p_id uuid (no p_unit_cost/p_device_name/etc. left over)
select p.proname, pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname in ('mark_bulk_order_shell_paid', 'mark_bulk_order_shell_unpaid')
order by p.proname;
