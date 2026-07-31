-- Mark Gadgets — mock dry-run data (v2)
-- Not a schema migration — a one-off data seed for testing. Run once
-- against a freshly wiped database (see the truncate script). Same
-- January-through-July spread as the original seed, extended with the
-- two categories added since: Repair Parts (its own Brand New / Genuine /
-- Used condition vocabulary, no Storage/Color) and Accessories (real
-- colors on cases, no Storage). Every device that ends up Reserved has a
-- matching reservations row — Add Device no longer allows setting status
-- straight to Reserved for exactly this reason, so seed data shouldn't
-- either.
do $$
declare
  v_salesperson uuid;

  v_sup_istudio uuid := gen_random_uuid();
  v_sup_lilah uuid := gen_random_uuid();
  v_sup_bgc uuid := gen_random_uuid();
  v_sup_sohayma uuid := gen_random_uuid();
  v_sup_ping uuid := gen_random_uuid();
  v_sup_diane uuid := gen_random_uuid();
  v_sup_techparts uuid := gen_random_uuid();
  v_sup_gadgetworld uuid := gen_random_uuid();

  v_shell_a uuid := gen_random_uuid(); -- iStudio, iPhone 13 x5, Jan 15, Paid
  v_shell_b uuid := gen_random_uuid(); -- Lilah, iPhone 11 x4, Mar 10, Unpaid
  v_shell_c uuid := gen_random_uuid(); -- BGC, iPhone 14 x6 expected, Jul 20, only 2 logged, Pending

  -- iPhone 13 (Shell A, Brand New)
  v_ip13_1 uuid := gen_random_uuid();
  v_ip13_2 uuid := gen_random_uuid();
  v_ip13_3 uuid := gen_random_uuid();
  v_ip13_4 uuid := gen_random_uuid();
  v_ip13_5 uuid := gen_random_uuid();

  -- iPhone 11 (Shell B, Pre-owned)
  v_ip11_1 uuid := gen_random_uuid();
  v_ip11_2 uuid := gen_random_uuid();
  v_ip11_3 uuid := gen_random_uuid(); -- sold then returned -> Supplier Defective
  v_ip11_4 uuid := gen_random_uuid(); -- replacement unit for the return

  -- iPhone 14 (Shell C, Brand New, shipment still Pending)
  v_ip14_1 uuid := gen_random_uuid();
  v_ip14_2 uuid := gen_random_uuid();

  -- iPhone 15 Pro (standalone, Brand New)
  v_ip15p_1 uuid := gen_random_uuid();
  v_ip15p_2 uuid := gen_random_uuid();
  v_ip15p_3 uuid := gen_random_uuid();

  -- iPhone XR (standalone, Pre-owned)
  v_ipxr_1 uuid := gen_random_uuid();
  v_ipxr_2 uuid := gen_random_uuid();
  v_ipxr_3 uuid := gen_random_uuid(); -- sold via reservation conversion
  v_ipxr_4 uuid := gen_random_uuid(); -- standalone Supplier Defective

  -- iPad 9th gen (standalone, Brand New)
  v_ipad_1 uuid := gen_random_uuid();
  v_ipad_2 uuid := gen_random_uuid();

  -- Apple Watch Series 9 (standalone, Brand New)
  v_watch_1 uuid := gen_random_uuid();
  v_watch_2 uuid := gen_random_uuid(); -- Active reservation

  -- MacBook Air M1 (standalone, Pre-owned)
  v_mba_1 uuid := gen_random_uuid();
  v_mba_2 uuid := gen_random_uuid();

  -- Repair Parts (standalone, no Storage/Color)
  v_rp_lcd13 uuid := gen_random_uuid();   -- iPhone 13 LCD Screen, Genuine, sold
  v_rp_bat11 uuid := gen_random_uuid();   -- iPhone 11 Battery, Brand New, sold
  v_rp_portxr uuid := gen_random_uuid();  -- iPhone XR Charging Port Flex, Used, available
  v_rp_lcdipad uuid := gen_random_uuid(); -- iPad LCD Screen, Genuine, available
  v_rp_batmba uuid := gen_random_uuid();  -- MacBook Battery, Brand New, sold

  -- Accessories (standalone, real colors, no Storage)
  v_acc_case1 uuid := gen_random_uuid(); -- Phone Case, Black, sold
  v_acc_case2 uuid := gen_random_uuid(); -- Phone Case, Clear, available
  v_acc_prot uuid := gen_random_uuid();  -- Screen Protector, sold
  v_acc_charger uuid := gen_random_uuid(); -- Charger, White, available
  v_acc_earbuds uuid := gen_random_uuid(); -- Wireless Earbuds, Black, sold

  v_sale1 uuid := gen_random_uuid();
  v_sale2 uuid := gen_random_uuid();
  v_sale3 uuid := gen_random_uuid(); -- bulk, 4 units, Paid
  v_sale4 uuid := gen_random_uuid();
  v_sale5 uuid := gen_random_uuid(); -- later returned
  v_sale6 uuid := gen_random_uuid();
  v_sale7 uuid := gen_random_uuid(); -- bulk, 5 units, Pending
  v_sale8 uuid := gen_random_uuid();
  v_sale9 uuid := gen_random_uuid();
  v_sale10 uuid := gen_random_uuid(); -- reservation conversion
  v_sale11 uuid := gen_random_uuid();
  v_sale12 uuid := gen_random_uuid();
  v_sale13 uuid := gen_random_uuid();
  v_sale14 uuid := gen_random_uuid();
  v_sale15 uuid := gen_random_uuid();
  v_sale16 uuid := gen_random_uuid();

  v_saleitem_ip11_3 uuid := gen_random_uuid();
begin
  select id into v_salesperson from public.profiles order by created_at limit 1;

  -- ============================================================
  -- SUPPLIERS
  -- ============================================================
  insert into public.suppliers (id, name) values
    (v_sup_istudio, 'iStudio Philippines'),
    (v_sup_lilah, 'Lilah'),
    (v_sup_bgc, 'BGC Trading'),
    (v_sup_sohayma, 'Sohayma'),
    (v_sup_ping, 'Ping'),
    (v_sup_diane, 'Diane Rose'),
    (v_sup_techparts, 'TechParts PH'),
    (v_sup_gadgetworld, 'Gadget World');

  -- ============================================================
  -- BULK ORDER SHELLS
  -- ============================================================
  insert into public.bulk_order_shells
    (id, supplier_id, device_name, storage, color, quantity_expected, date_arrived, status, unit_cost, supplier_payment_status, supplier_paid_at)
  values
    (v_shell_a, v_sup_istudio, 'iPhone 13', '128GB', null, 5, '2026-01-15T09:00:00+08', 'Completed', 17000, 'Paid', '2026-01-20T10:00:00+08'),
    (v_shell_b, v_sup_lilah, 'iPhone 11', '128GB', null, 4, '2026-03-10T09:00:00+08', 'Completed', 9500, 'Unpaid', null),
    (v_shell_c, v_sup_bgc, 'iPhone 14', '128GB', null, 6, '2026-07-20T09:00:00+08', 'Pending', 27000, 'Unpaid', null);

  -- ============================================================
  -- DEVICES
  -- ============================================================

  -- iPhone 13 x5 — from Shell A, all logged the day it arrived
  insert into public.devices (id, batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, date_added, bulk_order_shell_id, date_arrived) values
    (v_ip13_1, '011526-001', 'iPhone 13', 'iPhones', '128GB', 'Midnight',   'Available', v_sup_istudio, 17000, 20500, 'Brand New', '2026-01-15T09:00:00+08', v_shell_a, '2026-01-15T09:00:00+08'),
    (v_ip13_2, '011526-002', 'iPhone 13', 'iPhones', '128GB', 'Starlight',  'Sold',      v_sup_istudio, 17000, 20500, 'Brand New', '2026-01-15T09:00:00+08', v_shell_a, '2026-01-15T09:00:00+08'),
    (v_ip13_3, '011526-003', 'iPhone 13', 'iPhones', '128GB', 'Blue',       'Sold',      v_sup_istudio, 17000, 20500, 'Brand New', '2026-01-15T09:00:00+08', v_shell_a, '2026-01-15T09:00:00+08'),
    (v_ip13_4, '011526-004', 'iPhone 13', 'iPhones', '128GB', 'Pink',       'Sold',      v_sup_istudio, 17000, 20500, 'Brand New', '2026-01-15T09:00:00+08', v_shell_a, '2026-01-15T09:00:00+08'),
    (v_ip13_5, '011526-005', 'iPhone 13', 'iPhones', '128GB', 'Green',      'Available', v_sup_istudio, 17000, 20500, 'Brand New', '2026-01-15T09:00:00+08', v_shell_a, '2026-01-15T09:00:00+08');

  -- iPhone 11 x4 — from Shell B, Pre-owned
  insert into public.devices (id, batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, date_added, bulk_order_shell_id, date_arrived) values
    (v_ip11_1, '031026-001', 'iPhone 11', 'iPhones', '128GB', 'Black', 'Sold',              v_sup_lilah, 9500, 12500, 'Pre-owned', '2026-03-10T09:00:00+08', v_shell_b, '2026-03-10T09:00:00+08'),
    (v_ip11_2, '031026-002', 'iPhone 11', 'iPhones', '128GB', 'White', 'Sold',              v_sup_lilah, 9500, 12500, 'Pre-owned', '2026-03-10T09:00:00+08', v_shell_b, '2026-03-10T09:00:00+08'),
    (v_ip11_3, '031026-003', 'iPhone 11', 'iPhones', '128GB', 'Red',   'Supplier Defective', v_sup_lilah, 9500, 12500, 'Pre-owned', '2026-03-10T09:00:00+08', v_shell_b, '2026-03-10T09:00:00+08'),
    (v_ip11_4, '031026-004', 'iPhone 11', 'iPhones', '128GB', 'Yellow','Sold',              v_sup_lilah, 9500, 12500, 'Pre-owned', '2026-03-10T09:00:00+08', v_shell_b, '2026-03-10T09:00:00+08');

  -- iPhone 14 x2 — from Shell C, shipment still Pending (2 of 6 expected logged)
  insert into public.devices (id, batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, date_added, bulk_order_shell_id, date_arrived) values
    (v_ip14_1, '072026-001', 'iPhone 14', 'iPhones', '128GB', 'Blue',   'Available', v_sup_bgc, 27000, 32000, 'Brand New', '2026-07-20T09:00:00+08', v_shell_c, '2026-07-20T09:00:00+08'),
    (v_ip14_2, '072026-002', 'iPhone 14', 'iPhones', '128GB', 'Purple', 'Available', v_sup_bgc, 27000, 32000, 'Brand New', '2026-07-20T09:00:00+08', v_shell_c, '2026-07-20T09:00:00+08');

  -- iPhone 15 Pro x3 — standalone, Brand New
  insert into public.devices (id, batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, date_added) values
    (v_ip15p_1, '020126-001', 'iPhone 15 Pro', 'iPhones', '256GB', 'Natural Titanium', 'Sold', v_sup_sohayma, 45000, 55000, 'Brand New', '2026-02-01T10:00:00+08'),
    (v_ip15p_2, '030126-001', 'iPhone 15 Pro', 'iPhones', '256GB', 'Blue Titanium',    'Sold', v_sup_sohayma, 45000, 55000, 'Brand New', '2026-03-01T10:00:00+08'),
    (v_ip15p_3, '060126-001', 'iPhone 15 Pro', 'iPhones', '256GB', 'White Titanium',   'Sold', v_sup_sohayma, 45000, 55000, 'Brand New', '2026-06-01T10:00:00+08');

  -- iPhone XR x4 — standalone, Pre-owned
  insert into public.devices (id, batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, date_added) values
    (v_ipxr_1, '010526-001', 'iPhone XR', 'iPhones', '128GB', 'Black', 'Sold',              v_sup_sohayma, 8500, 10500, 'Pre-owned', '2026-01-05T10:00:00+08'),
    (v_ipxr_2, '030526-001', 'iPhone XR', 'iPhones', '128GB', 'White', 'Sold',              v_sup_sohayma, 8500, 10500, 'Pre-owned', '2026-03-05T10:00:00+08'),
    (v_ipxr_3, '070126-001', 'iPhone XR', 'iPhones', '128GB', 'Coral', 'Sold',              v_sup_sohayma, 8500, 10500, 'Pre-owned', '2026-07-01T10:00:00+08'),
    (v_ipxr_4, '011026-001', 'iPhone XR', 'iPhones', '128GB', 'Blue',  'Supplier Defective', v_sup_sohayma, 8500, 10500, 'Pre-owned', '2026-01-10T10:00:00+08');

  -- iPad 9th gen x2 — standalone, Brand New
  insert into public.devices (id, batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, date_added) values
    (v_ipad_1, '021026-001', 'iPad 9th gen', 'iPads', '64GB', 'Space Gray', 'Sold', v_sup_ping, 11000, 14500, 'Brand New', '2026-02-10T10:00:00+08'),
    (v_ipad_2, '040126-001', 'iPad 9th gen', 'iPads', '64GB', 'Silver',     'Sold', v_sup_ping, 11000, 14500, 'Brand New', '2026-04-01T10:00:00+08');

  -- Apple Watch Series 9 x2 — standalone, Brand New
  insert into public.devices (id, batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, date_added) values
    (v_watch_1, '012526-001', 'Apple Watch Series 9', 'Apple Watches', '41mm', 'Midnight',  'Sold',     v_sup_ping, 15000, 19500, 'Brand New', '2026-01-25T10:00:00+08'),
    (v_watch_2, '050126-001', 'Apple Watch Series 9', 'Apple Watches', '41mm', 'Starlight', 'Reserved', v_sup_ping, 15000, 19500, 'Brand New', '2026-05-01T10:00:00+08');

  -- MacBook Air M1 x2 — standalone, Pre-owned
  insert into public.devices (id, batch_code, device_name, category, storage, color, status, supplier_id, purchase_price, selling_price, condition, date_added) values
    (v_mba_1, '021526-001', 'MacBook Air M1', 'MacBooks', '256GB', 'Space Gray', 'Sold', v_sup_diane, 28000, 36000, 'Pre-owned', '2026-02-15T10:00:00+08'),
    (v_mba_2, '060126-002', 'MacBook Air M1', 'MacBooks', '256GB', 'Gold',       'Sold', v_sup_diane, 28000, 36000, 'Pre-owned', '2026-06-01T10:00:00+08');

  -- Repair Parts x5 — standalone, no Storage/Color, own condition vocabulary
  insert into public.devices (id, batch_code, device_name, category, condition, status, supplier_id, purchase_price, selling_price, date_added) values
    (v_rp_lcd13,   '022026-001', 'iPhone 13 LCD Screen',          'Repair Parts', 'Genuine',   'Sold',      v_sup_techparts, 3500, 6000, '2026-02-20T10:00:00+08'),
    (v_rp_bat11,   '031526-001', 'iPhone 11 Battery',             'Repair Parts', 'Brand New', 'Sold',      v_sup_techparts,  800, 1800, '2026-03-15T10:00:00+08'),
    (v_rp_portxr,  '050126-002', 'iPhone XR Charging Port Flex',  'Repair Parts', 'Used',      'Available', v_sup_techparts,  400, 1200, '2026-05-01T10:00:00+08'),
    (v_rp_lcdipad, '061026-001', 'iPad LCD Screen',                'Repair Parts', 'Genuine',   'Available', v_sup_techparts, 4500, 7500, '2026-06-10T10:00:00+08'),
    (v_rp_batmba,  '070526-001', 'MacBook Battery',                'Repair Parts', 'Brand New', 'Sold',      v_sup_techparts, 2500, 4500, '2026-07-05T10:00:00+08');

  -- Accessories x5 — standalone, no Storage, real colors where they apply
  insert into public.devices (id, batch_code, device_name, category, color, condition, status, supplier_id, purchase_price, selling_price, date_added) values
    (v_acc_case1,   '020526-001', 'Phone Case',                       'Accessories', 'Black', 'Brand New', 'Sold',      v_sup_gadgetworld, 150, 500,  '2026-02-05T10:00:00+08'),
    (v_acc_case2,   '030126-002', 'Phone Case',                       'Accessories', 'Clear', 'Brand New', 'Available', v_sup_gadgetworld, 150, 500,  '2026-03-01T10:00:00+08'),
    (v_acc_prot,    '041026-001', 'Screen Protector (Tempered Glass)', 'Accessories', 'N/A',   'Brand New', 'Sold',      v_sup_gadgetworld,  50, 250,  '2026-04-10T10:00:00+08'),
    (v_acc_charger, '051526-001', 'Charger / Power Adapter',           'Accessories', 'White', 'Brand New', 'Available', v_sup_gadgetworld, 300, 800,  '2026-05-15T10:00:00+08'),
    (v_acc_earbuds, '062026-001', 'Wireless Earbuds',                  'Accessories', 'Black', 'Brand New', 'Sold',      v_sup_gadgetworld, 1200, 2500, '2026-06-20T10:00:00+08');

  -- ============================================================
  -- SALES + SALE ITEMS
  -- ============================================================

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale1, 'Anna Reyes', '09171234501', v_salesperson, 'Cash', null, 10500, 'Completed', 'Regular', 'Paid', '2026-01-28T14:00:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale1, v_ipxr_1, 10500, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale2, 'Mark Tan', '09171234502', v_salesperson, 'GCash', 'GC-88213', 55000, 'Completed', 'Regular', 'Paid', '2026-02-05T11:30:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale2, v_ip15p_1, 55000, 1);

  -- Bulk sale, 4 units, Check, already marked Paid
  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale3, 'Ken Villareal (reseller)', '09171234503', v_salesperson, 'Check', 'CHK-10045', 66000, 'Completed', 'Bulk', 'Paid', '2026-03-20T15:00:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values
    (v_sale3, v_ip13_2, 20500, 1),
    (v_sale3, v_ip13_3, 20500, 1),
    (v_sale3, v_ip11_1, 12500, 1),
    (v_sale3, v_ip11_2, 12500, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale4, 'Grace Lim', '09171234504', v_salesperson, 'Bank Transfer', 'BT-55201', 14500, 'Completed', 'Regular', 'Paid', '2026-03-25T09:45:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale4, v_ipad_1, 14500, 1);

  -- This one gets returned+replaced below
  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale5, 'Paolo Garcia', '09171234505', v_salesperson, 'Cash', null, 12500, 'Completed', 'Regular', 'Paid', '2026-04-18T13:20:00+08');
  insert into public.sale_items (id, sale_id, device_id, price_at_sale, quantity) values (v_saleitem_ip11_3, v_sale5, v_ip11_3, 12500, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale6, 'Liza Cruz', '09171234506', v_salesperson, 'GCash', 'GC-90344', 19500, 'Completed', 'Regular', 'Paid', '2026-05-02T10:10:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale6, v_watch_1, 19500, 1);

  -- Bulk sale, 5 units, Skyro installment, still Pending
  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale7, 'Ella Fernandez (reseller)', '09171234507', v_salesperson, 'Skyro', 'SKY-77021', 136500, 'Completed', 'Bulk', 'Pending', '2026-05-25T16:00:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values
    (v_sale7, v_ip13_4, 20500, 1),
    (v_sale7, v_ip15p_2, 55000, 1),
    (v_sale7, v_ipxr_2, 10500, 1),
    (v_sale7, v_mba_1, 36000, 1),
    (v_sale7, v_ipad_2, 14500, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale8, 'Tin Aquino', '09171234508', v_salesperson, 'Home Credit', 'HC-33019', 55000, 'Completed', 'Regular', 'Paid', '2026-06-12T12:00:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale8, v_ip15p_3, 55000, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale9, 'Rico Hernandez', '09171234509', v_salesperson, 'Credit Card', 'CC-40021', 36000, 'Completed', 'Regular', 'Paid', '2026-07-08T14:40:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale9, v_mba_2, 36000, 1);

  -- Reservation-converted sale (down payment noted, matching convert_reservation_to_sale's notes format)
  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, notes, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale10, 'Jenny Ocampo', '09171234510', v_salesperson, 'Cash', null, 'Down payment of ₱1,500 already collected at reservation.', 10500, 'Completed', 'Regular', 'Paid', '2026-07-22T11:00:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale10, v_ipxr_3, 10500, 1);

  -- Repair parts + accessories sales
  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale11, 'Carlo Mendoza', '09171234514', v_salesperson, 'Cash', null, 6000, 'Completed', 'Regular', 'Paid', '2026-03-02T13:00:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale11, v_rp_lcd13, 6000, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale12, 'Bea Santos', '09171234515', v_salesperson, 'GCash', 'GC-12045', 1800, 'Completed', 'Regular', 'Paid', '2026-04-05T15:30:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale12, v_rp_bat11, 1800, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale13, 'Nico Reyes', '09171234516', v_salesperson, 'Cash', null, 4500, 'Completed', 'Regular', 'Paid', '2026-07-20T16:00:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale13, v_rp_batmba, 4500, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale14, 'Walk-in Customer', null, v_salesperson, 'Cash', null, 500, 'Completed', 'Regular', 'Paid', '2026-02-20T10:15:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale14, v_acc_case1, 500, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale15, 'Walk-in Customer', null, v_salesperson, 'GCash', 'GC-20011', 250, 'Completed', 'Regular', 'Paid', '2026-04-25T09:30:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale15, v_acc_prot, 250, 1);

  insert into public.sales (id, customer_name, customer_phone, salesperson_id, payment_method, reference_number, total_amount, status, order_type, payment_status, sold_at) values
    (v_sale16, 'Sam Villanueva', '09171234517', v_salesperson, 'Credit Card', 'CC-51022', 2500, 'Completed', 'Regular', 'Paid', '2026-07-10T17:00:00+08');
  insert into public.sale_items (sale_id, device_id, price_at_sale, quantity) values (v_sale16, v_acc_earbuds, 2500, 1);

  -- ============================================================
  -- CUSTOMER RETURN — resolved by replacement; original unit auto-transfers
  -- to Supplier Defective (no cash refunds), same as the real app flow.
  -- ============================================================
  insert into public.customer_returns (sale_item_id, reason, status, replacement_device_id, returned_at) values
    (v_saleitem_ip11_3, 'Battery draining fast, doesn''t hold a charge', 'Replaced', v_ip11_4, '2026-05-01T10:00:00+08');

  insert into public.supplier_defective_records (device_id, supplier_id, issue_description, status, date_detected) values
    (v_ip11_3, v_sup_lilah, 'Battery draining fast, doesn''t hold a charge', 'Pending Return', '2026-05-01T10:00:00+08');

  -- Standalone defective unit — never involved a sale, flagged at intake
  insert into public.supplier_defective_records (device_id, supplier_id, issue_description, action_taken, status, date_detected) values
    (v_ipxr_4, v_sup_sohayma, 'Screen has visible burn-in from previous owner', 'Contacted supplier, awaiting response', 'Pending Return', '2026-01-10T10:00:00+08');

  -- ============================================================
  -- RESERVATIONS — Active, Expired, Converted, Cancelled. Every reserved
  -- device has exactly one Active/Expiring Soon reservation behind it —
  -- no orphan "Reserved" statuses.
  -- ============================================================
  insert into public.reservations (device_id, customer_name, customer_phone, salesperson_id, reserved_until, status, total_price, down_payment, created_at) values
    (v_watch_2, 'Maria Santos', '09171234511', v_salesperson, '2026-08-15T23:59:59+08', 'Active', 19500, 3000, '2026-07-25T09:00:00+08');

  insert into public.reservations (device_id, customer_name, customer_phone, salesperson_id, reserved_until, status, total_price, down_payment, created_at) values
    (v_ip14_1, 'Juan Dela Cruz', '09171234512', v_salesperson, '2026-07-25T23:59:59+08', 'Expired', 32000, 0, '2026-07-21T09:00:00+08');

  insert into public.reservations (device_id, customer_name, customer_phone, salesperson_id, reserved_until, status, total_price, down_payment, created_at) values
    (v_ipxr_3, 'Jenny Ocampo', '09171234510', v_salesperson, '2026-07-20T23:59:59+08', 'Converted', 10500, 1500, '2026-07-15T09:00:00+08');

  insert into public.reservations (device_id, customer_name, customer_phone, salesperson_id, reserved_until, status, total_price, down_payment, created_at) values
    (v_ip13_1, 'Test Cancel', '09171234513', v_salesperson, '2026-06-01T23:59:59+08', 'Cancelled', 20500, 0, '2026-05-20T09:00:00+08');

  -- ============================================================
  -- EXPENSES — shared (Reports + Financial) and admin-only (Financial only)
  -- ============================================================
  insert into public.expenses (expense_date, description, amount, admin_only) values
    ('2026-01-10', 'Store Rent - January', 15000, false),
    ('2026-02-05', 'Electricity Bill', 3500, false),
    ('2026-03-03', 'Internet & Phone Bill', 2000, false),
    ('2026-03-20', 'Repair tools purchase', 4500, true),
    ('2026-04-15', 'Store Rent - April', 15000, false),
    ('2026-05-08', 'Facebook Ads boost', 5000, true),
    ('2026-06-12', 'Store Rent - June', 15000, false),
    ('2026-07-05', 'Staff bonus', 8000, true),
    ('2026-07-25', 'Electricity Bill', 4000, false);

end $$;
