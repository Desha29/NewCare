create or replace function public.pull_workspace_operations(
  p_center_id uuid, p_after_sequence bigint
) returns table(sequence bigint, operation_id text, action text, payload jsonb)
language plpgsql security definer set search_path = ''
as $$
begin
  if not private.is_device(p_center_id) then
    raise exception 'device_not_enrolled' using errcode = '42501';
  end if;
  if p_after_sequence is null or p_after_sequence < 0 then
    raise exception 'invalid_sync_cursor' using errcode = '22023';
  end if;
  return query
    select o.sequence, o.operation_id, o.action, o.payload
    from public.workspace_operations o
    where o.center_id = p_center_id and o.sequence > p_after_sequence
    order by o.sequence limit 500;
end;
$$;
revoke all on function public.pull_workspace_operations(uuid,bigint) from public, anon, authenticated;
grant execute on function public.pull_workspace_operations(uuid,bigint) to authenticated;
