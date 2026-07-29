-- The overload-ambiguity bug fixed in the previous migration (13-arg vs
-- 14-arg add_device) traces back further: the very first add_device, from
-- before the bulk-shipment feature, had an 11-arg signature. When that
-- feature's migration added p_bulk_order_shell_id/p_date_arrived via
-- create-or-replace, it widened the signature and — same mistake — left
-- that original 11-arg version behind as a separate overload instead of
-- replacing it. It hasn't caused a visible error yet only because no call
-- has happened to trigger it, but it's the same latent hazard the last
-- migration just fixed for the 13-vs-14 pair. Drop it defensively.
drop function if exists public.add_device(
  text, text, text, text, text, text, text, numeric, text, timestamptz, text
);
