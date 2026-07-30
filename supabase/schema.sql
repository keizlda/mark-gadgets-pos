-- Mark Gadgets POS — initial schema
-- Run this in the Supabase SQL Editor (Project → SQL Editor → New query).
-- Safe to run once against a fresh project. Re-running will error on
-- "already exists" — that's expected, not a bug.

-- ============================================================
-- TABLES
-- ============================================================

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null,
  role text not null default 'staff' check (role in ('admin', 'staff')),
  created_at timestamptz not null default now()
);

create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  contact_info text,
  created_at timestamptz not null default now()
);

create table public.devices (
  id uuid primary key default gen_random_uuid(),
  batch_code text not null unique,
  device_name text not null,
  category text not null check (category in ('iPhones', 'iPads', 'Apple Watches', 'MacBooks', 'Accessories')),
  storage text,
  color text,
  status text not null default 'Available'
    check (status in ('Available', 'Reserved', 'Sold', 'Customer Returned', 'Supplier Defective', 'Returned')),
  supplier_id uuid references public.suppliers (id),
  purchase_price numeric(12, 2) check (purchase_price is null or purchase_price >= 0),
  selling_price numeric(12, 2) not null check (selling_price >= 0),
  condition text check (condition in ('Brand New', 'Pre-owned')),
  notes text,
  date_added timestamptz not null default now(),
  created_at timestamptz not null default now()
);

-- Bulk shipment placeholders — staff can log "a shipment arrived" (supplier,
-- model, quantity, date) the same night without entering every serial, then
-- link each individual unit back to it the next morning via Add Device.
create table public.bulk_order_shells (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid references public.suppliers (id),
  device_name text not null,
  storage text,
  color text,
  quantity_expected int not null check (quantity_expected > 0),
  date_arrived timestamptz not null,
  status text not null default 'Pending' check (status in ('Pending', 'Completed')),
  notes text,
  -- What Mark Gadgets owes the supplier for this shipment — unit_cost times
  -- the agreed quantity_expected, not however many units have been logged
  -- so far (see bulk_order_shell_progress_view.amount_payable).
  unit_cost numeric(12, 2) check (unit_cost is null or unit_cost >= 0),
  supplier_payment_status text not null default 'Unpaid' check (supplier_payment_status in ('Unpaid', 'Paid')),
  supplier_paid_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.devices add column bulk_order_shell_id uuid references public.bulk_order_shells (id);
alter table public.devices add column date_arrived timestamptz;

-- Reorder threshold is set per model (device_name), not per unit — the owner
-- configures this from the Low Stock page rather than at Add Device time.
create table public.reorder_settings (
  id uuid primary key default gen_random_uuid(),
  device_name text not null unique,
  reorder_level integer not null check (reorder_level >= 0),
  enabled boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.sales (
  id uuid primary key default gen_random_uuid(),
  customer_name text,
  customer_phone text,
  salesperson_id uuid references public.profiles (id),
  payment_method text not null check (payment_method in ('Cash', 'GCash', 'Credit Card', 'Bank Transfer', 'Check', 'Skyro', 'Home Credit')),
  reference_number text,
  notes text,
  total_amount numeric(12, 2) not null check (total_amount >= 0),
  status text not null default 'Completed' check (status in ('Completed', 'Refunded')),
  -- A sale with more than 3 total units (summed across its sale_items) is
  -- classified Bulk and starts Pending — bulk buyers usually pay by check,
  -- which isn't confirmed the moment the sale is rung up. Lives here (not
  -- per sale_item) since every unit in one sale shares this one sales row —
  -- marking it Paid naturally reflects across every unit in the order.
  order_type text not null default 'Regular' check (order_type in ('Regular', 'Bulk')),
  payment_status text not null default 'Paid' check (payment_status in ('Paid', 'Pending')),
  sold_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.sales (id) on delete cascade,
  device_id uuid not null references public.devices (id),
  price_at_sale numeric(12, 2) not null check (price_at_sale >= 0),
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz not null default now()
);

-- No cash refunds — every return is either Rejected or resolved by handing
-- the customer a replacement unit of the same model (replacement_device_id).
-- A sold item can only ever be returned once (unique sale_item_id) — this is
-- the invariant that stops "Return" from being submitted twice on one item.
create table public.customer_returns (
  id uuid primary key default gen_random_uuid(),
  sale_item_id uuid not null references public.sale_items (id) unique,
  reason text not null,
  status text not null default 'Pending' check (status in ('Pending', 'Replaced', 'Rejected')),
  replacement_device_id uuid references public.devices (id),
  returned_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table public.supplier_defective_records (
  id uuid primary key default gen_random_uuid(),
  device_id uuid not null references public.devices (id),
  supplier_id uuid references public.suppliers (id),
  issue_description text not null,
  status text not null default 'Pending Return'
    check (status in ('Pending Return', 'Returned to Supplier', 'Resolved')),
  action_taken text,
  date_detected timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table public.reservations (
  id uuid primary key default gen_random_uuid(),
  device_id uuid not null references public.devices (id),
  customer_name text not null,
  customer_phone text,
  salesperson_id uuid references public.profiles (id),
  reserved_until timestamptz not null,
  status text not null default 'Active'
    check (status in ('Active', 'Expiring Soon', 'Expired', 'Cancelled', 'Converted')),
  total_price numeric(12, 2) not null check (total_price >= 0),
  down_payment numeric(12, 2) not null default 0 check (down_payment >= 0 and down_payment <= total_price),
  created_at timestamptz not null default now()
);

-- Reports' expense log. A plain date (not timestamptz) — an expense is tied
-- to a calendar day, not a moment, so there's no timezone-midnight footgun
-- when filtering by report date range.
create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  expense_date date not null,
  description text not null,
  amount numeric(12, 2) not null check (amount >= 0),
  -- Expenses logged from the admin-only Financial page stay out of
  -- Reports, which any role can open — Reports only shows what staff
  -- themselves have logged.
  admin_only boolean not null default false,
  -- Set when this expense was auto-created by marking a bulk shipment
  -- Paid — lets marking it Unpaid again find and remove this exact row.
  bulk_order_shell_id uuid references public.bulk_order_shells (id),
  created_at timestamptz not null default now()
);

create index on public.expenses (expense_date);

-- ============================================================
-- VIEWS
-- ============================================================

-- Groups available units by model (across all storage/color/supplier
-- variants) and flags models below their configured reorder level.
-- security_invoker means it respects the querying user's own RLS on devices,
-- rather than running with the view owner's privileges.
create view public.low_stock_view
with (security_invoker = true) as
select
  d.device_name,
  d.category,
  rs.reorder_level,
  count(*) filter (where d.status = 'Available') as available,
  coalesce(sum(d.selling_price) filter (where d.status = 'Available'), 0) as estimated_value,
  max(d.date_added) as last_updated
from public.reorder_settings rs
join public.devices d on d.device_name = rs.device_name
where rs.enabled = true
group by d.device_name, d.category, rs.reorder_level
having count(*) filter (where d.status = 'Available') < rs.reorder_level;

-- How many units have been linked back to each shipment shell so far — used
-- by Add Device's "Link to Pending Shipment" dropdown and the All Devices
-- progress display.
create view public.bulk_order_shell_progress_view
with (security_invoker = true) as
select
  s.id,
  s.supplier_id,
  sup.name as supplier_name,
  s.device_name,
  s.storage,
  s.color,
  s.quantity_expected,
  s.date_arrived,
  s.status,
  count(d.id) as linked_count,
  s.unit_cost,
  s.unit_cost * s.quantity_expected as amount_payable,
  s.supplier_payment_status,
  s.supplier_paid_at
from public.bulk_order_shells s
left join public.suppliers sup on sup.id = s.supplier_id
left join public.devices d on d.bulk_order_shell_id = s.id
group by s.id, sup.name;

-- Monthly completed-sales totals, for the Dashboard trend chart.
create view public.sales_by_month_view
with (security_invoker = true) as
select
  date_trunc('month', sold_at) as month_start,
  to_char(date_trunc('month', sold_at), 'Mon') as month,
  sum(total_amount) as sales
from public.sales
where status = 'Completed'
group by date_trunc('month', sold_at);

-- Recent devices with whichever customer they're most associated with right
-- now (their most recent sale, falling back to their most recent reservation).
-- Used by the Dashboard's "Recent Device Activity" widget.
create view public.recent_device_activity_view
with (security_invoker = true) as
select
  d.batch_code,
  d.device_name,
  d.storage,
  d.color,
  d.status,
  d.date_added,
  coalesce(sale_customer.customer_name, res.customer_name) as customer_name,
  coalesce(sale_customer.customer_phone, res.customer_phone) as customer_phone
from public.devices d
left join lateral (
  select s.customer_name, s.customer_phone
  from public.sale_items si
  join public.sales s on s.id = si.sale_id
  where si.device_id = d.id
  order by s.sold_at desc
  limit 1
) sale_customer on true
left join lateral (
  select r.customer_name, r.customer_phone
  from public.reservations r
  where r.device_id = d.id
  order by r.created_at desc
  limit 1
) res on true;

-- ============================================================
-- INDEXES (foreign keys aren't auto-indexed in Postgres)
-- ============================================================

create index on public.devices (supplier_id);
create index on public.devices (status);
create index on public.sales (salesperson_id);
create index on public.sale_items (sale_id);
create index on public.sale_items (device_id);
create index on public.customer_returns (sale_item_id);
create index on public.supplier_defective_records (device_id);
create index on public.supplier_defective_records (supplier_id);
create index on public.reservations (device_id);
create index on public.reservations (salesperson_id);
create index on public.bulk_order_shells (supplier_id);
create index on public.devices (bulk_order_shell_id);

-- ============================================================
-- TRANSACTIONAL RPCs
--
-- Every multi-table write in the app used to be several separate round
-- trips from the browser (insert sale, insert sale_items, update devices,
-- ...). If the connection dropped between calls, you could end up with a
-- sale recorded but the device still "Available", or similar half-done
-- states — silent data corruption, not an error message. A single
-- plpgsql function body is one implicit transaction: if anything inside
-- raises, everything the function did is rolled back. security invoker
-- (the default, made explicit here) means these still run under the
-- calling user's own RLS, not elevated privileges.
-- ============================================================

-- More than 3 total units (cart items, since each is always quantity 1)
-- classifies the sale as Bulk and starts it Pending — bulk buyers usually
-- pay by check, which isn't confirmed the moment the sale is rung up.
-- Decided here rather than trusting the caller, same as every other
-- business rule enforced inside these RPCs.
create function public.process_sale(
  p_customer_name text,
  p_salesperson_id uuid,
  p_payment_method text,
  p_reference_number text,
  p_notes text,
  p_total_amount numeric,
  p_cart_items jsonb -- [{"device_id": "...", "price": 123.45}, ...]
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_sale_id uuid;
  v_item jsonb;
  v_device_id uuid;
  v_item_count int;
  v_order_type text;
  v_payment_status text;
begin
  v_item_count := jsonb_array_length(p_cart_items);
  v_order_type := case when v_item_count > 3 then 'Bulk' else 'Regular' end;
  v_payment_status := case when v_item_count > 3 then 'Pending' else 'Paid' end;

  insert into public.sales (customer_name, salesperson_id, payment_method, reference_number, notes, total_amount, status, order_type, payment_status)
  values (p_customer_name, p_salesperson_id, p_payment_method, p_reference_number, p_notes, p_total_amount, 'Completed', v_order_type, v_payment_status)
  returning id into v_sale_id;

  for v_item in select * from jsonb_array_elements(p_cart_items)
  loop
    v_device_id := (v_item->>'device_id')::uuid;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, (v_item->>'price')::numeric, 1);

    update public.devices set status = 'Sold' where id = v_device_id;
  end loop;

  return v_sale_id;
end;
$$;

create function public.convert_reservation_to_sale(
  p_reservation_id uuid,
  p_device_id uuid,
  p_customer_name text,
  p_customer_phone text,
  p_total_price numeric,
  p_payment_method text,
  p_reference_number text,
  p_notes text,
  p_salesperson_id uuid
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_sale_id uuid;
begin
  insert into public.sales (customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, notes, status)
  values (p_customer_name, p_customer_phone, p_salesperson_id, p_payment_method, p_reference_number, p_total_price, p_notes, 'Completed')
  returning id into v_sale_id;

  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
  values (v_sale_id, p_device_id, p_total_price, 1);

  update public.devices set status = 'Sold' where id = p_device_id;

  update public.reservations set status = 'Converted' where id = p_reservation_id;

  return v_sale_id;
end;
$$;

-- Original (broken) unit goes straight to Supplier Defective, carrying the
-- return reason over as the issue description; replacement unit is sold.
create function public.replace_return(
  p_return_id uuid,
  p_original_device_id uuid,
  p_replacement_device_id uuid,
  p_reason text
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_supplier_id uuid;
begin
  update public.customer_returns
  set status = 'Replaced', replacement_device_id = p_replacement_device_id
  where id = p_return_id;

  select supplier_id into v_supplier_id from public.devices where id = p_original_device_id;

  update public.devices set status = 'Supplier Defective' where id = p_original_device_id;

  insert into public.supplier_defective_records (device_id, supplier_id, issue_description)
  values (p_original_device_id, v_supplier_id, p_reason);

  update public.devices set status = 'Sold' where id = p_replacement_device_id;
end;
$$;

create function public.create_reservation(
  p_device_id uuid,
  p_customer_name text,
  p_customer_phone text,
  p_salesperson_id uuid,
  p_reserved_until timestamptz,
  p_total_price numeric,
  p_down_payment numeric
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_reservation_id uuid;
begin
  insert into public.reservations (device_id, customer_name, customer_phone, salesperson_id, reserved_until, total_price, down_payment, status)
  values (p_device_id, p_customer_name, p_customer_phone, p_salesperson_id, p_reserved_until, p_total_price, coalesce(p_down_payment, 0), 'Active')
  returning id into v_reservation_id;

  update public.devices set status = 'Reserved' where id = p_device_id;

  return v_reservation_id;
end;
$$;

create function public.cancel_reservation(p_reservation_id uuid, p_device_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  update public.reservations set status = 'Cancelled' where id = p_reservation_id;
  update public.devices set status = 'Available' where id = p_device_id;
end;
$$;

-- A reservation is valid through the whole of its reserved_until day, so it
-- only expires once we're a full day past that (local) midnight. The
-- update...returning CTE feeding the second update means this sweeps and
-- frees devices in one atomic statement instead of a select-then-two-updates.
create function public.expire_overdue_reservations()
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  with overdue as (
    update public.reservations
    set status = 'Expired'
    where status = 'Active'
      and reserved_until <= now() - interval '1 day'
    returning device_id
  )
  update public.devices
  set status = 'Available'
  where id in (select device_id from overdue);
end;
$$;

-- Marking Resolved puts the device back to Available. Undoing that (moving
-- the record back off Resolved) puts it back to Supplier Defective — but
-- only if the device is still sitting Available untouched since then; if
-- it's since been reserved/sold/whatever else, leave it alone rather than
-- clobbering newer state.
create function public.update_supplier_defective_status(
  p_id uuid,
  p_status text,
  p_action_taken text,
  p_device_id uuid
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_previous_status text;
  v_current_device_status text;
begin
  select status into v_previous_status from public.supplier_defective_records where id = p_id;

  update public.supplier_defective_records
  set status = p_status, action_taken = p_action_taken
  where id = p_id;

  if p_device_id is not null then
    if p_status = 'Resolved' then
      update public.devices set status = 'Available' where id = p_device_id;
    elsif v_previous_status = 'Resolved' and p_status <> 'Resolved' then
      select status into v_current_device_status from public.devices where id = p_device_id;
      if v_current_device_status = 'Available' then
        update public.devices set status = 'Supplier Defective' where id = p_device_id;
      end if;
    end if;
  end if;
end;
$$;

-- A supplier payment is a real cash outflow — reflects as an expense on
-- the day it's paid, tagged admin_only and linked back to the shell so
-- mark_bulk_order_shell_unpaid can remove exactly this expense if the
-- payment was marked by mistake.
create function public.mark_bulk_order_shell_paid(p_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_unit_cost numeric;
  v_quantity_expected int;
  v_device_name text;
  v_supplier_name text;
begin
  update public.bulk_order_shells
  set supplier_payment_status = 'Paid', supplier_paid_at = now()
  where id = p_id;

  select s.unit_cost, s.quantity_expected, s.device_name, sup.name
    into v_unit_cost, v_quantity_expected, v_device_name, v_supplier_name
  from public.bulk_order_shells s
  left join public.suppliers sup on sup.id = s.supplier_id
  where s.id = p_id;

  if v_unit_cost is not null then
    insert into public.expenses (expense_date, description, amount, admin_only, bulk_order_shell_id)
    values (
      current_date,
      'Supplier payment - ' || coalesce(v_supplier_name, 'Unknown supplier') || ' - ' || v_device_name,
      v_unit_cost * v_quantity_expected,
      true,
      p_id
    );
  end if;
end;
$$;

-- Mirrors the "un-resolve" pattern already used for supplier defective
-- records — corrects a mistaken Mark as Paid without losing history on the
-- shell itself.
create function public.mark_bulk_order_shell_unpaid(p_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  update public.bulk_order_shells
  set supplier_payment_status = 'Unpaid', supplier_paid_at = null
  where id = p_id;

  delete from public.expenses where bulk_order_shell_id = p_id;
end;
$$;

-- Folds in the "report as Supplier Defective" record creation that used to
-- be a separate follow-up call from Add Device. p_bulk_order_shell_id/
-- p_date_arrived link this unit back to an overnight shipment placeholder
-- (see bulk_order_shells) — both optional, unrelated to a device's normal
-- date_added. When linking pushes a shell's logged count up to its
-- quantity_expected, the shell flips to Completed in the same atomic call.
create function public.add_device(
  p_batch_code text,
  p_device_name text,
  p_category text,
  p_storage text,
  p_color text,
  p_status text,
  p_supplier_name text,
  p_price numeric,
  p_notes text,
  p_date_added timestamptz,
  p_issue_description text default null,
  p_bulk_order_shell_id uuid default null,
  p_date_arrived timestamptz default null,
  p_purchase_price numeric default null,
  p_condition text default null
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_supplier_id uuid;
  v_device_id uuid;
  v_linked_count int;
  v_quantity_expected int;
begin
  if p_supplier_name is null or p_supplier_name = '' then
    v_supplier_id := null;
  else
    select id into v_supplier_id from public.suppliers where name = p_supplier_name;
  end if;

  insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, selling_price, purchase_price, condition, notes, date_added, bulk_order_shell_id, date_arrived)
  values (p_batch_code, p_device_name, p_category, p_storage, p_color, p_status, v_supplier_id, p_price, p_purchase_price, p_condition, p_notes, p_date_added, p_bulk_order_shell_id, p_date_arrived)
  returning id into v_device_id;

  if p_status = 'Supplier Defective' and p_issue_description is not null then
    insert into public.supplier_defective_records (device_id, supplier_id, issue_description)
    values (v_device_id, v_supplier_id, p_issue_description);
  end if;

  if p_bulk_order_shell_id is not null then
    select count(*) into v_linked_count from public.devices where bulk_order_shell_id = p_bulk_order_shell_id;
    select quantity_expected into v_quantity_expected from public.bulk_order_shells where id = p_bulk_order_shell_id;
    if v_linked_count >= v_quantity_expected then
      update public.bulk_order_shells set status = 'Completed' where id = p_bulk_order_shell_id;
    end if;
  end if;

  return v_device_id;
end;
$$;

-- Folds in the same "report as Supplier Defective" record creation for the
-- Edit Device flow. Checks the device's OWN previous status server-side
-- (not a value handed in by the client) so it only creates a record on a
-- genuine transition into Supplier Defective.
create function public.update_device(
  p_id uuid,
  p_batch_code text,
  p_device_name text,
  p_category text,
  p_storage text,
  p_color text,
  p_status text,
  p_supplier_name text,
  p_price numeric,
  p_notes text,
  p_issue_description text default null,
  p_purchase_price numeric default null,
  p_condition text default null
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_supplier_id uuid;
  v_previous_status text;
begin
  select status into v_previous_status from public.devices where id = p_id;

  if p_supplier_name is null or p_supplier_name = '' then
    v_supplier_id := null;
  else
    select id into v_supplier_id from public.suppliers where name = p_supplier_name;
  end if;

  update public.devices
  set batch_code = p_batch_code,
      device_name = p_device_name,
      category = p_category,
      storage = p_storage,
      color = p_color,
      status = p_status,
      supplier_id = v_supplier_id,
      selling_price = p_price,
      purchase_price = p_purchase_price,
      condition = p_condition,
      notes = p_notes
  where id = p_id;

  if p_status = 'Supplier Defective' and v_previous_status <> 'Supplier Defective' and p_issue_description is not null then
    insert into public.supplier_defective_records (device_id, supplier_id, issue_description)
    values (p_id, v_supplier_id, p_issue_description);
  end if;
end;
$$;

grant execute on all functions in schema public to authenticated;

-- ============================================================
-- AUTO-CREATE PROFILE ROW ON SIGNUP
-- ============================================================

create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- ROW LEVEL SECURITY — basic authenticated-access policies.
-- Tighten these to per-role checks later (e.g. only 'admin' can delete).
-- ============================================================

alter table public.profiles enable row level security;
alter table public.suppliers enable row level security;
alter table public.devices enable row level security;
alter table public.reorder_settings enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.customer_returns enable row level security;
alter table public.supplier_defective_records enable row level security;
alter table public.reservations enable row level security;
alter table public.expenses enable row level security;
alter table public.bulk_order_shells enable row level security;

-- profiles: everyone authenticated can view (needed for salesperson lookups),
-- but a user can only update their own row.
create policy "profiles_select_authenticated" on public.profiles
  for select using (auth.role() = 'authenticated');
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- Every other table: full CRUD for any authenticated user, for now.
create policy "suppliers_all_authenticated" on public.suppliers
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "devices_all_authenticated" on public.devices
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "reorder_settings_all_authenticated" on public.reorder_settings
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "sales_all_authenticated" on public.sales
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "sale_items_all_authenticated" on public.sale_items
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "customer_returns_all_authenticated" on public.customer_returns
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "supplier_defective_records_all_authenticated" on public.supplier_defective_records
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "reservations_all_authenticated" on public.reservations
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "expenses_all_authenticated" on public.expenses
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "bulk_order_shells_all_authenticated" on public.bulk_order_shells
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
