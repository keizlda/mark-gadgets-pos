-- The previous migration added p_purchase_price via create-or-replace, but
-- adding a new parameter changes the function's signature — Postgres treated
-- it as a distinct overload instead of replacing the old one, leaving both
-- the old (no purchase_price) and new versions active side by side. That's
-- why calls started failing with "Could not choose the best candidate
-- function". Dropping the old-signature overloads leaves only the new one.
drop function if exists public.add_device(
  text, text, text, text, text, text, text, numeric, text, timestamptz, text, uuid, timestamptz
);

drop function if exists public.update_device(
  uuid, text, text, text, text, text, text, text, numeric, text, text
);
