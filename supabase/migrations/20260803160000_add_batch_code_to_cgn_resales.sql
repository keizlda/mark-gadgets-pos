-- Lets the CGN Ledger show a real batch code for "CGN Resale" rows instead
-- of a permanent blank dash. Free text, not an FK to devices — some CGN
-- resales trace back to a unit we actually sold them wholesale (a real
-- devices.batch_code), but others were sourced by CGN directly from a
-- supplier and never passed through our own inventory at all, so there's
-- no devices row to reference for those.
alter table public.cgn_resales add column batch_code text;
