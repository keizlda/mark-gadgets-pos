-- Adds "Prulife" (life insurance premiums) as a third expense category,
-- alongside the existing General/Cargo, so Reports can break it out in its
-- own summary line. Run this in the Supabase SQL Editor.

alter table public.expenses drop constraint if exists expenses_category_check;

alter table public.expenses
  add constraint expenses_category_check check (category in ('General', 'Cargo', 'Prulife'));
