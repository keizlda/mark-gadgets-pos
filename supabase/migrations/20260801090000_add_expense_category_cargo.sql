-- Lets an expense be tagged "Cargo" (shipping/rider/courier fees) so the
-- Financial page can total those separately from general expenses, instead
-- of them being buried in one lump Total Expenses figure.
-- Run this in the Supabase SQL Editor (Project → SQL Editor → New query).

alter table public.expenses
  add column if not exists category text not null default 'General'
  check (category in ('General', 'Cargo'));
