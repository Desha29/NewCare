-- Login labels are visible only to an enrolled center device.
create or replace function public.list_center_login_managers(p_center_id uuid)
returns table(id uuid, username text, name text)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not private.is_device(p_center_id) then
    raise exception 'device_not_enrolled' using errcode = '42501';
  end if;
  return query
    select p.user_id, p.username, p.display_name
    from public.center_managers m
    join public.manager_profiles p on p.user_id = m.user_id
    where m.center_id = p_center_id and m.active
    order by p.display_name, p.username;
end;
$$;
revoke all on function public.list_center_login_managers(uuid) from public, anon, authenticated;
grant execute on function public.list_center_login_managers(uuid) to authenticated;

-- Lost responses may retry an identical operation, never replace its meaning.
create or replace function public.push_workspace_operation(
  p_center_id uuid, p_operation_id text, p_action text, p_payload jsonb
) returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not private.is_device(p_center_id) then
    raise exception 'device_not_enrolled' using errcode = '42501';
  end if;
  if p_operation_id is null or length(p_operation_id) not between 1 and 120
    or p_payload is null or jsonb_typeof(p_payload) <> 'object'
    or p_payload->>'version' is distinct from '1'
    or jsonb_typeof(p_payload->'collections') is distinct from 'object'
    or jsonb_typeof(p_payload->'settings') is distinct from 'object'
    or octet_length(p_payload::text) > 2097152 then
    raise exception 'invalid_workspace_operation' using errcode = '22023';
  end if;
  insert into public.workspace_operations(center_id,operation_id,action,payload,created_by)
    values(p_center_id,p_operation_id,trim(p_action),p_payload,auth.uid())
    on conflict(center_id,operation_id) do nothing;
  if not exists (
    select 1 from public.workspace_operations o where o.center_id=p_center_id
      and o.operation_id=p_operation_id and o.action=trim(p_action) and o.payload=p_payload
  ) then
    raise exception 'operation_id_conflict' using errcode = '23505';
  end if;
end;
$$;
revoke all on function public.push_workspace_operation(uuid,text,text,jsonb)
  from public, anon, authenticated;
grant execute on function public.push_workspace_operation(uuid,text,text,jsonb) to authenticated;
