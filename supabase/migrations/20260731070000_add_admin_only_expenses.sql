-- Expenses admin logs from the Financial page are for admin's own view
-- only — Reports (which any role can open) should keep showing just what
-- staff themselves have logged, not the admin-only ones.
alter table public.expenses add column admin_only boolean not null default false;
