-- Adds Skyro and Home Credit (installment providers) as valid payment
-- methods, alongside Check from the earlier bulk-order migration.
alter table public.sales drop constraint sales_payment_method_check;
alter table public.sales add constraint sales_payment_method_check
  check (payment_method in ('Cash', 'GCash', 'Credit Card', 'Bank Transfer', 'Check', 'Skyro', 'Home Credit'));
