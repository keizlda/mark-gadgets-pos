-- Lets the admin manage the product catalog (models + colors, previously
-- hardcoded in the app's source) and archive suppliers, from the UI instead
-- of a code deploy.
-- Run this in the Supabase SQL Editor (Project → SQL Editor → New query).

-- ============================================================
-- SUPPLIERS: archive instead of delete
-- ============================================================
-- Suppliers are referenced by id (not name) from devices, bulk_order_shells,
-- and supplier_defective_records — a hard delete of a supplier already used
-- anywhere would either fail on the FK or, worse, silently orphan history.
-- Archiving just hides it from future picks (SupplierSelect) while every
-- past record it's linked to keeps working exactly as before.
alter table public.suppliers add column if not exists active boolean not null default true;

-- ============================================================
-- PRODUCT MODELS: the Add Device catalog, now database-backed
-- ============================================================
-- device_name/color on devices are free text, not foreign keys — so
-- removing a model or a color here never touches existing inventory rows,
-- it only changes what's offered going forward in Add Device / Quick Add.
create table if not exists public.product_models (
  id uuid primary key default gen_random_uuid(),
  category text not null check (category in ('iPhone', 'iPad', 'Apple Watch', 'MacBook', 'Accessories', 'Repair Parts')),
  name text not null,
  colors text[] not null default '{}',
  created_at timestamptz not null default now(),
  unique (category, name)
);

alter table public.product_models enable row level security;

create policy "product_models_all_authenticated" on public.product_models
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ============================================================
-- SEED — the catalog that used to live in src/data/referenceData.js
-- ============================================================
insert into public.product_models (category, name, colors) values
  ('iPhone', 'iPhone XR', ARRAY['Black','White','Blue','Coral','Yellow','(Product)Red']),
  ('iPhone', 'iPhone 11', ARRAY['Black','Green','Yellow','Purple','White','(Product)Red']),
  ('iPhone', 'iPhone 11 Pro', ARRAY['Midnight Green','Space Gray','Silver','Gold']),
  ('iPhone', 'iPhone 11 Pro Max', ARRAY['Midnight Green','Space Gray','Silver','Gold']),
  ('iPhone', 'iPhone 12 mini', ARRAY['Black','White','(Product)Red','Green','Blue','Purple']),
  ('iPhone', 'iPhone 12', ARRAY['Black','White','(Product)Red','Green','Blue','Purple']),
  ('iPhone', 'iPhone 12 Pro', ARRAY['Graphite','Silver','Gold','Pacific Blue']),
  ('iPhone', 'iPhone 12 Pro Max', ARRAY['Graphite','Silver','Gold','Pacific Blue']),
  ('iPhone', 'iPhone 13 mini', ARRAY['Pink','Blue','Midnight','Starlight','(Product)Red','Green']),
  ('iPhone', 'iPhone 13', ARRAY['Pink','Blue','Midnight','Starlight','(Product)Red','Green']),
  ('iPhone', 'iPhone 13 Pro', ARRAY['Graphite','Gold','Silver','Sierra Blue','Alpine Green']),
  ('iPhone', 'iPhone 13 Pro Max', ARRAY['Graphite','Gold','Silver','Sierra Blue','Alpine Green']),
  ('iPhone', 'iPhone 14', ARRAY['Midnight','Starlight','(Product)Red','Blue','Purple','Yellow']),
  ('iPhone', 'iPhone 14 Plus', ARRAY['Midnight','Starlight','(Product)Red','Blue','Purple','Yellow']),
  ('iPhone', 'iPhone 14 Pro', ARRAY['Space Black','Silver','Gold','Deep Purple']),
  ('iPhone', 'iPhone 14 Pro Max', ARRAY['Space Black','Silver','Gold','Deep Purple']),
  ('iPhone', 'iPhone 15', ARRAY['Black','Blue','Green','Yellow','Pink']),
  ('iPhone', 'iPhone 15 Plus', ARRAY['Black','Blue','Green','Yellow','Pink']),
  ('iPhone', 'iPhone 15 Pro', ARRAY['Black Titanium','White Titanium','Blue Titanium','Natural Titanium']),
  ('iPhone', 'iPhone 15 Pro Max', ARRAY['Black Titanium','White Titanium','Blue Titanium','Natural Titanium']),
  ('iPhone', 'iPhone 16', ARRAY['Black','White','Pink','Teal','Ultramarine']),
  ('iPhone', 'iPhone 16 Plus', ARRAY['Black','White','Pink','Teal','Ultramarine']),
  ('iPhone', 'iPhone 16 Pro', ARRAY['Black Titanium','White Titanium','Natural Titanium','Desert Titanium']),
  ('iPhone', 'iPhone 16 Pro Max', ARRAY['Black Titanium','White Titanium','Natural Titanium','Desert Titanium']),
  ('iPhone', 'iPhone 16e', ARRAY['Black','White']),
  ('iPhone', 'iPhone 17', ARRAY['Black','White','Lavender','Sage','Mist Blue']),
  ('iPhone', 'iPhone Air', ARRAY['Space Black','Cloud White','Sky Blue','Light Gold']),
  ('iPhone', 'iPhone 17 Pro', ARRAY['Silver','Cosmic Orange','Deep Blue']),
  ('iPhone', 'iPhone 17 Pro Max', ARRAY['Silver','Cosmic Orange','Deep Blue']),

  ('iPad', 'iPad Pro M4', ARRAY['Space Black','Silver']),
  ('iPad', 'iPad Air 6', ARRAY['Space Gray','Blue','Purple','Starlight']),
  ('iPad', 'iPad 10th Gen', ARRAY['Blue','Pink','Yellow','Silver']),

  ('Apple Watch', 'Apple Watch Series 9', ARRAY['Midnight','Starlight','Silver','Pink','(Product)Red']),
  ('Apple Watch', 'Apple Watch Ultra 2', ARRAY['Natural Titanium']),
  ('Apple Watch', 'Apple Watch SE', ARRAY['Midnight','Starlight','Silver']),

  ('MacBook', 'MacBook Air M4', ARRAY['Sky Blue','Silver','Starlight','Midnight']),
  ('MacBook', 'MacBook Air M3', ARRAY['Midnight','Starlight','Space Gray','Silver']),
  ('MacBook', 'MacBook Pro 14" M4', ARRAY['Space Black','Silver']),
  ('MacBook', 'MacBook Pro 16" M4', ARRAY['Space Black','Silver']),

  ('Accessories', 'Phone Case', ARRAY['Black','Clear','Blue','Pink','Red','White']),
  ('Accessories', 'Screen Protector (Tempered Glass)', ARRAY['N/A']),
  ('Accessories', 'Charger / Power Adapter', ARRAY['White','Black']),
  ('Accessories', 'Lightning Cable', ARRAY['White','Black']),
  ('Accessories', 'USB-C Cable', ARRAY['White','Black']),
  ('Accessories', 'Wireless Earbuds', ARRAY['White','Black']),
  ('Accessories', 'Power Bank', ARRAY['Black','White']),
  ('Accessories', 'Wireless Charger', ARRAY['Black','White']),

  ('Repair Parts', 'iPhone LCD Screen', ARRAY['N/A']),
  ('Repair Parts', 'iPhone Battery', ARRAY['N/A']),
  ('Repair Parts', 'iPhone Charging Port Flex', ARRAY['N/A']),
  ('Repair Parts', 'iPhone Back Glass', ARRAY['N/A']),
  ('Repair Parts', 'iPad LCD Screen', ARRAY['N/A']),
  ('Repair Parts', 'iPad Battery', ARRAY['N/A']),
  ('Repair Parts', 'MacBook Battery', ARRAY['N/A']),
  ('Repair Parts', 'Apple Watch Battery', ARRAY['N/A'])
on conflict (category, name) do nothing;
