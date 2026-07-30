-- profiles.role had no constraint at all — anything could end up in there.
-- Locking it to 'admin'/'staff' now, ahead of building admin-only features
-- on top of it.
alter table public.profiles
  add constraint profiles_role_check check (role in ('admin', 'staff'));
