-- ============================================================
-- Fresh historical data: June + July 2026, main store + CGN.
-- Batch codes and Date Added are based on the ACQUISITION date
-- (embedded in the Supplier column, e.g. "lilah 05.02.26"), not the
-- sale date — a unit is often held for days/weeks before it sells.
-- Where the Supplier cell had no date, sale date is used as a fallback.
-- Two-digit dates with no year (e.g. "12.08") are assumed 2026 unless
-- that would put acquisition after the sale, in which case 2025.
--
-- Run this once in the Supabase SQL Editor, after truncating.
-- ============================================================

-- ============================================================
-- Suppliers
-- ============================================================
insert into public.suppliers (name) values
  ('Abaton'),
  ('Abraham'),
  ('Aminor'),
  ('BGC'),
  ('Bagtong'),
  ('Chikita'),
  ('Dara'),
  ('Diane Rose'),
  ('Elaine Abas'),
  ('Fr. Bagtong'),
  ('Joey'),
  ('Kathy'),
  ('Lilah'),
  ('Maam Neng'),
  ('Market Place'),
  ('Marky'),
  ('Masiba'),
  ('ND'),
  ('Neil'),
  ('Pabz'),
  ('Page'),
  ('Paul'),
  ('Ping'),
  ('Salazar'),
  ('Shy'),
  ('Sohayma'),
  ('Suki'),
  ('Susan Capitol'),
  ('Tina'),
  ('Walk-in')
on conflict (name) do nothing;

-- ============================================================
-- Main store sales — regular (111 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
begin
  for rec in select * from (values
    ('050226-001', 'iPhone 11', '128GB', 'Black', 'iPhones', 10500.0::numeric, 12500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-02'::timestamptz, '2026-06-01'::timestamptz),
    ('120825-001', 'iPhone XR', '128GB', 'Coral', 'iPhones', 9000.0::numeric, 10500.0::numeric, 'Pre-owned', 'Aminor', null, '2025-12-08'::timestamptz, '2026-06-01'::timestamptz),
    ('050226-002', 'iPhone 11', '128GB', 'White', 'iPhones', 10500.0::numeric, 15500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-02'::timestamptz, '2026-06-01'::timestamptz),
    ('050826-001', 'iPhone 16 Pro', '128GB', 'Desert', 'iPhones', 38000.0::numeric, 45000.0::numeric, 'Pre-owned', 'Maam Neng', null, '2026-05-08'::timestamptz, '2026-06-01'::timestamptz),
    ('051026-001', 'iPhone 14', '128GB', 'White', 'iPhones', 28300.0::numeric, 31000.0::numeric, 'Brand New', 'BGC', null, '2026-05-10'::timestamptz, '2026-06-02'::timestamptz),
    ('040726-001', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 20500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-04-07'::timestamptz, '2026-06-02'::timestamptz),
    ('051226-001', 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 21300.0::numeric, 27500.0::numeric, 'Brand New', 'Ping', null, '2026-05-12'::timestamptz, '2026-06-03'::timestamptz),
    ('050226-003', 'iPhone 11', '128GB', 'White', 'iPhones', 10500.0::numeric, 15500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-02'::timestamptz, '2026-06-04'::timestamptz),
    ('040726-002', 'iPhone 13', '256GB', 'Blue', 'iPhones', 17500.0::numeric, 20500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-04-07'::timestamptz, '2026-06-05'::timestamptz),
    ('040726-003', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 20500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-04-07'::timestamptz, '2026-06-05'::timestamptz),
    ('051826-001', 'iPad 10th Gen', '256GB', 'Pink Cellular', 'iPads', 25000.0::numeric, 30000.0::numeric, 'Brand New', 'ND', null, '2026-05-18'::timestamptz, '2026-06-05'::timestamptz),
    ('040526-001', 'iPad 9th Gen', '256GB', 'Black', 'iPads', 10300.0::numeric, 16000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-05'::timestamptz, '2026-06-06'::timestamptz),
    ('051026-002', 'iPhone 14', '128GB', 'Blue', 'iPhones', 28300.0::numeric, 35552.0::numeric, 'Brand New', 'BGC', null, '2026-05-10'::timestamptz, '2026-06-06'::timestamptz),
    ('041926-001', 'iPhone XR', '128GB', 'Black', 'iPhones', 8500.0::numeric, 10500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz, '2026-06-06'::timestamptz),
    ('052726-001', 'iPhone 14 Pro', '128GB', 'Silver', 'iPhones', 25500.0::numeric, 31000.0::numeric, 'Pre-owned', 'Page', null, '2026-05-27'::timestamptz, '2026-06-08'::timestamptz),
    ('053026-001', 'iPhone 16 Pro Max', '256GB', 'Natural', 'iPhones', 46500.0::numeric, 57500.0::numeric, 'Pre-owned', 'Suki', null, '2026-05-30'::timestamptz, '2026-06-08'::timestamptz),
    ('060526-001', 'iPhone 16PLUS', '128GB', 'White', 'iPhones', 36000.0::numeric, 44500.0::numeric, 'Pre-owned', 'Masiba', null, '2026-06-05'::timestamptz, '2026-06-08'::timestamptz),
    ('051126-001', 'iPhone 12 Pro Max', '256GB', 'Gold', 'iPhones', 13350.0::numeric, 20000.0::numeric, 'Pre-owned', 'Diane Rose', null, '2026-05-11'::timestamptz, '2026-06-12'::timestamptz),
    ('052026-001', 'iPhone 12 Pro Max', '256GB', 'Blue', 'iPhones', 13500.0::numeric, 23000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-05-20'::timestamptz, '2026-06-12'::timestamptz),
    ('052826-001', 'iPhone 11 Pro', '256GB', 'Black', 'iPhones', 13200.0::numeric, 18500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz, '2026-06-13'::timestamptz),
    ('051526-001', 'iPad 11th Gen', '128GB', 'Blue', 'iPads', 21000.0::numeric, 23800.0::numeric, 'Brand New', 'Sohayma', null, '2026-05-15'::timestamptz, '2026-06-13'::timestamptz),
    ('051326-001', 'iPhone 17 Pro', '256GB', 'Silver', 'iPhones', 57000.0::numeric, 73000.0::numeric, 'Pre-owned', 'Joey', null, '2026-05-13'::timestamptz, '2026-06-15'::timestamptz),
    ('061626-001', 'iPhone 14+', '256GB', 'Black', 'iPhones', 22500.0::numeric, 23500.0::numeric, 'Pre-owned', 'Paul', null, '2026-06-16'::timestamptz, '2026-06-16'::timestamptz),
    ('060226-001', 'iPhone 14 Pro Max', '128GB', 'Purple', 'iPhones', 28000.0::numeric, 35000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-06-02'::timestamptz, '2026-06-16'::timestamptz),
    ('060826-001', 'iPhone 17', '256GB', 'Mist', 'iPhones', 51000.0::numeric, 55300.0::numeric, 'Brand New', 'ND', null, '2026-06-08'::timestamptz, '2026-06-16'::timestamptz),
    ('043026-001', 'Samsung Fold 6', null, null, 'Accessories', 30000.0::numeric, 45000.0::numeric, 'Pre-owned', 'Maam Neng', null, '2026-04-30'::timestamptz, '2026-06-16'::timestamptz),
    ('061526-001', 'iPhone 13 Pro', '256GB', 'Gold', 'iPhones', 20500.0::numeric, 25500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-06-15'::timestamptz, '2026-06-17'::timestamptz),
    ('052826-002', 'iPhone 11 Pro', '256GB', 'Gold', 'iPhones', 13200.0::numeric, 15500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz, '2026-06-18'::timestamptz),
    ('053126-001', 'iPhone 17 Pro Max', '256GB', 'Silver', 'iPhones', 67000.0::numeric, 76000.0::numeric, 'Pre-owned', 'Marky', null, '2026-05-31'::timestamptz, '2026-06-22'::timestamptz),
    ('040926-001', 'iPhone 11PM', '256GB', 'Gold', 'iPhones', 13000.0::numeric, 22500.0::numeric, 'Pre-owned', 'Market Place', null, '2026-04-09'::timestamptz, '2026-06-22'::timestamptz),
    ('051526-002', 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 21500.0::numeric, 23500.0::numeric, 'Brand New', 'Sohayma', null, '2026-05-15'::timestamptz, '2026-06-22'::timestamptz),
    ('062226-001', 'iPhone 13', '128GB', 'Pink', 'iPhones', 17500.0::numeric, 20500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-06-23'::timestamptz),
    ('061926-001', 'iPhone 16 Pro Max', '256GB', 'Black', 'iPhones', 38000.0::numeric, 57500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-06-19'::timestamptz, '2026-06-24'::timestamptz),
    ('051526-003', 'iPhone 17 Pro Max', '256GB', 'Cosmic', 'iPhones', 78300.0::numeric, 83500.0::numeric, 'Brand New', 'BGC', null, '2026-05-15'::timestamptz, '2026-06-24'::timestamptz),
    ('062226-002', 'iPhone 13', '128GB', 'Black', 'iPhones', 17500.0::numeric, 20500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-06-24'::timestamptz),
    ('061226-001', 'iPhone 17 Pro Max', '256GB', 'Cosmic', 'iPhones', 63000.0::numeric, 74000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-06-12'::timestamptz, '2026-06-25'::timestamptz),
    ('062226-003', 'iPhone 11', '128GB', 'Black', 'iPhones', 11000.0::numeric, 12500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-06-25'::timestamptz),
    ('052226-001', 'iPhone 12', '256GB', 'White', 'iPhones', 13200.0::numeric, 16000.0::numeric, 'Pre-owned', 'Page', null, '2026-05-22'::timestamptz, '2026-06-25'::timestamptz),
    ('051526-004', 'iPad 11th Gen', '128GB', 'Pink', 'iPads', 21000.0::numeric, 23800.0::numeric, 'Brand New', 'Sohayma', null, '2026-05-15'::timestamptz, '2026-06-25'::timestamptz),
    ('062526-001', 'iPad 6th Gen', '128GB', 'Pink', 'iPads', 6500.0::numeric, 8500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-25'::timestamptz, '2026-06-25'::timestamptz),
    ('040526-002', 'iPad 9th Gen', '256GB', 'Silver', 'iPads', 10300.0::numeric, 12500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-05'::timestamptz, '2026-06-26'::timestamptz),
    ('061526-002', 'iPad Air 5 M1', '256GB', 'Blue', 'iPads', 15000.0::numeric, 24000.0::numeric, 'Pre-owned', null, 'Swap trade-in (from Supplier column): swap 06.15', '2026-06-15'::timestamptz, '2026-06-26'::timestamptz),
    ('062426-001', 'iPhone 15 Pro Max', '512GB', 'Natural', 'iPhones', 38000.0::numeric, 48000.0::numeric, 'Pre-owned', 'Walk-in', 'Supplier column had no name, only a date ("06.24.26") — defaulted to Walk-in.', '2026-06-24'::timestamptz, '2026-06-26'::timestamptz),
    ('051026-003', 'iPhone 14', '128GB', 'White', 'iPhones', 28300.0::numeric, 34000.0::numeric, 'Brand New', 'BGC', null, '2026-05-10'::timestamptz, '2026-06-28'::timestamptz),
    ('050826-002', 'iPhone 16 Plus', '128GB', 'Pink', 'iPhones', 35000.0::numeric, 41500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-05-08'::timestamptz, '2026-06-29'::timestamptz),
    ('062726-001', 'iPad 11th Gen', '128GB', 'Pink', 'iPads', 15000.0::numeric, 21000.0::numeric, 'Brand New', 'Walk-in', null, '2026-06-27'::timestamptz, '2026-06-29'::timestamptz),
    ('062226-004', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 20000.0::numeric, 'Pre-owned', 'Abaton', null, '2026-06-22'::timestamptz, '2026-06-30'::timestamptz),
    ('062526-002', 'iPhone 16 Pro Max', '256GB', 'Black', 'iPhones', 31000.0::numeric, 51000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-06-25'::timestamptz, '2026-07-02'::timestamptz),
    ('070226-001', 'Samsung S22', null, null, 'Accessories', 10000.0::numeric, 12000.0::numeric, 'Pre-owned', 'Neil', 'Non-Apple device (Samsung) — filed under Accessories since the catalog has no Android category. Sheet only gave Net Profit (₱2,000), Capital/Disposal were blank — inferred as ₱10,000 bought / ₱12,000 sold, matching the stated profit exactly.', '2026-07-02'::timestamptz, '2026-07-02'::timestamptz),
    ('050226-004', 'iPhone 11', '128GB', 'White', 'iPhones', 10500.0::numeric, 12500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-05-02'::timestamptz, '2026-07-02'::timestamptz),
    ('062226-005', 'iPhone 13', '256GB', 'Black', 'iPhones', 17500.0::numeric, 20500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-02'::timestamptz),
    ('070226-002', 'iPhone 15 Pro', '128GB', 'Natural', 'iPhones', 23800.0::numeric, 32000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-02'::timestamptz, '2026-07-02'::timestamptz),
    ('062226-006', 'iPhone 11', '128GB', 'White', 'iPhones', 11000.0::numeric, 12000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-03'::timestamptz),
    ('062226-007', 'iPhone 11', '128GB', 'Purple', 'iPhones', 11000.0::numeric, 12000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-03'::timestamptz),
    ('063026-001', 'MacBook Neo', '256GB', 'Blue', 'MacBooks', 30000.0::numeric, 41500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-06-30'::timestamptz, '2026-07-03'::timestamptz),
    ('070326-001', 'iPhone SE', '128GB', 'Black', 'iPhones', 6000.0::numeric, 8500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-03'::timestamptz, '2026-07-03'::timestamptz),
    ('022826-001', 'iPhone 14', '128GB', 'Black', 'iPhones', 20500.0::numeric, 22500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-02-28'::timestamptz, '2026-07-03'::timestamptz),
    ('062226-008', 'iPhone 11', '128GB', 'White', 'iPhones', 11000.0::numeric, 12500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-04'::timestamptz),
    ('062226-009', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 23500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-04'::timestamptz),
    ('040826-001', 'iPhone 15', '128GB', 'Black', 'iPhones', 25000.0::numeric, 32500.0::numeric, 'Pre-owned', 'Pabz', null, '2026-04-08'::timestamptz, '2026-07-05'::timestamptz),
    ('051526-005', 'iPad 11th Gen', null, 'Silver', 'iPads', 21500.0::numeric, 28000.0::numeric, 'Brand New', 'Sohayma', null, '2026-05-15'::timestamptz, '2026-07-05'::timestamptz),
    ('062226-010', 'iPhone 13 Pro Max', '128GB', 'Gold', 'iPhones', 22000.0::numeric, 27000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-06-22'::timestamptz, '2026-07-05'::timestamptz),
    ('040526-003', 'iPad 9th Gen', '256GB', 'Black', 'iPads', 10300.0::numeric, 12500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-05'::timestamptz, '2026-07-06'::timestamptz),
    ('040526-004', 'iPad 9th Gen', '256GB', 'Black', 'iPads', 10300.0::numeric, 12300.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-05'::timestamptz, '2026-07-06'::timestamptz),
    ('062226-011', 'iPhone 11', '128GB', 'White', 'iPhones', 11000.0::numeric, 12700.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-07'::timestamptz),
    ('062226-012', 'iPhone 11', '128GB', 'Mint', 'iPhones', 11000.0::numeric, 12700.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-08'::timestamptz),
    ('051526-006', 'iPad 11th Gen', null, 'Blue', 'iPads', 21500.0::numeric, 25500.0::numeric, 'Brand New', 'Sohayma', null, '2026-05-15'::timestamptz, '2026-07-08'::timestamptz),
    ('051526-007', 'iPad 11th Gen', null, 'Blue', 'iPads', 21500.0::numeric, 25500.0::numeric, 'Brand New', 'Sohayma', null, '2026-05-15'::timestamptz, '2026-07-08'::timestamptz),
    ('040526-005', 'iPad 9th Gen', '256GB', 'Black', 'iPads', 10300.0::numeric, 12300.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-05'::timestamptz, '2026-07-08'::timestamptz),
    ('062226-013', 'iPhone 13', '128GB', 'Pink', 'iPhones', 16500.0::numeric, 22500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-08'::timestamptz),
    ('070826-001', 'iPhone 17PM', '256GB', 'Cosmic', 'iPhones', 78000.0::numeric, 84500.0::numeric, 'Brand New', 'BGC', null, '2026-07-08'::timestamptz, '2026-07-08'::timestamptz),
    ('051526-008', 'iPad 11th Gen', '128GB', 'Blue', 'iPads', 21500.0::numeric, 25500.0::numeric, 'Brand New', 'Sohayma', null, '2026-05-15'::timestamptz, '2026-07-09'::timestamptz),
    ('070926-001', 'iPhone 16', '128GB', 'White', 'iPhones', 30000.0::numeric, 38000.0::numeric, 'Pre-owned', 'Abraham', null, '2026-07-09'::timestamptz, '2026-07-10'::timestamptz),
    ('070226-003', 'iPhone 16 Pro Max', '256GB', 'Dessert', 'iPhones', 40500.0::numeric, 57000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-02'::timestamptz, '2026-07-11'::timestamptz),
    ('071026-001', 'iPad Air M3', '128GB', '13 Inch', 'iPads', 25500.0::numeric, 35500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-10'::timestamptz, '2026-07-11'::timestamptz),
    ('052226-002', 'iPhone 17PM', '256GB', 'Blue', 'iPhones', 78500.0::numeric, 88500.0::numeric, 'Brand New', 'Pabz', null, '2026-05-22'::timestamptz, '2026-07-11'::timestamptz),
    ('070326-002', 'iPhone 13 Pro', '256GB', 'Gold', 'iPhones', 22000.0::numeric, 26000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-03'::timestamptz, '2026-07-11'::timestamptz),
    ('041526-001', 'iPhone 15PM', '256GB', 'Natural', 'iPhones', 39000.0::numeric, 48500.0::numeric, 'Pre-owned', 'Chikita', null, '2026-04-15'::timestamptz, '2026-07-12'::timestamptz),
    ('061026-001', 'iPhone 11', '128GB', 'Black', 'iPhones', 10700.0::numeric, 12500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz, '2026-07-13'::timestamptz),
    ('051026-004', 'iPhone 14', '128GB', 'White', 'iPhones', 28300.0::numeric, 31500.0::numeric, 'Brand New', 'BGC', null, '2026-05-10'::timestamptz, '2026-07-14'::timestamptz),
    ('070826-002', 'iPad 11th Gen', '128GB', 'Pink', 'iPads', 24000.0::numeric, 26500.0::numeric, 'Brand New', 'Sohayma', null, '2026-07-08'::timestamptz, '2026-07-14'::timestamptz),
    ('051526-009', 'iPad 11th Gen', '128GB', 'Blue', 'iPads', 21500.0::numeric, 25500.0::numeric, 'Brand New', 'Sohayma', null, '2026-05-15'::timestamptz, '2026-07-16'::timestamptz),
    ('120825-002', 'iPhone XR', '128GB', 'Black', 'iPhones', 9000.0::numeric, 10500.0::numeric, 'Pre-owned', 'Aminor', null, '2025-12-08'::timestamptz, '2026-07-16'::timestamptz),
    ('070826-003', 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 24000.0::numeric, 26500.0::numeric, 'Brand New', 'Sohayma', null, '2026-07-08'::timestamptz, '2026-07-16'::timestamptz),
    ('051226-002', 'iPhone 16PM', '256GB', 'Dessert', 'iPhones', 45500.0::numeric, 57000.0::numeric, 'Pre-owned', 'Kathy', null, '2026-05-12'::timestamptz, '2026-07-16'::timestamptz),
    ('062226-014', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 20500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-17'::timestamptz),
    ('061026-002', 'iPhone 11', '128GB', 'Mint', 'iPhones', 10700.0::numeric, 16500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz, '2026-07-17'::timestamptz),
    ('071426-001', 'iPhone 13PM', '128GB', 'Gold', 'iPhones', 22500.0::numeric, 27000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-14'::timestamptz, '2026-07-17'::timestamptz),
    ('062226-015', 'iPhone 13', '256GB', 'Black', 'iPhones', 17500.0::numeric, 20500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-18'::timestamptz),
    ('070826-004', 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 24000.0::numeric, 27500.0::numeric, 'Brand New', 'Sohayma', null, '2026-07-08'::timestamptz, '2026-07-19'::timestamptz),
    ('062226-037', 'iPhone 13', '128GB', 'White', 'iPhones', 16500.0::numeric, 22000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-20'::timestamptz),
    ('071226-001', 'iPhone 16', '256GB', 'Teal', 'iPhones', 31500.0::numeric, 38500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-12'::timestamptz, '2026-07-21'::timestamptz),
    ('051826-002', 'iPad 10th Gen', '256GB', 'Pink Wifi + Cel', 'iPads', 25000.0::numeric, 30000.0::numeric, 'Brand New', 'ND', null, '2026-05-18'::timestamptz, '2026-07-21'::timestamptz),
    ('041926-002', 'iPhone XR', '128GB', 'Black', 'iPhones', 8500.0::numeric, 13000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz, '2026-07-22'::timestamptz),
    ('071626-001', 'iPad 10th Gen', '256GB', 'Blue', 'iPads', 13500.0::numeric, 20000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-16'::timestamptz, '2026-07-22'::timestamptz),
    ('062226-038', 'iPhone 13', '128GB', 'White', 'iPhones', 16500.0::numeric, 22500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-22'::timestamptz),
    ('022526-001', 'iPad 10th Gen', '64GB', 'Silver', 'iPads', 14000.0::numeric, 16000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-02-25'::timestamptz, '2026-07-23'::timestamptz),
    ('062226-039', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 20500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-23'::timestamptz),
    ('070926-002', 'iPhone 16 Pro Max', '256GB', 'Dessert', 'iPhones', 50000.0::numeric, 59500.0::numeric, 'Pre-owned', 'Tina', null, '2026-07-09'::timestamptz, '2026-07-24'::timestamptz),
    ('062226-040', 'iPhone 11', '128GB', 'White', 'iPhones', 11000.0::numeric, 12500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-24'::timestamptz),
    ('062726-002', 'iPhone 14PM', '128GB', 'Black', 'iPhones', 30000.0::numeric, 36500.0::numeric, 'Pre-owned', 'Fr. Bagtong', null, '2026-06-27'::timestamptz, '2026-07-24'::timestamptz),
    ('071626-002', 'MacBook Neo', '256GB', 'Pink', 'MacBooks', 30000.0::numeric, 40000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-16'::timestamptz, '2026-07-25'::timestamptz),
    ('041926-003', 'iPhone XR', '128GB', 'White', 'iPhones', 8500.0::numeric, 10500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz, '2026-07-26'::timestamptz),
    ('062226-041', 'iPhone 11', '128GB', 'Black', 'iPhones', 11000.0::numeric, 12500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-27'::timestamptz),
    ('062226-042', 'iPhone 11', '128GB', 'Purple', 'iPhones', 11000.0::numeric, 12500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz, '2026-07-27'::timestamptz),
    ('072726-001', 'iPad Air M1', '64GB', 'Silver', 'iPads', 21000.0::numeric, 23000.0::numeric, 'Pre-owned', 'Dara', null, '2026-07-27'::timestamptz, '2026-07-27'::timestamptz),
    ('052826-019', 'iPhone 11 Pro', '256GB', 'Black', 'iPhones', 13200.0::numeric, 15000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz, '2026-07-28'::timestamptz),
    ('072826-001', 'MacBook Pro', '512GB', 'Silver', 'MacBooks', 32000.0::numeric, 40500.0::numeric, 'Pre-owned', 'Masiba', null, '2026-07-28'::timestamptz, '2026-07-28'::timestamptz),
    ('072926-001', 'MacBook Air M3', '256GB', 'Grey', 'MacBooks', 40000.0::numeric, 55500.0::numeric, 'Pre-owned', 'Neil', null, '2026-07-29'::timestamptz, '2026-07-29'::timestamptz),
    ('073026-001', 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 20000.0::numeric, 27500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-07-30'::timestamptz, '2026-07-30'::timestamptz),
    ('040526-006', 'iPad 9th Gen', '256GB', 'Silver', 'iPads', 10300.0::numeric, 12500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-05'::timestamptz, '2026-07-30'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added, sold_at)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sales (payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
    values ('Cash', rec.note, rec.disposal, 'Completed', 'Regular', 'Paid', rec.sold_at)
    returning id into v_sale_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- Main store sales — Mona (bulk buyer) (45 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (23000.0::numeric),
    (23000.0::numeric),
    (25000.0::numeric),
    (17500.0::numeric),
    (17500.0::numeric),
    (17500.0::numeric),
    (17500.0::numeric),
    (17500.0::numeric),
    (17500.0::numeric),
    (17500.0::numeric),
    (17500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (11800.0::numeric),
    (11800.0::numeric),
    (11800.0::numeric),
    (11800.0::numeric),
    (11800.0::numeric),
    (11800.0::numeric),
    (11800.0::numeric),
    (11800.0::numeric),
    (11800.0::numeric),
    (11800.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (18500.0::numeric),
    (42500.0::numeric),
    (42500.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('Mona', 'Cash', null, v_total, 'Completed', 'Bulk', 'Paid', '2026-07-18'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('123025-001', 'iPhone 13 Pro', '128GB', 'Black', 'iPhones', 22800.0::numeric, 23000.0::numeric, 'Pre-owned', 'Aminor', null, '2025-12-30'::timestamptz),
    ('052926-001', 'iPhone 13 Pro', '128GB', 'Gold', 'iPhones', 19000.0::numeric, 23000.0::numeric, 'Pre-owned', 'Joey', null, '2026-05-29'::timestamptz),
    ('060826-002', 'iPhone 13 Pro', '256GB', 'White', 'iPhones', 22000.0::numeric, 25000.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-06-08'::timestamptz),
    ('052826-003', 'iPhone 13', '128GB', 'White', 'iPhones', 16000.0::numeric, 17500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-004', 'iPhone 13', '128GB', 'White', 'iPhones', 16000.0::numeric, 17500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-005', 'iPhone 13', '128GB', 'White', 'iPhones', 16000.0::numeric, 17500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-006', 'iPhone 13', '128GB', 'White', 'iPhones', 16000.0::numeric, 17500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-007', 'iPhone 13', '128GB', 'Black', 'iPhones', 16000.0::numeric, 17500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-008', 'iPhone 13', '128GB', 'Black', 'iPhones', 16000.0::numeric, 17500.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('062226-016', 'iPhone 13', '128GB', 'Black', 'iPhones', 16500.0::numeric, 17500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('121725-001', 'iPhone 13', '128GB', 'Green', 'iPhones', 18600.0::numeric, 17500.0::numeric, 'Pre-owned', null, 'Trade-in note (from Supplier column): swap 12pm 12.17', '2025-12-17'::timestamptz),
    ('040726-004', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-04-07'::timestamptz),
    ('040726-005', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-04-07'::timestamptz),
    ('061026-003', 'iPhone 11', '128GB', 'Black', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-004', 'iPhone 11', '128GB', 'Black', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-005', 'iPhone 11', '128GB', 'Black', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-006', 'iPhone 11', '128GB', 'Black', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-007', 'iPhone 11', '128GB', 'Black', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-008', 'iPhone 11', '128GB', 'White', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-009', 'iPhone 11', '128GB', 'White', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-010', 'iPhone 11', '128GB', 'White', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-011', 'iPhone 11', '128GB', 'Mint', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-012', 'iPhone 11', '128GB', 'Mint', 'iPhones', 10700.0::numeric, 11800.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('062226-017', 'iPhone 13', '256GB', 'Black', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-018', 'iPhone 13', '256GB', 'Black', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-019', 'iPhone 13', '256GB', 'Black', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-020', 'iPhone 13', '256GB', 'Black', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-021', 'iPhone 13', '256GB', 'Black', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-022', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-023', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-024', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-025', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-026', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-027', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-028', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-029', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-030', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-031', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-032', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-033', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-034', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-035', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-036', 'iPhone 13', '256GB', 'White', 'iPhones', 17500.0::numeric, 18500.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('071826-001', 'RS iPhone 16', '128GB', 'Pink', 'iPhones', 39000.0::numeric, 42500.0::numeric, 'Pre-owned', null, 'Original ledger notation in Supplier column: "rs nd" — RS = resealed iPhone (dealer grading code), not a supplier.', '2026-07-18'::timestamptz),
    ('071826-002', 'RS iPhone 16', '128GB', 'Black', 'iPhones', 39000.0::numeric, 42500.0::numeric, 'Pre-owned', null, 'Original ledger notation in Supplier column: "rs nd" — RS = resealed iPhone (dealer grading code), not a supplier.', '2026-07-18'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- Main store sales — ND (bulk buyer) (10 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (18000.0::numeric),
    (18000.0::numeric),
    (18000.0::numeric),
    (18000.0::numeric),
    (18000.0::numeric),
    (18000.0::numeric),
    (18000.0::numeric),
    (18000.0::numeric),
    (18000.0::numeric),
    (18000.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('ND', 'Cash', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.', v_total, 'Completed', 'Bulk', 'Pending', '2026-07-18'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('052826-009', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-010', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-011', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-012', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-013', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-014', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-015', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-016', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-017', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-018', 'iPhone 13', '128GB', null, 'iPhones', 16000.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 0 (10 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (10000.0::numeric),
    (10000.0::numeric),
    (10000.0::numeric),
    (10000.0::numeric),
    (10000.0::numeric),
    (10000.0::numeric),
    (10000.0::numeric),
    (10000.0::numeric),
    (10000.0::numeric),
    (10000.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Pending', '2026-06-01'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('041926-004', 'iPhone XR', '128GB', 'Blue', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz),
    ('041926-005', 'iPhone XR', '128GB', 'Blue', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz),
    ('041926-006', 'iPhone XR', '128GB', 'Black', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz),
    ('041926-007', 'iPhone XR', '128GB', 'Black', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz),
    ('041926-008', 'iPhone XR', '128GB', 'Black', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz),
    ('041926-009', 'iPhone XR', '128GB', 'Black', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz),
    ('041926-010', 'iPhone XR', '128GB', 'White', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz),
    ('041926-011', 'iPhone XR', '128GB', 'White', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz),
    ('041926-012', 'iPhone XR', '128GB', 'White', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz),
    ('041926-013', 'iPhone XR', '128GB', 'Red', 'iPhones', 8500.0::numeric, 10000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-04-19'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 1 (5 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (14000.0::numeric),
    (14000.0::numeric),
    (14000.0::numeric),
    (14000.0::numeric),
    (14000.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Pending', '2026-06-01'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('050626-001', 'iPhone 12', '128GB', 'Blue', 'iPhones', 12200.0::numeric, 14000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-06'::timestamptz),
    ('050626-002', 'iPhone 12', '128GB', 'Blue', 'iPhones', 12200.0::numeric, 14000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-06'::timestamptz),
    ('050626-003', 'iPhone 12', '128GB', 'Black', 'iPhones', 12200.0::numeric, 14000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-06'::timestamptz),
    ('050626-004', 'iPhone 12', '128GB', 'Purple', 'iPhones', 12200.0::numeric, 14000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-06'::timestamptz),
    ('050626-005', 'iPhone 12', '128GB', 'White', 'iPhones', 12200.0::numeric, 14000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-06'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 2 (3 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (19000.0::numeric),
    (19000.0::numeric),
    (19000.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Paid', '2026-06-01'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('040726-006', 'iPhone 13', '256GB', 'Blue', 'iPhones', 17500.0::numeric, 19000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-04-07'::timestamptz),
    ('012326-001', 'iPhone 13', '256GB', 'White', 'iPhones', 17600.0::numeric, 19000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-01-23'::timestamptz),
    ('040726-007', 'iPhone 13', '256GB', 'Black', 'iPhones', 17500.0::numeric, 19000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-04-07'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 3 (2 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (22800.0::numeric),
    (22800.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Paid', '2026-06-08'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('051226-003', 'iPad 11th Gen', '128GB', 'Pink', 'iPads', 21300.0::numeric, 22800.0::numeric, 'Brand New', 'Ping', null, '2026-05-12'::timestamptz),
    ('051226-004', 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 21300.0::numeric, 22800.0::numeric, 'Brand New', 'Ping', null, '2026-05-12'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 4 (3 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (18000.0::numeric),
    (18000.0::numeric),
    (18000.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Paid', '2026-06-08'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('052826-020', 'iPhone 13', '128GB', 'Black', 'iPhones', 16500.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-021', 'iPhone 13', '128GB', 'Black', 'iPhones', 16500.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz),
    ('052826-022', 'iPhone 13', '128GB', 'Blue', 'iPhones', 16500.0::numeric, 18000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-05-28'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 5 (10 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (12200.0::numeric),
    (12200.0::numeric),
    (12200.0::numeric),
    (12200.0::numeric),
    (12200.0::numeric),
    (12200.0::numeric),
    (12200.0::numeric),
    (12200.0::numeric),
    (12200.0::numeric),
    (12200.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Pending', '2026-06-10'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('061026-013', 'iPhone 11', '128GB', 'Black', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-014', 'iPhone 11', '128GB', 'Black', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-015', 'iPhone 11', '128GB', 'Black', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-016', 'iPhone 11', '128GB', 'Black', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-017', 'iPhone 11', '128GB', 'Black', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-018', 'iPhone 11', '128GB', 'White', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-019', 'iPhone 11', '128GB', 'White', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-020', 'iPhone 11', '128GB', 'White', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-021', 'iPhone 11', '128GB', 'White', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-022', 'iPhone 11', '128GB', 'Yellow', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 6 (3 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (27500.0::numeric),
    (28500.0::numeric),
    (32500.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Paid', '2026-06-11'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('053126-004', 'iPhone 13 Pro Max', '128GB', 'Blue', 'iPhones', 22000.0::numeric, 27500.0::numeric, 'Pre-owned', 'Walk-in', null, '2026-05-31'::timestamptz),
    ('052626-001', 'iPhone 13 Pro Max', '256GB', 'Blue', 'iPhones', 23500.0::numeric, 28500.0::numeric, 'Pre-owned', 'Neil', null, '2026-05-26'::timestamptz),
    ('060826-007', 'iPhone 14 Pro Max', '128GB', 'Gold', 'iPhones', 25000.0::numeric, 32500.0::numeric, 'Pre-owned', 'Page', null, '2026-06-08'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 7 (3 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (19000.0::numeric),
    (19000.0::numeric),
    (19000.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Paid', '2026-06-19'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('040726-008', 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500.0::numeric, 19000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-04-07'::timestamptz),
    ('040726-009', 'iPhone 13', '256GB', 'Blue', 'iPhones', 17500.0::numeric, 19000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-04-07'::timestamptz),
    ('021426-001', 'iPhone 13', '256GB', 'White', 'iPhones', 17600.0::numeric, 19000.0::numeric, 'Pre-owned', 'Lilah', null, '2026-02-14'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 8 (1 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (22800.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Paid', '2026-06-19'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('051526-010', 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 21000.0::numeric, 22800.0::numeric, 'Brand New', 'Sohayma', null, '2026-05-15'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 9 (2 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (18000.0::numeric),
    (18000.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Paid', '2026-06-23'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('062226-044', 'iPhone 13', '128GB', 'White', 'iPhones', 16500.0::numeric, 18000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz),
    ('062226-045', 'iPhone 13', '128GB', 'White', 'iPhones', 16500.0::numeric, 18000.0::numeric, 'Pre-owned', 'Sohayma', null, '2026-06-22'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- CGN wholesale — block 10 (3 units)
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_total numeric;
begin
  select sum(disposal) into v_total from (values
    (12200.0::numeric),
    (12200.0::numeric),
    (12200.0::numeric)
  ) as t(disposal);

  insert into public.sales (customer_name, payment_method, notes, total_amount, status, order_type, payment_status, sold_at)
  values ('CGN', 'Cash', null, v_total, 'Completed', 'Bulk', 'Paid', '2026-06-24'::timestamptz)
  returning id into v_sale_id;

  for rec in select * from (values
    ('061026-023', 'iPhone 11', '128GB', 'White', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-024', 'iPhone 11', '128GB', 'Mint', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz),
    ('061026-025', 'iPhone 11', '128GB', 'Purple', 'iPhones', 10800.0::numeric, 12200.0::numeric, 'Pre-owned', 'Lilah', null, '2026-06-10'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, disposal, condition, supplier_name, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold', v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note, rec.date_added)
    returning id into v_device_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- Add-on purchases (34 units) — walk-in acquisitions, all still
-- unsold (status Available, Selling Price 0). 25 units originally
-- logged here were confirmed resold later the same period under a
-- separate batch code in Main Sales/CGN — those are intentionally
-- left out entirely (the Main Sales/CGN row already has the correct
-- capital/disposal for that sale), rather than inserted twice.
-- ============================================================
do $$
declare
  rec record;
  v_supplier_id uuid;
begin
  for rec in select * from (values
    ('053026-003', 'iPhone 17 Pro Max', '256GB', 'Silver', 'iPhones', 79500.0::numeric, 'Brand New', 'ND', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-05-30'::timestamptz),
    ('053026-004', 'iPhone 17 Pro Max', '256GB', 'Silver', 'iPhones', 79000.0::numeric, 'Brand New', 'ND', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-05-30'::timestamptz),
    ('060526-003', 'iPhone 16', '128GB', 'Teal', 'iPhones', 31000.0::numeric, 'Pre-owned', 'Masiba', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-05'::timestamptz),
    ('060826-004', 'iPhone 13 Pro', '256GB', 'Silver', 'iPhones', 22000.0::numeric, 'Pre-owned', 'Page', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-08'::timestamptz),
    ('060826-005', 'iPhone 17 Pro Max', '256GB', 'Silver', 'iPhones', 78500.0::numeric, 'Brand New', 'ND', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-08'::timestamptz),
    ('061626-002', 'iPhone 12 Pro Max', '256GB', 'Blue', 'iPhones', 19500.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-16'::timestamptz),
    ('061626-003', 'iPhone 13 Pro Max', '256GB', 'Blue', 'iPhones', 23000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-16'::timestamptz),
    ('061626-004', 'iPhone 12 Pro Max', '256GB', 'Blue', 'iPhones', 9000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Received with a defective speaker — Supplier column said "defective speaker", not a real supplier name, defaulted to Walk-in. Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-16'::timestamptz),
    ('062126-001', 'iPhone 13 Pro Max', '128GB', 'Blue', 'iPhones', 17000.0::numeric, 'Pre-owned', 'Elaine Abas', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-21'::timestamptz),
    ('062426-002', 'iPhone 15PM', '1TB', 'Blue', 'iPhones', 38000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-24'::timestamptz),
    ('062526-004', 'iPhone 16 Pro Max', '256GB', 'Silver', 'iPhones', 40000.0::numeric, 'Pre-owned', 'Susan Capitol', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-25'::timestamptz),
    ('062726-003', 'iPhone 14 Pro Max', '128GB', 'Purple', 'iPhones', 30000.0::numeric, 'Pre-owned', 'Bagtong', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-27'::timestamptz),
    ('062826-001', 'iPhone 12', '128GB', 'White', 'iPhones', 12000.0::numeric, 'Pre-owned', 'Shy', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-06-28'::timestamptz),
    ('070126-001', 'iWatch SE Gen 2 44mm', null, null, 'Apple Watches', 5000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-01'::timestamptz),
    ('070226-004', 'iPhone 16 Pro Max', '256GB', 'Gold', 'iPhones', 40000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-02'::timestamptz),
    ('070326-003', 'iPhone 11 Pro', '256GB', 'Gold', 'iPhones', 4000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-03'::timestamptz),
    ('070926-003', 'iPhone 16 Pro Max', '256GB', 'Gold', 'iPhones', 50000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-09'::timestamptz),
    ('071026-002', 'iPhone 17 Pro', '256GB', 'Silver', 'iPhones', 48000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-10'::timestamptz),
    ('071026-003', 'iPad Air M3', '128GB', 'Grey', 'iPads', 25000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-10'::timestamptz),
    ('071126-001', 'RS iPhone 16', '128GB', 'Silver', 'iPhones', 36000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-11'::timestamptz),
    ('072126-001', 'iPhone 12', '128GB', 'White', 'iPhones', 12000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-21'::timestamptz),
    ('072126-002', 'iPhone 17PM', '256GB', 'Blue', 'iPhones', 70500.0::numeric, 'Brand New', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-21'::timestamptz),
    ('072326-001', 'iPhone 13 Pro', '128GB', 'Gold', 'iPhones', 22000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-23'::timestamptz),
    ('072326-002', 'iPhone 13 Pro', '256GB', 'Silver', 'iPhones', 22000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-23'::timestamptz),
    ('072426-001', 'iPhone 14 Pro Max', '128GB', 'Deep P', 'iPhones', 26000.0::numeric, 'Pre-owned', 'Neil', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-24'::timestamptz),
    ('072426-002', 'iPhone 14 Pro Max', '256GB', 'Deep P', 'iPhones', 27000.0::numeric, 'Pre-owned', 'Neil', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-24'::timestamptz),
    ('072726-002', 'iPhone 13 Pro Max', '256GB', 'Gold', 'iPhones', 23000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-27'::timestamptz),
    ('072726-003', 'iPhone 14', '128GB', 'Black', 'iPhones', 11000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-27'::timestamptz),
    ('072826-002', 'iPhone 16 Pro Max', '1TB', 'Gold', 'iPhones', 49000.0::numeric, 'Pre-owned', 'Salazar', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-28'::timestamptz),
    ('072926-002', 'iPhone 15+', '128GB', 'Pink', 'iPhones', 30000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-29'::timestamptz),
    ('072926-003', 'iPhone 12 Pro Max', '128GB', 'Gold', 'iPhones', 18000.0::numeric, 'Pre-owned', 'Paul', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-29'::timestamptz),
    ('072926-004', 'iPhone 13 Pro Max', '128GB', 'Blue', 'iPhones', 21000.0::numeric, 'Pre-owned', 'Paul', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-29'::timestamptz),
    ('072926-005', 'iPad 10th Ge', '64GB', 'Pink', 'iPads', 12000.0::numeric, 'Pre-owned', 'Maam Neng', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-29'::timestamptz),
    ('073126-001', 'iPhone 13 Pro', '128GB', 'Blue', 'iPhones', 21000.0::numeric, 'Pre-owned', 'Walk-in', 'Available', 'Walk-in purchase — no resale price set yet. Update Selling Price via Edit Device once priced.', '2026-07-31'::timestamptz)
  ) as t(batch_code, device_name, storage, color, category, capital, condition, supplier_name, status, note, date_added)
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, notes, date_added)
    values (rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, rec.status, v_supplier_id, rec.capital, 0, rec.condition, rec.note, rec.date_added);
  end loop;
end $$;

-- ============================================================
-- Expenses (99 entries, category General)
-- ============================================================
insert into public.expenses (expense_date, description, amount, category) values
  ('2026-06-01', 'incentives', 300.0::numeric, 'General'),
  ('2026-06-03', 'outcash ira', 500.0::numeric, 'General'),
  ('2026-06-05', 'rent', 15000.0::numeric, 'General'),
  ('2026-06-05', 'gas', 4800.0::numeric, 'General'),
  ('2026-06-06', 'ira salary', 3600.0::numeric, 'General'),
  ('2026-06-06', 'brent', 1400.0::numeric, 'General'),
  ('2026-06-06', 'rai', 2200.0::numeric, 'General'),
  ('2026-06-08', 'cake', 578.0::numeric, 'General'),
  ('2026-06-08', 'incentives', 300.0::numeric, 'General'),
  ('2026-06-08', 'outcash ira', 500.0::numeric, 'General'),
  ('2026-06-09', 'diesel', 1300.0::numeric, 'General'),
  ('2026-06-09', 'parasat', 2000.0::numeric, 'General'),
  ('2026-06-15', 'lessandra', 1500.0::numeric, 'General'),
  ('2026-06-15', 'shoppee', 5764.0::numeric, 'General'),
  ('2026-06-15', 'savemore', 2122.0::numeric, 'General'),
  ('2026-06-15', 'ororama', 1880.0::numeric, 'General'),
  ('2026-06-15', 'Tiktok', 5271.0::numeric, 'General'),
  ('2026-06-12', 'rice ira', 1200.0::numeric, 'General'),
  ('2026-06-12', 'rr', 100.0::numeric, 'General'),
  ('2026-06-13', 'rai salary', 1800.0::numeric, 'General'),
  ('2026-06-13', 'ira salary', 4300.0::numeric, 'General'),
  ('2026-06-13', 'brent salary', 2400.0::numeric, 'General'),
  ('2026-06-15', 'rr cgn', 250.0::numeric, 'General'),
  ('2026-06-15', 'out cash ira', 500.0::numeric, 'General'),
  ('2026-06-15', 'bond paper', 250.0::numeric, 'General'),
  ('2026-06-17', 'diy', 176.0::numeric, 'General'),
  ('2026-06-17', 'medicine', 2015.0::numeric, 'General'),
  ('2026-06-17', 'ira salary', 3000.0::numeric, 'General'),
  ('2026-06-17', 'rai & brent', 4100.0::numeric, 'General'),
  ('2026-06-23', 'Maria reyna', 4500.0::numeric, 'General'),
  ('2026-06-23', 'Pldt', 1700.0::numeric, 'General'),
  ('2026-06-22', 'incentives', 300.0::numeric, 'General'),
  ('2026-06-22', 'ira outcash', 500.0::numeric, 'General'),
  ('2026-06-22', 'aircon cleaning', 1100.0::numeric, 'General'),
  ('2026-06-22', 'diy', 200.0::numeric, 'General'),
  ('2026-06-24', 'expenses', 600.0::numeric, 'General'),
  ('2026-06-25', 'incentives', 300.0::numeric, 'General'),
  ('2026-06-25', 'ira salary', 2900.0::numeric, 'General'),
  ('2026-06-26', 'expenses', 540.0::numeric, 'General'),
  ('2026-06-27', 'brent salary', 2100.0::numeric, 'General'),
  ('2026-06-27', 'rai salary', 2800.0::numeric, 'General'),
  ('2026-06-28', 'Diy', 400.0::numeric, 'General'),
  ('2026-06-28', 'pharmacy', 100.0::numeric, 'General'),
  ('2026-07-01', 'out cash ira', 500.0::numeric, 'General'),
  ('2026-07-03', 'rr bjs', 250.0::numeric, 'General'),
  ('2026-07-03', 'incent', 400.0::numeric, 'General'),
  ('2026-07-04', 'rent', 15000.0::numeric, 'General'),
  ('2026-07-04', 'incentives', 300.0::numeric, 'General'),
  ('2026-07-04', 'rai salary', 2000.0::numeric, 'General'),
  ('2026-07-04', 'ira salary', 2500.0::numeric, 'General'),
  ('2026-07-04', 'brent', 1925.0::numeric, 'General'),
  ('2026-07-04', 'paper bag', 100.0::numeric, 'General'),
  ('2026-07-07', 'parasat', 2000.0::numeric, 'General'),
  ('2026-07-07', 'inentives', 200.0::numeric, 'General'),
  ('2026-07-07', 'outcash', 500.0::numeric, 'General'),
  ('2026-07-07', 'rider fee', 250.0::numeric, 'General'),
  ('2026-07-08', 'df', 100.0::numeric, 'General'),
  ('2026-07-09', 'cake', 890.0::numeric, 'General'),
  ('2026-07-09', 'rider fee', 100.0::numeric, 'General'),
  ('2026-07-15', 'globe camella', 1500.0::numeric, 'General'),
  ('2026-07-15', 'shopee pay', 4360.0::numeric, 'General'),
  ('2026-07-15', 'tiktok pay later', 5041.0::numeric, 'General'),
  ('2026-07-15', 'manila exp', 10500.0::numeric, 'General'),
  ('2026-07-10', 'incentives', 300.0::numeric, 'General'),
  ('2026-07-10', 'salary rai', 2400.0::numeric, 'General'),
  ('2026-07-10', 'salary brent', 2100.0::numeric, 'General'),
  ('2026-07-10', 'salary ira', 3500.0::numeric, 'General'),
  ('2026-07-10', 'grab', 200.0::numeric, 'General'),
  ('2026-07-10', 'gelou', 400.0::numeric, 'General'),
  ('2026-07-13', 'outcash ira', 500.0::numeric, 'General'),
  ('2026-07-16', 'incentives', 300.0::numeric, 'General'),
  ('2026-07-16', 'shoppee bag', 1465.0::numeric, 'General'),
  ('2026-07-17', 'incentives', 300.0::numeric, 'General'),
  ('2026-07-17', 'diy brent', 1000.0::numeric, 'General'),
  ('2026-07-18', 'ira salary', 3000.0::numeric, 'General'),
  ('2026-07-18', 'brent salary', 2400.0::numeric, 'General'),
  ('2026-07-18', 'rai salary', 2400.0::numeric, 'General'),
  ('2026-07-19', 'diesel', 3000.0::numeric, 'General'),
  ('2026-07-19', 'gas', 1000.0::numeric, 'General'),
  ('2026-07-19', 'outcash ira', 500.0::numeric, 'General'),
  ('2026-07-19', 'jelou', 400.0::numeric, 'General'),
  ('2026-07-20', 'lessandra electric', 2790.0::numeric, 'General'),
  ('2026-07-21', 'snack', 225.0::numeric, 'General'),
  ('2026-07-21', 'everest shipping fee', 3000.0::numeric, 'General'),
  ('2026-07-21', 'Diesel hilux', 1000.0::numeric, 'General'),
  ('2026-07-23', 'shoppee rs', 150.0::numeric, 'General'),
  ('2026-07-23', 'incentives', 300.0::numeric, 'General'),
  ('2026-07-24', 'claveria expenses', 3000.0::numeric, 'General'),
  ('2026-07-24', 'incentives', 400.0::numeric, 'General'),
  ('2026-07-26', 'electric', 12200.0::numeric, 'General'),
  ('2026-07-26', 'Ira salary', 3000.0::numeric, 'General'),
  ('2026-07-27', 'ira out cash', 500.0::numeric, 'General'),
  ('2026-07-27', 'incentives', 300.0::numeric, 'General'),
  ('2026-07-27', 'pldt', 1700.0::numeric, 'General'),
  ('2026-07-28', 'watsons', 2300.0::numeric, 'General'),
  ('2026-07-29', 'medicine', 4200.0::numeric, 'General'),
  ('2026-07-29', 'lunch', 120.0::numeric, 'General'),
  ('2026-07-29', 'rr bjs', 200.0::numeric, 'General'),
  ('2026-07-29', 'rider fee', 200.0::numeric, 'General');

-- ============================================================
-- Cargo (12 entries, category Cargo)
-- ============================================================
insert into public.expenses (expense_date, description, amount, category) values
  ('2026-06-10', 'lhord', 2600.0::numeric, 'Cargo'),
  ('2026-06-10', 'rider', 500.0::numeric, 'Cargo'),
  ('2026-06-22', 'lhord', 4300.0::numeric, 'Cargo'),
  ('2026-06-22', 'rider', 500.0::numeric, 'Cargo'),
  ('2026-06-26', 'lhord', 1600.0::numeric, 'Cargo'),
  ('2026-06-26', 'rider', 500.0::numeric, 'Cargo'),
  ('2026-07-08', 'lord', 2050.0::numeric, 'Cargo'),
  ('2026-07-08', 'rider', 500.0::numeric, 'Cargo'),
  ('2026-07-19', 'lhord', 1600.0::numeric, 'Cargo'),
  ('2026-07-19', 'rider', 500.0::numeric, 'Cargo'),
  ('2026-07-22', 'lhord', 2800.0::numeric, 'Cargo'),
  ('2026-07-22', 'rider', 500.0::numeric, 'Cargo');

-- ============================================================
-- CGN's own resale to their customers (33 entries)
-- ============================================================
insert into public.cgn_resales (sale_date, device_name, capital, disposal_price, supplier_note) values
  ('2026-07-04', 'iPhone 11 128GB Purple', 11000.0::numeric, 12200.0::numeric, 'S 06.22'),
  ('2026-07-04', 'iPhone 11 128GB Purple', 11000.0::numeric, 12200.0::numeric, 'S 06.22'),
  ('2026-07-04', 'iPhone 11 128GB White', 11000.0::numeric, 12200.0::numeric, 'S 06.22'),
  ('2026-07-04', 'iPhone 11 128GB White', 11000.0::numeric, 12200.0::numeric, 'S 06.22'),
  ('2026-07-04', 'iPhone 11 128GB Black', 10700.0::numeric, 12200.0::numeric, 'L 06.10'),
  ('2026-07-06', 'iPhone 12 128GB Black', 12200.0::numeric, 14000.0::numeric, 'L 05.06'),
  ('2026-07-06', 'iPhone 12 128GB Black', 12200.0::numeric, 14000.0::numeric, 'L 05.06'),
  ('2026-07-06', 'iPhone 12 128GB Red', 12200.0::numeric, 14000.0::numeric, 'L 05.06'),
  ('2026-07-06', 'iPhone 13 128GB White', 16500.0::numeric, 18000.0::numeric, 'S 06.22'),
  ('2026-07-06', 'iPhone 13 128GB White', 16500.0::numeric, 18000.0::numeric, 'S 06.22'),
  ('2026-07-06', 'iPhone 13 128GB Pink', 16500.0::numeric, 18000.0::numeric, 'S 06.22'),
  ('2026-07-06', 'iPhone 13 256GB Pink', 17500.0::numeric, 19000.0::numeric, 'S 06.22'),
  ('2026-07-06', 'iPhone 13 256GB Pink', 17500.0::numeric, 19000.0::numeric, 'S 06.22'),
  ('2026-07-06', 'iPhone 13 256GB White', 17500.0::numeric, 19000.0::numeric, 'S 06.22'),
  ('2026-07-14', 'iPhone 13 256GB White', 17500.0::numeric, 19000.0::numeric, 'S 06.22'),
  ('2026-07-14', 'iPhone 13 256GB White', 17500.0::numeric, 19000.0::numeric, 'S 06.22'),
  ('2026-07-14', 'iPhone 13 256GB White', 17500.0::numeric, 19000.0::numeric, 'S 06.22'),
  ('2026-07-14', 'iPhone 13 256GB Pink', 17500.0::numeric, 19000.0::numeric, 'S 06.22'),
  ('2026-07-14', 'iPhone 13 256GB Pink', 17500.0::numeric, 19000.0::numeric, 'S 06.22'),
  ('2026-07-20', 'MacBook Neo 256GB Silver (Brand New)', 37300.0::numeric, 42000.0::numeric, 'bgc '),
  ('2026-07-23', 'iPhone 11 128GB White', 10700.0::numeric, 12200.0::numeric, 'L 06.10'),
  ('2026-07-23', 'iPhone 11 128GB White', 10700.0::numeric, 12200.0::numeric, 'L 06.10'),
  ('2026-07-23', 'iPhone 11 128GB Black', 10700.0::numeric, 12200.0::numeric, 'L 06.10'),
  ('2026-07-23', 'iPhone 11 128GB Black', 10700.0::numeric, 12200.0::numeric, 'L 06.10'),
  ('2026-07-23', 'iPhone 11 128GB Mint', 10700.0::numeric, 12200.0::numeric, 'L 06.10'),
  ('2026-07-23', 'iPhone 12 128GB White', 12200.0::numeric, 14000.0::numeric, 'L 05.06'),
  ('2026-07-23', 'iPhone 12 128GB White', 12200.0::numeric, 14000.0::numeric, 'L 05.06'),
  ('2026-07-23', 'iPhone 12 128GB Purple', 12200.0::numeric, 14000.0::numeric, 'L 05.06'),
  ('2026-07-24', 'iPhone XR 128GB White', 9000.0::numeric, 10000.0::numeric, 'A 12.08'),
  ('2026-07-24', 'iPhone XR 128GB Blue', 9000.0::numeric, 10000.0::numeric, 'A 12.08'),
  ('2026-07-24', 'iPhone XR 128GB Black', 9000.0::numeric, 10000.0::numeric, 'A 12.08'),
  ('2026-07-24', 'iPhone XR 128GB Coral', 9000.0::numeric, 10000.0::numeric, 'A 12.08'),
  ('2026-07-24', 'iPhone XR 128GB White', 8500.0::numeric, 10000.0::numeric, 'L 04.19');
