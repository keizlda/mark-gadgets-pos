-- Adds "Swap" as a valid payment_method for the new swap-trade-in feature
-- on New Sale: a customer trades in their own phone (logged as a new
-- Available unit, its appraised value as Capital) toward one of ours. The
-- constraint was a fixed list, so the new value needs to be added
-- explicitly or every swap sale would fail at the database level.
--
-- Run this in the Supabase SQL Editor.

alter table public.sales drop constraint sales_payment_method_check;

alter table public.sales
  add constraint sales_payment_method_check
  check (payment_method in ('Cash', 'GCash', 'Credit Card', 'Bank Transfer', 'Check', 'Skyro', 'Home Credit', 'Swap'));
