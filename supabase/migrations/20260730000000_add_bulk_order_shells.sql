-- Bulk shipment placeholders — staff can log "a shipment arrived" (supplier,
-- model, quantity, date) the same night without entering every serial, then
-- link each individual unit back to it the next morning via Add Device.
create table public.bulk_order_shells (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid references public.suppliers (id),
  device_name text not null,
  storage text,
  color text,
  quantity_expected int not null check (quantity_expected > 0),
  date_arrived timestamptz not null,
  status text not null default 'Pending' check (status in ('Pending', 'Completed')),
  notes text,
  created_at timestamptz not null default now()
);

alter table public.devices add column bulk_order_shell_id uuid references public.bulk_order_shells (id);
alter table public.devices add column date_arrived timestamptz;

create index on public.bulk_order_shells (supplier_id);
create index on public.devices (bulk_order_shell_id);

alter table public.bulk_order_shells enable row level security;

create policy "bulk_order_shells_all_authenticated" on public.bulk_order_shells
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
