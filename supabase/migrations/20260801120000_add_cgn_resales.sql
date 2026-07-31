-- CGN (the admin's other branch) resells units we already sold to them, to
-- their own customers. That's a separate business event from our own sales
-- — the unit already left our inventory when we sold it to CGN — so it
-- gets its own table rather than another row in devices/sales, which would
-- incorrectly imply we sold it a second time. Shown as a second table under
-- Financial's CGN Ledger view. Run this in the Supabase SQL Editor.

create table public.cgn_resales (
  id uuid primary key default gen_random_uuid(),
  sale_date date not null,
  device_name text not null,
  -- What CGN paid us for the unit (should generally match our own sale to
  -- them), and what CGN resold it for to their own customer.
  capital numeric(12, 2) not null check (capital >= 0),
  disposal_price numeric(12, 2) not null check (disposal_price >= 0),
  -- Free text — the shorthand supplier/receipt-date code from CGN's own
  -- ledger (e.g. "S 06.22"), kept for traceability, not a foreign key.
  supplier_note text,
  created_at timestamptz not null default now()
);

create index on public.cgn_resales (sale_date);

alter table public.cgn_resales enable row level security;

create policy "cgn_resales_all_authenticated" on public.cgn_resales
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
