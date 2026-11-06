create table if not exists public.workspace_operations (
  sequence bigint generated always as identity unique,
  center_id uuid not null references public.centers(id),
  operation_id text not null,
  action text not null check (length(trim(action)) between 1 and 120),
  payload jsonb not null,
  created_at timestamptz not null default now(),
  created_by uuid not null references auth.users(id),
  primary key (center_id, operation_id)
);

alter table public.workspace_operations enable row level security;
revoke all on public.workspace_operations from anon, authenticated;

create or replace function public.push_workspace_operation(
  p_center_id uuid,
  p_operation_id text,
  p_action text,
  p_payload jsonb
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_device(p_center_id) then
    raise exception 'device_not_enrolled' using errcode = '42501';
  end if;
  insert into public.workspace_operations(
    center_id, operation_id, action, payload, created_by
  )
  values (
    p_center_id, p_operation_id, trim(p_action), p_payload, auth.uid()
  )
  on conflict (center_id, operation_id) do nothing;
end;
$$;

revoke all on function public.push_workspace_operation(uuid,text,text,jsonb)
  from public, anon, authenticated;
grant execute on function public.push_workspace_operation(uuid,text,text,jsonb)
  to authenticated;

create or replace function public.pull_workspace_operations(
  p_center_id uuid,
  p_after_sequence bigint
) returns table(sequence bigint, operation_id text, action text, payload jsonb)
language sql
security definer
set search_path = ''
as $$
  select o.sequence, o.operation_id, o.action, o.payload
  from public.workspace_operations o
  where o.center_id = p_center_id
    and o.sequence > p_after_sequence
    and private.is_device(p_center_id)
  order by o.sequence
  limit 500;
$$;

revoke all on function public.pull_workspace_operations(uuid,bigint)
  from public, anon, authenticated;
grant execute on function public.pull_workspace_operations(uuid,bigint)
  to authenticated;
