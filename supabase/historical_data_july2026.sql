-- Fresh reload for July 2026 — for use after truncating the database (test
-- units cleared out). Same source data as before (the "july" sheet of the
-- source Excel workbook), rebuilt so device_name/storage/color are
-- properly split into their own columns instead of storage/color being
-- crammed into the device_name title.
--
-- Everything confirmed in earlier rounds carries over:
--   • Samsung S22 (no Capital/Disposal in the sheet, only Net Profit
--     ₱2,000): bought for ₱10,000 cash, sold for ₱12,000.
--   • "Add on" table (26 items, price only): walk-in purchases from people
--     selling their phones in-store — entered as unsold inventory (status
--     Available), that price as Capital, Selling Price 0 (not yet
--     computed), flagged in Notes.
--   • The whole undated block under 07.18.26 — the "Mona"-tagged row, every
--     numbered batch after it, and the two "RS" rows — is one single-day
--     Bulk sale to Mona. "RS" is a dealer grading code for resealed
--     iPhones, not a supplier. Rows 89-98 are a separate bulk buyer, ND —
--     still owing ₱30,000 of ₱180,000 (₱150,000 paid via BPI), unsettled.
--   • Cargo: one date typo (07.22.23 → 07.22.26) corrected. The duplicate
--     7th Cargo row (₱7,950, no date/description — the total of the other
--     6) is excluded.
--   • 5 of the 26 Add-on units were confirmed (matching model + purchase
--     price, Add-on date before the Main sale date) to have been resold
--     later that same month under a separate Main Sales batch code — those
--     5 go in as status Sold (not Available), with a note pointing at the
--     batch code holding the actual sale, instead of a second sale record
--     that would double-count the revenue:
--       070326-007 (iPhone 13 Pro 256GB Gold)      -> resold as 071126-004
--       071226-002 (iPhone 16 256GB Teal)          -> resold as 072126-001
--       071426-003 (iPhone 13 Pro Max 128GB Gold)  -> resold as 071726-003
--       071626-005 (iPad 10th Gen 256GB Blue)      -> resold as 072226-002
--         (also fixes a data-entry typo: this unit's capital is 13500, not
--         13000 as originally entered)
--       073026-003 (iPad 11th Gen 128GB Silver)    -> resold as 073026-001
--
-- New in this split-fields pass:
--   • A handful of entries had no storage size in the source at all (iPad
--     11th Gen Silver/Blue x2, row 14/20/21) — storage stays null rather
--     than guessed.
--   • "iPad Air M3 128GB 13 Inch" — "13 Inch" is the screen-size variant,
--     not a color; moved to a note, color left null.
--   • "iPad 10th Gen 256GB Pink Wifi + Cel" — "Wifi + Cel" is the
--     connectivity variant, not part of the color; moved to a note, color
--     is just Pink.
--   • "Deep P" (iPhone 14 Pro Max) expanded to "Deep Purple" — the only
--     Apple color for that model starting with those letters.
--
-- Run this once in the Supabase SQL Editor, after truncating, and after the
-- catalog-management and expense-category-cargo/prulife/personal
-- migrations.

-- ============================================================
-- Suppliers referenced by this report that may not exist yet
-- ============================================================
insert into public.suppliers (name) values
  ('Abraham'),
  ('Aminor'),
  ('BGC'),
  ('Chikita'),
  ('Dara'),
  ('Fr. Bagtong'),
  ('Joey'),
  ('Kathy'),
  ('Lilah'),
  ('Maam Neng'),
  ('Masiba'),
  ('ND'),
  ('Neil'),
  ('Pabz'),
  ('Paul'),
  ('Salazar'),
  ('Sohayma'),
  ('Tina'),
  ('Walk-in')
on conflict (name) do nothing;

-- ============================================================
-- Main sales (119 units) — devices + sales + sale_items
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
begin
  for rec in
    select * from (values
      (1, '070226-001', '2026-07-02'::date, 'iPhone 16 Pro Max', '256GB', 'Black', 'iPhones', 31000::numeric, 51000::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (2, '070226-002', '2026-07-02'::date, 'Samsung S22', null, null, 'Accessories', 10000::numeric, 12000::numeric, 'Neil', 'Pre-owned', null, 'Regular', 'Paid', 'Non-Apple device (Samsung) — filed under Accessories since the catalog has no Android category.'),
      (3, '070226-003', '2026-07-02'::date, 'iPhone 11', '128GB', 'White', 'iPhones', 10500::numeric, 12500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (4, '070226-004', '2026-07-02'::date, 'iPhone 13', '256GB', 'Black', 'iPhones', 17500::numeric, 20500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (5, '070226-005', '2026-07-02'::date, 'iPhone 15 Pro', '128GB', 'Natural', 'iPhones', 23800::numeric, 32000::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (6, '070326-001', '2026-07-03'::date, 'iPhone 11', '128GB', 'White', 'iPhones', 11000::numeric, 12000::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (7, '070326-002', '2026-07-03'::date, 'iPhone 11', '128GB', 'Purple', 'iPhones', 11000::numeric, 12000::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (8, '070326-003', '2026-07-03'::date, 'MacBook Neo', '256GB', 'Blue', 'MacBooks', 30000::numeric, 41500::numeric, null, 'Pre-owned', null, 'Regular', 'Paid', 'Unrecognized supplier text: "walk 06.30"'),
      (9, '070326-004', '2026-07-03'::date, 'iPhone SE', '128GB', 'Black', 'iPhones', 6000::numeric, 8500::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (10, '070326-005', '2026-07-03'::date, 'iPhone 14', '128GB', 'Black', 'iPhones', 20500::numeric, 22500::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (11, '070426-001', '2026-07-04'::date, 'iPhone 11', '128GB', 'White', 'iPhones', 11000::numeric, 12500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (12, '070426-002', '2026-07-04'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 23500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (13, '070526-001', '2026-07-05'::date, 'iPhone 15', '128GB', 'Black', 'iPhones', 25000::numeric, 32500::numeric, 'Pabz', 'Pre-owned', null, 'Regular', 'Paid', null),
      (14, '070526-002', '2026-07-05'::date, 'iPad 11th Gen', null, 'Silver', 'iPads', 21500::numeric, 28000::numeric, 'Sohayma', 'Brand New', null, 'Regular', 'Paid', null),
      (15, '070526-003', '2026-07-05'::date, 'iPhone 13 Pro Max', '128GB', 'Gold', 'iPhones', 22000::numeric, 27000::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (16, '070626-001', '2026-07-06'::date, 'iPad 9th Gen', '256GB', 'Black', 'iPads', 10300::numeric, 12500::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null),
      (17, '070626-002', '2026-07-06'::date, 'iPad 9th Gen', '256GB', 'Black', 'iPads', 10300::numeric, 12300::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null),
      (18, '070726-001', '2026-07-07'::date, 'iPhone 11', '128GB', 'White', 'iPhones', 11000::numeric, 12700::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (19, '070826-001', '2026-07-08'::date, 'iPhone 11', '128GB', 'Mint', 'iPhones', 11000::numeric, 12700::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (20, '070826-002', '2026-07-08'::date, 'iPad 11th Gen', null, 'Blue', 'iPads', 21500::numeric, 25500::numeric, 'Sohayma', 'Brand New', null, 'Regular', 'Paid', null),
      (21, '070826-003', '2026-07-08'::date, 'iPad 11th Gen', null, 'Blue', 'iPads', 21500::numeric, 25500::numeric, 'Sohayma', 'Brand New', null, 'Regular', 'Paid', null),
      (22, '070826-004', '2026-07-08'::date, 'iPad 9th Gen', '256GB', 'Black', 'iPads', 10300::numeric, 12300::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null),
      (23, '070826-005', '2026-07-08'::date, 'iPhone 13', '128GB', 'Pink', 'iPhones', 16500::numeric, 22500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (24, '070826-006', '2026-07-08'::date, 'iPhone 17 Pro Max', '256GB', 'Cosmic', 'iPhones', 78000::numeric, 84500::numeric, 'BGC', 'Brand New', null, 'Regular', 'Paid', null),
      (25, '070926-001', '2026-07-09'::date, 'iPad 11th Gen', '128GB', 'Blue', 'iPads', 21500::numeric, 25500::numeric, 'Sohayma', 'Brand New', null, 'Regular', 'Paid', null),
      (26, '071026-001', '2026-07-10'::date, 'iPhone 16', '128GB', 'White', 'iPhones', 30000::numeric, 38000::numeric, 'Abraham', 'Pre-owned', null, 'Regular', 'Paid', null),
      (27, '071126-001', '2026-07-11'::date, 'iPhone 16 Pro Max', '256GB', 'Dessert', 'iPhones', 40500::numeric, 57000::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (28, '071126-002', '2026-07-11'::date, 'iPad Air M3', '128GB', null, 'iPads', 25500::numeric, 35500::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', '13-inch variant'),
      (29, '071126-003', '2026-07-11'::date, 'iPhone 17 Pro Max', '256GB', 'Blue', 'iPhones', 78500::numeric, 88500::numeric, 'Pabz', 'Brand New', null, 'Regular', 'Paid', null),
      (30, '071126-004', '2026-07-11'::date, 'iPhone 13 Pro', '256GB', 'Gold', 'iPhones', 22000::numeric, 26000::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (31, '071226-001', '2026-07-12'::date, 'iPhone 15 Pro Max', '256GB', 'Natural', 'iPhones', 39000::numeric, 48500::numeric, 'Chikita', 'Pre-owned', null, 'Regular', 'Paid', null),
      (32, '071326-001', '2026-07-13'::date, 'iPhone 11', '128GB', 'Black', 'iPhones', 10700::numeric, 12500::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null),
      (33, '071426-001', '2026-07-14'::date, 'iPhone 14', '128GB', 'White', 'iPhones', 28300::numeric, 31500::numeric, 'BGC', 'Brand New', null, 'Regular', 'Paid', null),
      (34, '071426-002', '2026-07-14'::date, 'iPad 11th Gen', '128GB', 'Pink', 'iPads', 24000::numeric, 26500::numeric, 'Sohayma', 'Brand New', null, 'Regular', 'Paid', null),
      (35, '071626-001', '2026-07-16'::date, 'iPad 11th Gen', '128GB', 'Blue', 'iPads', 21500::numeric, 25500::numeric, 'Sohayma', 'Brand New', null, 'Regular', 'Paid', null),
      (36, '071626-002', '2026-07-16'::date, 'iPhone XR', '128GB', 'Black', 'iPhones', 9000::numeric, 10500::numeric, 'Aminor', 'Pre-owned', null, 'Regular', 'Paid', null),
      (37, '071626-003', '2026-07-16'::date, 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 24000::numeric, 26500::numeric, 'Sohayma', 'Brand New', null, 'Regular', 'Paid', null),
      (38, '071626-004', '2026-07-16'::date, 'iPhone 16 Pro Max', '256GB', 'Dessert', 'iPhones', 45500::numeric, 57000::numeric, 'Kathy', 'Pre-owned', null, 'Regular', 'Paid', null),
      (39, '071726-001', '2026-07-17'::date, 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500::numeric, 20500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (40, '071726-002', '2026-07-17'::date, 'iPhone 11', '128GB', 'Mint', 'iPhones', 10700::numeric, 16500::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null),
      (41, '071726-003', '2026-07-17'::date, 'iPhone 13 Pro Max', '128GB', 'Gold', 'iPhones', 22500::numeric, 27000::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (42, '071826-001', '2026-07-18'::date, 'iPhone 13', '256GB', 'Black', 'iPhones', 17500::numeric, 20500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (43, '071826-002', '2026-07-18'::date, 'iPhone 13 Pro', '128GB', 'Black', 'iPhones', 22800::numeric, 23000::numeric, 'Aminor', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (44, '071826-003', '2026-07-18'::date, 'iPhone 13 Pro', '128GB', 'Gold', 'iPhones', 19000::numeric, 23000::numeric, 'Joey', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (45, '071826-004', '2026-07-18'::date, 'iPhone 13 Pro', '256GB', 'White', 'iPhones', 22000::numeric, 25000::numeric, 'Walk-in', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (46, '071826-005', '2026-07-18'::date, 'iPhone 13', '128GB', 'White', 'iPhones', 16000::numeric, 17500::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (47, '071826-006', '2026-07-18'::date, 'iPhone 13', '128GB', 'White', 'iPhones', 16000::numeric, 17500::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (48, '071826-007', '2026-07-18'::date, 'iPhone 13', '128GB', 'White', 'iPhones', 16000::numeric, 17500::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (49, '071826-008', '2026-07-18'::date, 'iPhone 13', '128GB', 'White', 'iPhones', 16000::numeric, 17500::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (50, '071826-009', '2026-07-18'::date, 'iPhone 13', '128GB', 'Black', 'iPhones', 16000::numeric, 17500::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (51, '071826-010', '2026-07-18'::date, 'iPhone 13', '128GB', 'Black', 'iPhones', 16000::numeric, 17500::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (52, '071826-011', '2026-07-18'::date, 'iPhone 13', '128GB', 'Black', 'iPhones', 16500::numeric, 17500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (53, '071826-012', '2026-07-18'::date, 'iPhone 13', '128GB', 'Green', 'iPhones', 18600::numeric, 17500::numeric, null, 'Pre-owned', 'Mona', 'Bulk', 'Paid', 'Trade-in note (from Supplier column): swap 12pm 12.17'),
      (54, '071826-013', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (55, '071826-014', '2026-07-18'::date, 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (56, '071826-015', '2026-07-18'::date, 'iPhone 11', '128GB', 'Black', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (57, '071826-016', '2026-07-18'::date, 'iPhone 11', '128GB', 'Black', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (58, '071826-017', '2026-07-18'::date, 'iPhone 11', '128GB', 'Black', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (59, '071826-018', '2026-07-18'::date, 'iPhone 11', '128GB', 'Black', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (60, '071826-019', '2026-07-18'::date, 'iPhone 11', '128GB', 'Black', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (61, '071826-020', '2026-07-18'::date, 'iPhone 11', '128GB', 'White', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (62, '071826-021', '2026-07-18'::date, 'iPhone 11', '128GB', 'White', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (63, '071826-022', '2026-07-18'::date, 'iPhone 11', '128GB', 'White', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (64, '071826-023', '2026-07-18'::date, 'iPhone 11', '128GB', 'Mint', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (65, '071826-024', '2026-07-18'::date, 'iPhone 11', '128GB', 'Mint', 'iPhones', 10700::numeric, 11800::numeric, 'Lilah', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (66, '071826-025', '2026-07-18'::date, 'iPhone 13', '256GB', 'Black', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (67, '071826-026', '2026-07-18'::date, 'iPhone 13', '256GB', 'Black', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (68, '071826-027', '2026-07-18'::date, 'iPhone 13', '256GB', 'Black', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (69, '071826-028', '2026-07-18'::date, 'iPhone 13', '256GB', 'Black', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (70, '071826-029', '2026-07-18'::date, 'iPhone 13', '256GB', 'Black', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (71, '071826-030', '2026-07-18'::date, 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (72, '071826-031', '2026-07-18'::date, 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (73, '071826-032', '2026-07-18'::date, 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (74, '071826-033', '2026-07-18'::date, 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (75, '071826-034', '2026-07-18'::date, 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (76, '071826-035', '2026-07-18'::date, 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (77, '071826-036', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (78, '071826-037', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (79, '071826-038', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (80, '071826-039', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (81, '071826-040', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (82, '071826-041', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (83, '071826-042', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (84, '071826-043', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (85, '071826-044', '2026-07-18'::date, 'iPhone 13', '256GB', 'White', 'iPhones', 17500::numeric, 18500::numeric, 'Sohayma', 'Pre-owned', 'Mona', 'Bulk', 'Paid', null),
      (86, '071826-045', '2026-07-18'::date, 'RS iPhone 16', '128GB', 'Pink', 'iPhones', 39000::numeric, 42500::numeric, null, 'Pre-owned', 'Mona', 'Bulk', 'Paid', 'Original ledger notation in Supplier column: "rs nd" RS = resealed iPhone (dealer grading code), not a supplier.'),
      (87, '071826-046', '2026-07-18'::date, 'RS iPhone 16', '128GB', 'Black', 'iPhones', 39000::numeric, 42500::numeric, null, 'Pre-owned', 'Mona', 'Bulk', 'Paid', 'Original ledger notation in Supplier column: "rs nd" RS = resealed iPhone (dealer grading code), not a supplier.'),
      (88, '071826-047', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (89, '071826-048', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (90, '071826-049', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (91, '071826-050', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (92, '071826-051', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (93, '071826-052', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (94, '071826-053', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (95, '071826-054', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (96, '071826-055', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (97, '071826-056', '2026-07-18'::date, 'iPhone 13', '128GB', null, 'iPhones', 16000::numeric, 18000::numeric, 'Lilah', 'Pre-owned', 'ND', 'Bulk', 'Pending', 'Bulk order — ₱150,000 paid via BPI, ₱30,000 balance still owed per ledger.'),
      (98, '071926-001', '2026-07-19'::date, 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 24000::numeric, 27500::numeric, 'Sohayma', 'Brand New', null, 'Regular', 'Paid', null),
      (99, '072026-001', '2026-07-20'::date, 'iPhone 13', '128GB', 'White', 'iPhones', 16500::numeric, 22000::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (100, '072126-001', '2026-07-21'::date, 'iPhone 16', '256GB', 'Teal', 'iPhones', 31500::numeric, 38500::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (101, '072126-002', '2026-07-21'::date, 'iPad 10th Gen', '256GB', 'Pink', 'iPads', 25000::numeric, 30000::numeric, 'ND', 'Brand New', null, 'Regular', 'Paid', 'Wi-Fi + Cellular variant'),
      (102, '072226-001', '2026-07-22'::date, 'iPhone XR', '128GB', 'Black', 'iPhones', 8500::numeric, 13000::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null),
      (103, '072226-002', '2026-07-22'::date, 'iPad 10th Gen', '256GB', 'Blue', 'iPads', 13500::numeric, 20000::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (104, '072226-003', '2026-07-22'::date, 'iPhone 13', '128GB', 'White', 'iPhones', 16500::numeric, 22500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (105, '072326-001', '2026-07-23'::date, 'iPad 10th Gen', '64GB', 'Silver', 'iPads', 14000::numeric, 16000::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null),
      (106, '072326-002', '2026-07-23'::date, 'iPhone 13', '256GB', 'Pink', 'iPhones', 17500::numeric, 20500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (107, '072426-001', '2026-07-24'::date, 'iPhone 16 Pro Max', '256GB', 'Dessert', 'iPhones', 50000::numeric, 59500::numeric, 'Tina', 'Pre-owned', null, 'Regular', 'Paid', null),
      (108, '072426-002', '2026-07-24'::date, 'iPhone 11', '128GB', 'White', 'iPhones', 11000::numeric, 12500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (109, '072426-003', '2026-07-24'::date, 'iPhone 14 Pro Max', '128GB', 'Black', 'iPhones', 30000::numeric, 36500::numeric, 'Fr. Bagtong', 'Pre-owned', null, 'Regular', 'Paid', null),
      (110, '072526-001', '2026-07-25'::date, 'MacBook Neo', '256GB', 'Pink', 'MacBooks', 30000::numeric, 40000::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (111, '072626-001', '2026-07-26'::date, 'iPhone XR', '128GB', 'White', 'iPhones', 8500::numeric, 10500::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null),
      (112, '072726-001', '2026-07-27'::date, 'iPhone 11', '128GB', 'Black', 'iPhones', 11000::numeric, 12500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (113, '072726-002', '2026-07-27'::date, 'iPhone 11', '128GB', 'Purple', 'iPhones', 11000::numeric, 12500::numeric, 'Sohayma', 'Pre-owned', null, 'Regular', 'Paid', null),
      (114, '072726-003', '2026-07-27'::date, 'iPad Air M1', '64GB', 'Silver', 'iPads', 21000::numeric, 23000::numeric, 'Dara', 'Pre-owned', null, 'Regular', 'Paid', null),
      (115, '072826-001', '2026-07-28'::date, 'iPhone 11 Pro', '256GB', 'Black', 'iPhones', 13200::numeric, 15000::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null),
      (116, '072826-002', '2026-07-28'::date, 'MacBook Pro', '512GB', 'Silver', 'MacBooks', 32000::numeric, 40500::numeric, 'Masiba', 'Pre-owned', null, 'Regular', 'Paid', null),
      (117, '072926-001', '2026-07-29'::date, 'MacBook Air M3', '256GB', 'Grey', 'MacBooks', 40000::numeric, 55500::numeric, 'Neil', 'Pre-owned', null, 'Regular', 'Paid', null),
      (118, '073026-001', '2026-07-30'::date, 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 20000::numeric, 27500::numeric, 'Walk-in', 'Pre-owned', null, 'Regular', 'Paid', null),
      (119, '073026-002', '2026-07-30'::date, 'iPad 9th Gen', '256GB', 'Silver', 'iPads', 10300::numeric, 12500::numeric, 'Lilah', 'Pre-owned', null, 'Regular', 'Paid', null)
    ) as t(rownum, batch_code, sale_date, device_name, storage, color, category, capital, disposal, supplier_name, condition, customer_name, order_type, payment_status, note)
    order by rownum
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (
      batch_code, device_name, category, storage, color, status,
      supplier_id, purchase_price, selling_price, condition, notes, date_added
    ) values (
      rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, 'Sold',
      v_supplier_id, rec.capital, rec.disposal, rec.condition, rec.note,
      rec.sale_date::timestamptz
    )
    returning id into v_device_id;

    insert into public.sales (
      customer_name, salesperson_id, payment_method, reference_number,
      notes, total_amount, status, order_type, payment_status, sold_at
    ) values (
      rec.customer_name, null, 'Cash', 'N/A',
      rec.note, rec.disposal, 'Completed', rec.order_type, rec.payment_status, rec.sale_date::timestamptz
    )
    returning id into v_sale_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- Add-on purchases (26 units) — walk-in acquisitions. 21 are still unsold
-- inventory (status Available, Selling Price 0, not yet priced). 5 were
-- confirmed resold later that same month under a separate Main Sales batch
-- code (see header) — those go in as status Sold with a note pointing at
-- the batch code holding the real sale, so they don't sit in Available
-- stock as phantom inventory, and don't get a second sale record that
-- would double-count the revenue.
-- ============================================================
do $$
declare
  rec record;
  v_supplier_id uuid;
begin
  for rec in
    select * from (values
      (1, '070226-006', '2026-07-02'::date, 'iPhone 16 Pro Max', '256GB', 'Gold', 'iPhones', 40000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (2, '070326-006', '2026-07-03'::date, 'iPhone 11 Pro', '256GB', 'Gold', 'iPhones', 4000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (3, '070326-007', '2026-07-03'::date, 'iPhone 13 Pro', '256GB', 'Gold', 'iPhones', 22000::numeric, 'Walk-in', 'Pre-owned', 'Sold', 'Resold under a different batch code the same month — see that batch code for the actual sale record. This entry stays for the original purchase-in trail only.'),
      (4, '070926-002', '2026-07-09'::date, 'iPhone 16 Pro Max', '256GB', 'Gold', 'iPhones', 50000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (5, '070926-003', '2026-07-09'::date, 'iPhone 16', '128GB', 'Silver', 'iPhones', 30000::numeric, 'Abraham', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (6, '071026-002', '2026-07-10'::date, 'iPhone 17 Pro', '256GB', 'Silver', 'iPhones', 48000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (7, '071026-003', '2026-07-10'::date, 'iPad Air M3', '128GB', 'Grey', 'iPads', 25000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (8, '071126-005', '2026-07-11'::date, 'RS iPhone 16', '128GB', 'Silver', 'iPhones', 36000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (9, '071226-002', '2026-07-12'::date, 'iPhone 16', '256GB', 'Teal', 'iPhones', 31500::numeric, 'Walk-in', 'Pre-owned', 'Sold', 'Resold under a different batch code the same month — see that batch code for the actual sale record. This entry stays for the original purchase-in trail only.'),
      (10, '071426-003', '2026-07-14'::date, 'iPhone 13 Pro Max', '128GB', 'Gold', 'iPhones', 22500::numeric, 'Walk-in', 'Pre-owned', 'Sold', 'Resold under a different batch code the same month — see that batch code for the actual sale record. This entry stays for the original purchase-in trail only.'),
      (11, '071626-005', '2026-07-16'::date, 'iPad 10th Gen', '256GB', 'Blue', 'iPads', 13500::numeric, 'Walk-in', 'Pre-owned', 'Sold', 'Resold under a different batch code the same month — see that batch code for the actual sale record. This entry stays for the original purchase-in trail only.'),
      (12, '071626-006', '2026-07-16'::date, 'MacBook Neo', '256GB', 'Pink', 'MacBooks', 30000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (13, '072126-003', '2026-07-21'::date, 'iPhone 12', '128GB', 'White', 'iPhones', 12000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (14, '072126-004', '2026-07-21'::date, 'iPhone 17 Pro Max', '256GB', 'Blue', 'iPhones', 70500::numeric, 'Walk-in', 'Brand New', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (15, '072326-003', '2026-07-23'::date, 'iPhone 13 Pro', '128GB', 'Gold', 'iPhones', 22000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (16, '072326-004', '2026-07-23'::date, 'iPhone 13 Pro', '256GB', 'Silver', 'iPhones', 22000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (17, '072426-004', '2026-07-24'::date, 'iPhone 14 Pro Max', '128GB', 'Deep Purple', 'iPhones', 26000::numeric, 'Neil', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (18, '072426-005', '2026-07-24'::date, 'iPhone 14 Pro Max', '256GB', 'Deep Purple', 'iPhones', 27000::numeric, 'Neil', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (19, '072726-004', '2026-07-27'::date, 'iPhone 13 Pro Max', '256GB', 'Gold', 'iPhones', 23000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (20, '072726-005', '2026-07-27'::date, 'iPhone 14', '128GB', 'Black', 'iPhones', 11000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (21, '072826-003', '2026-07-28'::date, 'iPhone 16 Pro Max', '1TB', 'Gold', 'iPhones', 49000::numeric, 'Salazar', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (22, '072926-002', '2026-07-29'::date, 'iPhone 15 Plus', '128GB', 'Pink', 'iPhones', 30000::numeric, 'Walk-in', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (23, '072926-003', '2026-07-29'::date, 'iPhone 12 Pro Max', '128GB', 'Gold', 'iPhones', 18000::numeric, 'Paul', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (24, '072926-004', '2026-07-29'::date, 'iPhone 13 Pro Max', '128GB', 'Blue', 'iPhones', 21000::numeric, 'Paul', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (25, '072926-005', '2026-07-29'::date, 'iPad 10th Gen', '64GB', 'Pink', 'iPads', 12000::numeric, 'Maam Neng', 'Pre-owned', 'Available', 'Walk-in purchase from the July 2026 "Add on" ledger — no resale price set yet. Update Selling Price via Edit Device once priced.'),
      (26, '073026-003', '2026-07-30'::date, 'iPad 11th Gen', '128GB', 'Silver', 'iPads', 20000::numeric, 'Walk-in', 'Pre-owned', 'Sold', 'Resold under a different batch code the same month — see that batch code for the actual sale record. This entry stays for the original purchase-in trail only.')
    ) as t(rownum, batch_code, date_added, device_name, storage, color, category, price, supplier_name, condition, status, note)
    order by rownum
  loop
    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (
      batch_code, device_name, category, storage, color, status,
      supplier_id, purchase_price, selling_price, condition, notes, date_added
    ) values (
      rec.batch_code, rec.device_name, rec.category, rec.storage, rec.color, rec.status,
      v_supplier_id, rec.price, 0, rec.condition, rec.note,
      rec.date_added::timestamptz
    );
  end loop;
end $$;

-- ============================================================
-- Expenses (56 entries, category General)
-- ============================================================
insert into public.expenses (expense_date, description, amount, category) values
  ('2026-07-01', 'out cash ira', 500, 'General'),
  ('2026-07-03', 'rr bjs', 250, 'General'),
  ('2026-07-03', 'incent', 400, 'General'),
  ('2026-07-04', 'rent', 15000, 'General'),
  ('2026-07-04', 'incentives', 300, 'General'),
  ('2026-07-04', 'rai salary', 2000, 'General'),
  ('2026-07-04', 'ira salary', 2500, 'General'),
  ('2026-07-04', 'brent', 1925, 'General'),
  ('2026-07-04', 'paper bag', 100, 'General'),
  ('2026-07-07', 'parasat', 2000, 'General'),
  ('2026-07-07', 'inentives', 200, 'General'),
  ('2026-07-07', 'outcash', 500, 'General'),
  ('2026-07-07', 'rider fee', 250, 'General'),
  ('2026-07-08', 'df', 100, 'General'),
  ('2026-07-09', 'cake', 890, 'General'),
  ('2026-07-09', 'rider fee', 100, 'General'),
  ('2026-07-15', 'globe camella', 1500, 'General'),
  ('2026-07-15', 'shopee pay', 4360, 'General'),
  ('2026-07-15', 'tiktok pay later', 5041, 'General'),
  ('2026-07-15', 'manila exp', 10500, 'General'),
  ('2026-07-10', 'incentives', 300, 'General'),
  ('2026-07-10', 'salary rai', 2400, 'General'),
  ('2026-07-10', 'salary brent', 2100, 'General'),
  ('2026-07-10', 'salary ira', 3500, 'General'),
  ('2026-07-10', 'grab', 200, 'General'),
  ('2026-07-10', 'gelou', 400, 'General'),
  ('2026-07-13', 'outcash ira', 500, 'General'),
  ('2026-07-16', 'incentives', 300, 'General'),
  ('2026-07-16', 'shoppee bag', 1465, 'General'),
  ('2026-07-17', 'incentives', 300, 'General'),
  ('2026-07-17', 'diy brent', 1000, 'General'),
  ('2026-07-18', 'ira salary', 3000, 'General'),
  ('2026-07-18', 'brent salary', 2400, 'General'),
  ('2026-07-18', 'rai salary', 2400, 'General'),
  ('2026-07-19', 'diesel', 3000, 'General'),
  ('2026-07-19', 'gas', 1000, 'General'),
  ('2026-07-19', 'outcash ira', 500, 'General'),
  ('2026-07-19', 'jelou', 400, 'General'),
  ('2026-07-20', 'lessandra electric', 2790, 'General'),
  ('2026-07-21', 'snack', 225, 'General'),
  ('2026-07-21', 'everest shipping fee', 3000, 'General'),
  ('2026-07-21', 'Diesel hilux', 1000, 'General'),
  ('2026-07-23', 'shoppee rs', 150, 'General'),
  ('2026-07-23', 'incentives', 300, 'General'),
  ('2026-07-24', 'claveria expenses', 3000, 'General'),
  ('2026-07-24', 'incentives', 400, 'General'),
  ('2026-07-26', 'electric (for the month of April & May)', 12200, 'General'),
  ('2026-07-26', 'Ira salary', 3000, 'General'),
  ('2026-07-27', 'ira out cash', 500, 'General'),
  ('2026-07-27', 'incentives', 300, 'General'),
  ('2026-07-27', 'pldt', 1700, 'General'),
  ('2026-07-28', 'watsons', 2300, 'General'),
  ('2026-07-29', 'medicine', 4200, 'General'),
  ('2026-07-29', 'lunch', 120, 'General'),
  ('2026-07-29', 'rr bjs', 200, 'General'),
  ('2026-07-29', 'rider fee', 200, 'General');

-- ============================================================
-- Cargo (6 entries, category Cargo)
-- ============================================================
insert into public.expenses (expense_date, description, amount, category) values
  ('2026-07-08', 'lord', 2050, 'Cargo'),
  ('2026-07-08', 'rider', 500, 'Cargo'),
  ('2026-07-19', 'lhord', 1600, 'Cargo'),
  ('2026-07-19', 'rider', 500, 'Cargo'),
  ('2026-07-22', 'lhord', 2800, 'Cargo'),
  ('2026-07-22', 'rider', 500, 'Cargo');
