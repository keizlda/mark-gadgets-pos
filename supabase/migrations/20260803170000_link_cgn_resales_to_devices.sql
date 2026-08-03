-- Proper traceability link for the CGN Ledger's "CGN Resale" rows — a real
-- device_id, not just a free-text batch code, so the existing Supplier
-- Defective / Replace flow can actually operate on the unit if a CGN resale
-- customer needs a replacement.
alter table public.cgn_resales add column device_id uuid references public.devices(id);
