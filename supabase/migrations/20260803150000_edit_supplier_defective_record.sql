-- Admin-only correction for a supplier defective record's own fields
-- (issue description, supplier, date detected) — separate from
-- update_supplier_defective_status, which only ever touched status/action
-- taken. Those three fields are the ones that live on
-- supplier_defective_records itself; batch code/device details are already
-- editable via the existing Edit Device flow on All Devices.
create function public.edit_supplier_defective_record(
  p_id uuid,
  p_issue_description text,
  p_supplier_name text,
  p_date_detected timestamptz
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_supplier_id uuid;
begin
  if p_supplier_name is null or p_supplier_name = '' then
    v_supplier_id := null;
  else
    select id into v_supplier_id from public.suppliers where name = p_supplier_name;
  end if;

  update public.supplier_defective_records
  set issue_description = p_issue_description,
      supplier_id = v_supplier_id,
      date_detected = p_date_detected
  where id = p_id;
end;
$$;
