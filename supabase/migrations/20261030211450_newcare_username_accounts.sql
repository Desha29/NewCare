-- Supabase Auth uses a stable internal address. Contact email is editable
-- profile data and never participates in sign-in or email confirmation.
alter table public.manager_profiles add column contact_email text not null default ''
  check (contact_email='' or (length(contact_email)<=254 and contact_email ~ '^[^ @]+@[^ @]+\.[^ @]+$'));

create function private.manager_auth_address(p_username text)
returns text language sql immutable set search_path=''
as $$ select lower(trim(p_username))||'@accounts.newcare.invalid'; $$;
revoke all on function private.manager_auth_address(text) from public,anon,authenticated;

drop function public.bootstrap_center(text,text,text,uuid,text);
create function public.bootstrap_center(
  p_center_name text,p_username text,p_display_name text,p_contact_email text,
  p_device_user_id uuid,p_device_name text
) returns uuid language plpgsql security definer set search_path=''
as $$
declare actor uuid:=auth.uid();
declare center uuid;
begin
  if actor is null or not exists(select 1 from auth.users u where u.id=actor
    and u.email_confirmed_at is not null and not coalesce(u.is_anonymous,false)
    and lower(u.email)=private.manager_auth_address(p_username)) then
    raise exception 'manager_auth_required' using errcode='42501';
  end if;
  perform 1 from auth.users where id=actor for update;
  if exists(select 1 from public.manager_profiles where user_id=actor) then
    raise exception 'already_configured' using errcode='23505';
  end if;
  if not exists(select 1 from auth.users where id=p_device_user_id and is_anonymous)
    or exists(select 1 from public.center_devices where auth_user_id=p_device_user_id) then
    raise exception 'invalid_device' using errcode='42501';
  end if;
  insert into public.manager_profiles(user_id,username,display_name,contact_email)
    values(actor,lower(trim(p_username)),trim(p_display_name),trim(p_contact_email));
  insert into public.centers(name) values(trim(p_center_name)) returning id into center;
  insert into public.center_managers(center_id,user_id,can_manage_accounts,can_view_diagnostics)
    values(center,actor,true,true);
  insert into public.center_devices(auth_user_id,center_id,name,enrolled_by)
    values(p_device_user_id,center,trim(p_device_name),actor);
  insert into public.nursing_staff(center_id,id,name,manager_user_id)
    values(center,actor::text,trim(p_display_name),actor);
  insert into public.nursing_payroll(center_id,staff_id) values(center,actor::text);
  return center;
end;
$$;
revoke all on function public.bootstrap_center(text,text,text,text,uuid,text) from public,anon;
grant execute on function public.bootstrap_center(text,text,text,text,uuid,text) to authenticated;

create or replace function private.bind_invited_manager()
returns trigger language plpgsql security definer set search_path=''
as $$
declare invite private.manager_invitations;
declare token text:=new.raw_user_meta_data->>'newcare_invitation';
begin
  if token is null then return new; end if;
  select * into invite from private.manager_invitations
    where token_hash=sha256(convert_to(token,'UTF8')) and consumed_by is null
      and expires_at>now() and private.manager_auth_address(username)=lower(new.email)
    for update;
  if not found or not exists(select 1 from public.center_managers m
    where m.center_id=invite.center_id and m.user_id=invite.invited_by
      and m.active and m.can_manage_accounts) then
    raise exception 'invalid_invitation' using errcode='42501';
  end if;
  insert into public.manager_profiles(user_id,username,display_name,contact_email)
    values(new.id,invite.username,invite.display_name,invite.email);
  insert into public.center_managers(center_id,user_id) values(invite.center_id,new.id);
  insert into public.nursing_staff(center_id,id,name,manager_user_id)
    values(invite.center_id,new.id::text,invite.display_name,new.id);
  insert into public.nursing_payroll(center_id,staff_id) values(invite.center_id,new.id::text);
  update private.manager_invitations set consumed_by=new.id,consumed_at=now() where id=invite.id;
  return new;
end;
$$;

create function public.update_my_manager_contact_email(p_email text)
returns void language plpgsql security definer set search_path=''
as $$
begin
  if not exists(select 1 from public.center_managers m
    where m.user_id=auth.uid() and private.is_manager(m.center_id)) then
    raise exception 'forbidden' using errcode='42501';
  end if;
  update public.manager_profiles set contact_email=trim(p_email) where user_id=auth.uid();
end;
$$;
revoke all on function public.update_my_manager_contact_email(text) from public,anon;
grant execute on function public.update_my_manager_contact_email(text) to authenticated;
