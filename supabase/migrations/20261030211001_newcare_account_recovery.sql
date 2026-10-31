-- Retry-safe invitation provisioning and explicit enrollment for a replacement PC.
create or replace function public.create_manager_invitation(
  p_center_id uuid,p_username text,p_display_name text,p_email text
) returns text language plpgsql security definer set search_path = ''
as $$
declare token text;
declare invitation uuid;
begin
  if not private.is_manager(p_center_id,'accounts') then
    raise exception 'forbidden' using errcode='42501';
  end if;
  if length(trim(p_email))>254 or trim(p_email) !~ '^[^ @]+@[^ @]+\.[^ @]+$' then
    raise exception 'invalid_email' using errcode='22023';
  end if;
  if exists(select 1 from public.manager_profiles where username=lower(trim(p_username))) then
    raise exception 'username_taken' using errcode='23505';
  end if;
  token:=replace(gen_random_uuid()::text,'-','')||replace(gen_random_uuid()::text,'-','');
  insert into private.manager_invitations(center_id,email,username,display_name,
    token_hash,invited_by,expires_at)
    values(p_center_id,lower(trim(p_email)),lower(trim(p_username)),trim(p_display_name),
      sha256(convert_to(token,'UTF8')),auth.uid(),now()+interval '24 hours')
  on conflict(center_id,username) do update set
    email=excluded.email,display_name=excluded.display_name,token_hash=excluded.token_hash,
    invited_by=excluded.invited_by,expires_at=excluded.expires_at
    where manager_invitations.consumed_by is null
  returning id into invitation;
  if invitation is null then
    raise exception 'username_taken' using errcode='23505';
  end if;
  return token;
end;
$$;

create function public.enroll_center_device(p_center_id uuid,p_device_user_id uuid,p_name text)
returns void language plpgsql security definer set search_path = ''
as $$
declare enrolled uuid;
begin
  if not private.is_manager(p_center_id,'accounts') or not exists(
    select 1 from auth.users where id=p_device_user_id and is_anonymous) then
    raise exception 'forbidden' using errcode='42501';
  end if;
  insert into public.center_devices(auth_user_id,center_id,name,enrolled_by)
    values(p_device_user_id,p_center_id,trim(p_name),auth.uid())
  on conflict(auth_user_id) do update set active=true,name=excluded.name,
    enrolled_by=excluded.enrolled_by,enrolled_at=now()
    where center_devices.center_id=p_center_id
  returning auth_user_id into enrolled;
  if enrolled is null then raise exception 'forbidden' using errcode='42501'; end if;
end;
$$;
revoke all on function public.enroll_center_device(uuid,uuid,text) from public,anon;
grant execute on function public.enroll_center_device(uuid,uuid,text) to authenticated;

-- No client may read invitation tokens or bypass the provisioning functions.
create policy invitations_deny_all on private.manager_invitations as restrictive
for all to authenticated using(false) with check(false);
