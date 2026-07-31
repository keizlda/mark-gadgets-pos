-- Real historical data entry — July 2025 daily sales report ("cleared").
-- Backfills devices + sales + sale_items for every completed sale in the
-- report, plus the 4 lump-sum monthly figures from its summary block, so
-- the Financial page's computed Profit/Net Profit can be checked against
-- the report's own totals (₱300,400 Profit / ₱195,240 Net Profit).
--
-- One row skipped on purpose: the iPhone 12 Pro Max 256GB logged 07.10.25
-- (₱33,000 capital) has no recorded sale price yet ("--" in the source) —
-- add it later via Add Device once there's a real listing price.
--
-- Run this once in the Supabase SQL Editor (Project → SQL Editor → New query).

-- ============================================================
-- Suppliers referenced by this report that may not exist yet
-- ============================================================
insert into public.suppliers (name) values
  ('Lilah'), ('Aminor'), ('Sohayma'), ('Dara'), ('Sarcee'),
  ('Therence'), ('JB'), ('Fr. Bagtong'), ('Lester'), ('Mona')
on conflict (name) do nothing;

-- ============================================================
-- Older models this report includes that aren't in the current
-- Add Device catalog yet — added so this stock (and any more of it)
-- can be entered through the normal UI going forward, not just SQL.
-- ============================================================
insert into public.product_models (category, name, colors) values
  ('iPhone', 'iPhone X', ARRAY['Space Gray','Silver']),
  ('iPad', 'iPad Air 2', ARRAY['Space Gray','Silver','Gold']),
  ('iPad', 'iPad Air (5th Gen, M1)', ARRAY['Space Gray','Starlight','Blue','Purple','Pink']),
  ('MacBook', 'MacBook Air M1', ARRAY['Space Gray','Gold','Silver']),
  ('MacBook', 'MacBook Air (2017)', ARRAY['Space Gray','Silver','Gold'])
on conflict (category, name) do nothing;

-- ============================================================
-- The 82 completed sales (every row in the report except the one
-- unsold unit noted above). customer_name is set only for the two
-- rows/batches where the source ledger names a buyer ("mona", "baloc")
-- instead of a repeated date.
-- ============================================================
do $$
declare
  rec record;
  v_device_id uuid;
  v_supplier_id uuid;
  v_sale_id uuid;
  v_current_date date := null;
  v_seq int := 0;
  v_batch_code text;
begin
  for rec in
    select * from (values
      (1,  '2025-07-04'::date, 'iPad Air 2',        'iPads',    '128GB', 4800::numeric,  7000::numeric,  'Lilah',       null::text, 'Cellular',                                'Pre-owned'),
      (2,  '2025-07-04'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   15500, 'Lilah',       null,   'Skyro',                                    'Pre-owned'),
      (3,  '2025-07-04'::date, 'iPhone 11 Pro Max', 'iPhones', '256GB', 17000,  21000, 'Aminor',      null,   'BDO Credit Card',                          'Pre-owned'),
      (4,  '2025-07-05'::date, 'iPhone 13 Pro Max', 'iPhones', '256GB', 27500,  32000, 'Aminor',      null,   null,                                       'Pre-owned'),
      (5,  '2025-07-05'::date, 'iPhone 14 Pro Max', 'iPhones', '256GB', 36500,  44500, null,          null,   'Skyro',                                    'Pre-owned'),
      (6,  '2025-07-05'::date, 'iPhone 13 Pro Max', 'iPhones', '256GB', 27500,  35500, 'Aminor',      null,   'Skyro',                                    'Pre-owned'),
      (7,  '2025-07-05'::date, 'MacBook Air M1',    'MacBooks','256GB', 34500,  41500, null,          null,   'Skyro',                                    'Brand New'),
      (8,  '2025-07-05'::date, 'iPhone 15 Pro Max', 'iPhones', '256GB', 41500,  51500, null,          null,   'Skyro',                                    'Pre-owned'),
      (9,  '2025-07-05'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  12500, 'Sohayma',     'Baloc','Bulk buyer batch',                         'Pre-owned'),
      (10, '2025-07-05'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  12500, 'Sohayma',     'Baloc','Bulk buyer batch',                         'Pre-owned'),
      (11, '2025-07-05'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  12500, 'Sohayma',     'Baloc','Bulk buyer batch',                         'Pre-owned'),
      (12, '2025-07-05'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  12500, 'Sohayma',     'Baloc','Bulk buyer batch',                         'Pre-owned'),
      (13, '2025-07-05'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  12500, 'Sohayma',     'Baloc','Bulk buyer batch',                         'Pre-owned'),
      (14, '2025-07-06'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  13500, 'Sohayma',     null,   null,                                       'Pre-owned'),
      (15, '2025-07-06'::date, 'iPhone 13',         'iPhones', '128GB', 16800,  21000, 'Aminor',      null,   null,                                       'Pre-owned'),
      (16, '2025-07-06'::date, 'iPhone 13 Pro',     'iPhones', '256GB', 23500,  32500, 'Aminor',      null,   'Skyro',                                    'Pre-owned'),
      (17, '2025-07-06'::date, 'iPhone 11',         'iPhones', '128GB', 12000,  13500, 'Lilah',       null,   null,                                       'Pre-owned'),
      (18, '2025-07-07'::date, 'iPhone 16 Pro Max', 'iPhones', '256GB', 53000,  68500, null,          null,   'Trade-in: swap 14 Pro Max (25000) + 43500 cash', 'Pre-owned'),
      (19, '2025-07-07'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   15500, 'Lilah',       null,   'Skyro',                                    'Pre-owned'),
      (20, '2025-07-08'::date, 'iPhone 13 Pro Max', 'iPhones', '256GB', 27500,  32500, 'Aminor',      null,   'Maya',                                     'Pre-owned'),
      (21, '2025-07-08'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  13500, 'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (22, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (23, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (24, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (25, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (26, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (27, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (28, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (29, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (30, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (31, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (32, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (33, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (34, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (35, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (36, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (37, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (38, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (39, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (40, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (41, '2025-07-08'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   10600, 'Lilah',       'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (42, '2025-07-09'::date, 'iPad Air (5th Gen, M1)', 'iPads', '64GB', 23000, 28500, null,         null,   'Trade-in: swap 10th Gen + 18500 cash',    'Pre-owned'),
      (43, '2025-07-09'::date, 'iPhone 11',         'iPhones', '128GB', 12000,  13500, 'Lilah',       null,   null,                                       'Pre-owned'),
      (44, '2025-07-09'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   11500, 'Lilah',       null,   null,                                       'Pre-owned'),
      (45, '2025-07-09'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  13500, 'Sohayma',     null,   null,                                       'Pre-owned'),
      (46, '2025-07-09'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  13500, 'Sohayma',     null,   null,                                       'Pre-owned'),
      (47, '2025-07-09'::date, 'iPhone 14 Pro Max', 'iPhones', '128GB', 25000,  30000, null,          null,   'Trade-in: swap 13 Pro Max + 10000 cash',  'Pre-owned'),
      (48, '2025-07-10'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  12500, 'Sohayma',     null,   'Drop ship by Ong Amor',                   'Pre-owned'),
      (49, '2025-07-10'::date, 'iPhone 13',         'iPhones', '256GB', 18500,  28500, 'Aminor',      null,   'Skyro',                                    'Pre-owned'),
      (50, '2025-07-10'::date, 'MacBook Air (2017)','MacBooks', null,   0,      1000,  'Lester',      null,   null,                                       'Pre-owned'),
      (51, '2025-07-11'::date, 'iPad 10th Gen',     'iPads',   '64GB', 10000,  18500, 'Dara',        null,   'Skyro',                                    'Pre-owned'),
      (52, '2025-07-12'::date, 'iPhone 13 Pro Max', 'iPhones', '256GB', 27500,  35500, 'Aminor',      null,   'Skyro',                                    'Pre-owned'),
      (53, '2025-07-14'::date, 'iPhone 13',         'iPhones', '256GB', 18500,  28500, 'Aminor',      null,   'Skyro',                                    'Pre-owned'),
      (54, '2025-07-14'::date, 'iPhone 13',         'iPhones', '256GB', 18500,  23000, 'Aminor',      null,   null,                                       'Pre-owned'),
      (55, '2025-07-15'::date, 'iPhone 13',         'iPhones', '128GB', 16800,  26500, 'Aminor',      null,   'Skyro',                                    'Pre-owned'),
      (56, '2025-07-15'::date, 'iPhone 13 Pro Max', 'iPhones', '128GB', 20000,  28500, 'Sarcee',      null,   'Skyro',                                    'Pre-owned'),
      (57, '2025-07-16'::date, 'iPhone 15 Pro Max', 'iPhones', '256GB', 45000,  49000, null,          null,   null,                                       'Pre-owned'),
      (58, '2025-07-18'::date, 'iPhone 13 Pro Max', 'iPhones', '256GB', 27500,  32500, 'Aminor',      null,   'Maya',                                     'Pre-owned'),
      (59, '2025-07-18'::date, 'iPhone 16 Plus',    'iPhones', '128GB', 43000,  52000, 'Therence',    null,   'Trade-in: swap 13 Pro Max + 32000 cash',  'Brand New'),
      (60, '2025-07-18'::date, 'iPhone 16 Pro Max', 'iPhones', '256GB', 67000,  71000, 'JB',          null,   'Trade-in: swap 12 Pro Max + 55000 cash',  'Brand New'),
      (61, '2025-07-21'::date, 'iPhone 12',         'iPhones', '128GB', 13500,  16500, 'Sohayma',     null,   null,                                       'Pre-owned'),
      (62, '2025-07-21'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  18500, 'Sohayma',     null,   'Skyro',                                    'Pre-owned'),
      (63, '2025-07-21'::date, 'iPhone 16',         'iPhones', '256GB', 35000,  45500, 'Fr. Bagtong', null,   'Skyro',                                    'Pre-owned'),
      (64, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     null,   null,                                       'Pre-owned'),
      (65, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (66, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (67, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (68, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (69, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (70, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (71, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (72, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (73, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (74, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (75, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (76, '2025-07-22'::date, 'iPhone X',          'iPhones', '256GB', 8000,   9600,  'Sohayma',     'Mona', 'Bulk buyer batch',                         'Pre-owned'),
      (77, '2025-07-25'::date, 'iPhone 11',         'iPhones', '128GB', 11000,  13000, 'Sohayma',     null,   null,                                       'Pre-owned'),
      (78, '2025-07-25'::date, 'iPhone 13 Pro Max', 'iPhones', '512GB', 27500,  33500, 'Aminor',      null,   null,                                       'Pre-owned'),
      (79, '2025-07-26'::date, 'iPhone 11',         'iPhones', '128GB', 12000,  12500, 'Mona',        null,   null,                                       'Pre-owned'),
      (80, '2025-07-27'::date, 'iPhone XR',         'iPhones', '128GB', 9000,   11000, 'Lilah',       null,   null,                                       'Pre-owned'),
      (81, '2025-07-27'::date, 'iPhone 13',         'iPhones', '128GB', 22000,  27500, 'Therence',    null,   'Maya',                                     'Brand New'),
      (82, '2025-07-28'::date, 'iPhone 12',         'iPhones', '128GB', 13500,  16500, 'Sohayma',     null,   null,                                       'Pre-owned')
    ) as t(rownum, sale_date, device_name, category, storage, capital, disposal, supplier_name, customer_name, note, condition)
    order by rownum
  loop
    if rec.sale_date is distinct from v_current_date then
      v_current_date := rec.sale_date;
      v_seq := 0;
    end if;
    v_seq := v_seq + 1;
    v_batch_code := to_char(rec.sale_date, 'MMDDYY') || '-' || lpad(v_seq::text, 3, '0');

    v_supplier_id := null;
    if rec.supplier_name is not null then
      select id into v_supplier_id from public.suppliers where name = rec.supplier_name;
    end if;

    insert into public.devices (
      batch_code, device_name, category, storage, color, status,
      supplier_id, purchase_price, selling_price, condition, notes, date_added
    ) values (
      v_batch_code, rec.device_name, rec.category, rec.storage, null, 'Sold',
      v_supplier_id, rec.capital, rec.disposal, rec.condition,
      null,
      rec.sale_date::timestamptz
    )
    returning id into v_device_id;

    insert into public.sales (
      customer_name, salesperson_id, payment_method, reference_number,
      notes, total_amount, status, order_type, payment_status, sold_at
    ) values (
      rec.customer_name, null, 'Cash', 'N/A',
      rec.note, rec.disposal, 'Completed', 'Regular', 'Paid', rec.sale_date::timestamptz
    )
    returning id into v_sale_id;

    insert into public.sale_items (sale_id, device_id, price_at_sale, quantity)
    values (v_sale_id, v_device_id, rec.disposal, 1);
  end loop;
end $$;

-- ============================================================
-- The 4 lump-sum monthly figures from the report's summary block,
-- dated to the last transaction date in the report (07.28.25) since
-- the source doesn't give a daily breakdown. Together with the Profit
-- above, these are what the report nets down to ₱195,240 Net Profit.
-- ============================================================
insert into public.expenses (expense_date, description, amount, admin_only) values
  ('2025-07-28', 'July 2025 expenses (monthly total, from paper ledger)', 84911, false),
  ('2025-07-28', 'July 2025 incentives & SF (monthly total, from paper ledger)', 12549, false),
  ('2025-07-28', 'July 2025 Skyro commission (monthly total, from paper ledger)', 1700, false),
  ('2025-07-28', 'July 2025 life insurance (monthly total, from paper ledger)', 6000, false);
