-- The database session runs in UTC, so date_trunc('month', sold_at) bucketed
-- sales by the UTC month — anything sold between 00:00 and 07:59 Manila
-- time on the 1st landed in the previous month on the Dashboard chart.
-- Bucket by Manila's calendar month instead. month_start stays timestamptz
-- (Manila midnight on the 1st) so create or replace keeps the same column
-- types.
create or replace view public.sales_by_month_view
with (security_invoker = true) as
select
  date_trunc('month', sold_at at time zone 'Asia/Manila') at time zone 'Asia/Manila' as month_start,
  to_char(date_trunc('month', sold_at at time zone 'Asia/Manila'), 'Mon') as month,
  sum(total_amount) as sales
from public.sales
where status = 'Completed'
group by date_trunc('month', sold_at at time zone 'Asia/Manila');
