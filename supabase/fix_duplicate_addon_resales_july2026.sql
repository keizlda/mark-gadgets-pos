-- One-time data fix for the July 2026 historical data already loaded into
-- the live database (historical_data_july2026.sql). 5 of the 26 "Add on"
-- units were actually resold later in the same month under a separate Main
-- Sales batch code (confirmed by matching model + purchase price, with the
-- Add-on purchase date before the Main sale date). The resale is already
-- fully recorded as its own device/sale/sale_item under that other batch
-- code, so these don't get a second sale record here (that would
-- double-count the revenue) — they're just flipped out of Available stock,
-- since they aren't actually available anymore.
--
--   070326-007 (iPhone 13 Pro 256GB Gold)      -> resold as 071126-004
--   071226-002 (iPhone 16 256GB Teal)          -> resold as 072126-001
--   071426-003 (iPhone 13 Pro Max 128GB Gold)  -> resold as 071726-003
--   071626-005 (iPad 10th Gen 256GB Blue)      -> resold as 072226-002
--     (also fixes a data-entry typo: this unit's capital is 13500, not
--     13000 as originally entered)
--   073026-003 (iPad 11th Gen 128GB Silver)    -> resold as 073026-001
--
-- Run this once in the Supabase SQL Editor.

update public.devices
set status = 'Sold',
    notes = 'Resold under a different batch code the same month — see that batch code for the actual sale record. This entry stays for the original purchase-in trail only.'
where batch_code in ('070326-007', '071226-002', '071426-003', '073026-003', '071626-005');

update public.devices
set purchase_price = 13500
where batch_code = '071626-005';
