-- Adds "Personal" (owner's personal draws, kept separate from Cargo/
-- Prulife/General) as a fourth expense category, admin-only (Financial),
-- not offered on the shared Reports page. Run this in the Supabase SQL Editor.

alter table public.expenses drop constraint if exists expenses_category_check;

alter table public.expenses
  add constraint expenses_category_check check (category in ('General', 'Cargo', 'Prulife', 'Personal'));
