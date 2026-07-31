-- CGN's own resale report for July 2026 — parsed from the PDF the admin
-- provided ("MARK GADGETS CAMIGUIN STOCKS - July.pdf"). This is what CGN
-- (the admin's other branch) resold each unit for to their own customers,
-- separate from what we sold it to them for (that's the main CGN Ledger,
-- covered by historical_data_july2026.sql's Mona/ND-style customer tags —
-- CGN's own sales weren't part of that file).
--
-- The Skyro remittance column on the right side of the source report was
-- explicitly excluded per instruction — it's a separate financing summary,
-- not part of this unit-by-unit resale ledger.
--
-- Independently verified: every one of the 9 date/batch subtotals in the
-- source reconciles exactly to the report's own grand total —
-- Capital ₱452,700 / Resold For ₱504,000 / Profit ₱51,300 ("net profit",
-- highlighted in the source).
--
-- Run this once in the Supabase SQL Editor, after 20260801120000_add_cgn_resales.sql.

insert into public.cgn_resales (sale_date, device_name, capital, disposal_price, supplier_note) values
  ('2026-07-04', 'iPhone 11 128GB Purple', 11000, 12200, 'S 06.22'),
  ('2026-07-04', 'iPhone 11 128GB Purple', 11000, 12200, 'S 06.22'),
  ('2026-07-04', 'iPhone 11 128GB White', 11000, 12200, 'S 06.22'),
  ('2026-07-04', 'iPhone 11 128GB White', 11000, 12200, 'S 06.22'),
  ('2026-07-04', 'iPhone 11 128GB Black', 10700, 12200, 'L 06.10'),

  ('2026-07-06', 'iPhone 12 128GB Black', 12200, 14000, 'L 05.06'),
  ('2026-07-06', 'iPhone 12 128GB Black', 12200, 14000, 'L 05.06'),
  ('2026-07-06', 'iPhone 12 128GB Red', 12200, 14000, 'L 05.06'),

  ('2026-07-06', 'iPhone 13 128GB White', 16500, 18000, 'S 06.22'),
  ('2026-07-06', 'iPhone 13 128GB White', 16500, 18000, 'S 06.22'),
  ('2026-07-06', 'iPhone 13 128GB Pink', 16500, 18000, 'S 06.22'),

  ('2026-07-06', 'iPhone 13 256GB Pink', 17500, 19000, 'S 06.22'),
  ('2026-07-06', 'iPhone 13 256GB Pink', 17500, 19000, 'S 06.22'),
  ('2026-07-06', 'iPhone 13 256GB White', 17500, 19000, 'S 06.22'),

  ('2026-07-14', 'iPhone 13 256GB White', 17500, 19000, 'S 06.22'),
  ('2026-07-14', 'iPhone 13 256GB White', 17500, 19000, 'S 06.22'),
  ('2026-07-14', 'iPhone 13 256GB White', 17500, 19000, 'S 06.22'),
  ('2026-07-14', 'iPhone 13 256GB Pink', 17500, 19000, 'S 06.22'),
  ('2026-07-14', 'iPhone 13 256GB Pink', 17500, 19000, 'S 06.22'),

  ('2026-07-20', 'MacBook Neo 256GB Silver (Brand New)', 37300, 42000, 'bgc'),

  ('2026-07-23', 'iPhone 11 128GB White', 10700, 12200, 'L 06.10'),
  ('2026-07-23', 'iPhone 11 128GB White', 10700, 12200, 'L 06.10'),
  ('2026-07-23', 'iPhone 11 128GB Black', 10700, 12200, 'L 06.10'),
  ('2026-07-23', 'iPhone 11 128GB Black', 10700, 12200, 'L 06.10'),
  ('2026-07-23', 'iPhone 11 128GB Mint', 10700, 12200, 'L 06.10'),

  ('2026-07-23', 'iPhone 12 128GB White', 12200, 14000, 'L 05.06'),
  ('2026-07-23', 'iPhone 12 128GB White', 12200, 14000, 'L 05.06'),
  ('2026-07-23', 'iPhone 12 128GB Purple', 12200, 14000, 'L 05.06'),

  ('2026-07-24', 'iPhone XR 128GB White', 9000, 10000, 'A 12.08'),
  ('2026-07-24', 'iPhone XR 128GB Blue', 9000, 10000, 'A 12.08'),
  ('2026-07-24', 'iPhone XR 128GB Black', 9000, 10000, 'A 12.08'),
  ('2026-07-24', 'iPhone XR 128GB Coral', 9000, 10000, 'A 12.08'),
  ('2026-07-24', 'iPhone XR 128GB White', 8500, 10000, 'L 04.19');
