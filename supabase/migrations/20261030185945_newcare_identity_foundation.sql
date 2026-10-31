-- Username login is resolved only by an enrolled center device or manager.
-- Supabase Auth still owns password hashing, verification and recovery.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table public.centers (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 120),
  revision bigint not null default 0 check (revision >= 0),
  created_at timestamptz not null default now()
);

create table public.manager_profiles (
  user_id uuid primary key references auth.users(id),
  username text not null unique check (username ~ '^[a-z0-9_]{3,32}$'),
  display_name text not null check (length(trim(display_name)) between 1 and 120),
  created_at timestamptz not null default now()
);

create table public.center_managers (
  center_id uuid not null references public.centers(id),
  user_id uuid not null references public.manager_profiles(user_id),
  active boolean not null default true,
  can_manage_accounts boolean not null default false,
  can_view_diagnostics boolean not null default false,
  primary key (center_id, user_id)
);
create index center_managers_user_idx on public.center_managers(user_id, center_id) where active;

create table public.center_devices (
  auth_user_id uuid primary key references auth.users(id),
  center_id uuid not null references public.centers(id),
  name text not null check (length(trim(name)) between 1 and 120),
  active boolean not null default true,
  enrolled_by uuid not null references auth.users(id),
  enrolled_at timestamptz not null default now()
);
create index center_devices_center_idx on public.center_devices(center_id);
create index center_devices_enrolled_by_idx on public.center_devices(enrolled_by);

-- Public nursing projections never contain manager email or payroll figures.
create table public.nursing_staff (
  center_id uuid not null references public.centers(id),
  id text not null check (length(id) between 1 and 80),
  name text not null check (length(trim(name)) between 1 and 120),
  phone text not null default '',
  manager_user_id uuid references public.manager_profiles(user_id),
  active boolean not null default true,
  version bigint not null default 1 check (version > 0),
  primary key (center_id, id)
);
create index nursing_staff_manager_idx on public.nursing_staff(manager_user_id);

create table public.nursing_payroll (
  center_id uuid not null,
  staff_id text not null,
  salary_minor bigint not null default 0 check (salary_minor >= 0),
  primary key (center_id, staff_id),
  foreign key (center_id, staff_id) references public.nursing_staff(center_id, id)
);

create table public.procedures (
  center_id uuid not null references public.centers(id),
  id text not null check (length(id) between 1 and 80),
  name text not null check (length(trim(name)) between 1 and 120),
  active boolean not null default true,
  version bigint not null default 1 check (version > 0),
  primary key (center_id, id)
);

create table private.manager_invitations (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id),
  email text not null,
  username text not null check (username ~ '^[a-z0-9_]{3,32}$'),
  display_name text not null check (length(trim(display_name)) between 1 and 120),
  token_hash bytea not null unique,
  invited_by uuid not null references auth.users(id),
  expires_at timestamptz not null,
  consumed_by uuid references auth.users(id),
  consumed_at timestamptz,
  unique(center_id, username)
);
create index manager_invitations_invited_by_idx on private.manager_invitations(invited_by);
create index manager_invitations_consumed_by_idx on private.manager_invitations(consumed_by);

create function private.is_manager(target uuid, permission text default null)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.center_managers m join auth.users u on u.id = m.user_id
    where m.center_id = target and m.user_id = (select auth.uid()) and m.active
      and u.email_confirmed_at is not null and not coalesce(u.is_anonymous, false)
      and (permission is null
        or (permission = 'accounts' and m.can_manage_accounts)
        or (permission = 'diagnostics' and m.can_view_diagnostics))
  );
$$;

create function private.is_device(target uuid)
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.center_devices d
    where d.center_id = target and d.auth_user_id = (select auth.uid()) and d.active);
$$;

grant usage on schema private to authenticated;
revoke all on function private.is_manager(uuid,text), private.is_device(uuid) from public, anon;
grant execute on function private.is_manager(uuid,text), private.is_device(uuid) to authenticated;

alter table public.centers enable row level security;
alter table public.manager_profiles enable row level security;
alter table public.center_managers enable row level security;
alter table public.center_devices enable row level security;
alter table public.nursing_staff enable row level security;
alter table public.nursing_payroll enable row level security;
alter table public.procedures enable row level security;
alter table private.manager_invitations enable row level security;

revoke all on public.centers, public.manager_profiles, public.center_managers,
  public.center_devices, public.nursing_staff, public.nursing_payroll,
  public.procedures from anon, authenticated;
grant select on public.centers, public.manager_profiles, public.center_managers,
  public.center_devices, public.nursing_staff, public.nursing_payroll,
  public.procedures to authenticated;

create policy centers_read on public.centers for select to authenticated
using (private.is_manager(id));
create policy managers_own_profile on public.manager_profiles for select to authenticated
using (user_id = (select auth.uid()));
create policy memberships_read on public.center_managers for select to authenticated
using (private.is_manager(center_id));
create policy devices_read on public.center_devices for select to authenticated
using (auth_user_id = (select auth.uid()) or private.is_manager(center_id));
create policy nursing_read on public.nursing_staff for select to authenticated
using (private.is_manager(center_id) or private.is_device(center_id));
create policy payroll_read on public.nursing_payroll for select to authenticated
using (private.is_manager(center_id));
create policy procedures_read on public.procedures for select to authenticated
using (private.is_manager(center_id) or private.is_device(center_id));

create function public.bootstrap_center(
  p_center_name text, p_username text, p_display_name text,
  p_device_user_id uuid, p_device_name text
) returns uuid language plpgsql security definer set search_path = ''
as $$
declare
  actor uuid := auth.uid();
  center uuid;
begin
  if actor is null or not exists(select 1 from auth.users u where u.id = actor
    and u.email_confirmed_at is not null and not coalesce(u.is_anonymous,false)) then
    raise exception 'manager_verification_required' using errcode = '42501';
  end if;
  -- Serializes retries and prevents a second center on a duplicated response.
  perform 1 from auth.users where id = actor for update;
  if exists(select 1 from public.manager_profiles where user_id = actor) then
    raise exception 'already_configured' using errcode = '23505';
  end if;
  if not exists(select 1 from auth.users where id = p_device_user_id and is_anonymous)
    or exists(select 1 from public.center_devices where auth_user_id = p_device_user_id) then
    raise exception 'invalid_device' using errcode = '42501';
  end if;
  insert into public.manager_profiles(user_id,username,display_name)
    values(actor,lower(trim(p_username)),trim(p_display_name));
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

create function public.resolve_manager_login(p_center_id uuid, p_username text)
returns text language plpgsql stable security definer set search_path = ''
as $$
declare address text;
begin
  if not (private.is_device(p_center_id) or private.is_manager(p_center_id)) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select u.email into address from public.manager_profiles p
    join public.center_managers m on m.user_id=p.user_id
    join auth.users u on u.id=p.user_id
    where m.center_id=p_center_id and m.active
      and p.username=lower(trim(p_username)) and u.email_confirmed_at is not null;
  -- No public username-to-email endpoint. The enrolled device learns only the
  -- selected manager's Auth address, transiently, for password sign-in.
  return address;
end;
$$;

create function public.create_manager_invitation(
  p_center_id uuid, p_username text, p_display_name text, p_email text
) returns text language plpgsql security definer set search_path = ''
as $$
declare token text;
begin
  if not private.is_manager(p_center_id,'accounts') then
    raise exception 'forbidden' using errcode='42501';
  end if;
  if length(trim(p_email)) > 254 or trim(p_email) !~ '^[^ @]+@[^ @]+\.[^ @]+$' then
    raise exception 'invalid_email' using errcode='22023';
  end if;
  if exists(select 1 from public.manager_profiles where username=lower(trim(p_username))) then
    raise exception 'username_taken' using errcode='23505';
  end if;
  token := replace(gen_random_uuid()::text,'-','') || replace(gen_random_uuid()::text,'-','');
  insert into private.manager_invitations(center_id,email,username,display_name,token_hash,invited_by,expires_at)
    values(p_center_id,lower(trim(p_email)),lower(trim(p_username)),trim(p_display_name),
      sha256(convert_to(token,'UTF8')),auth.uid(),now()+interval '24 hours');
  return token;
end;
$$;

create function private.bind_invited_manager()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare invite private.manager_invitations;
declare token text := new.raw_user_meta_data->>'newcare_invitation';
begin
  -- Uninvited signups get no role. Client metadata never supplies permissions.
  if token is null then return new; end if;
  select * into invite from private.manager_invitations
    where token_hash=sha256(convert_to(token,'UTF8')) and consumed_by is null
      and expires_at > now() and email=lower(new.email) for update;
  if not found or not exists(select 1 from public.center_managers m
    where m.center_id=invite.center_id and m.user_id=invite.invited_by
      and m.active and m.can_manage_accounts) then
    raise exception 'invalid_invitation' using errcode='42501';
  end if;
  insert into public.manager_profiles(user_id,username,display_name)
    values(new.id,invite.username,invite.display_name);
  insert into public.center_managers(center_id,user_id)
    values(invite.center_id,new.id);
  insert into public.nursing_staff(center_id,id,name,manager_user_id)
    values(invite.center_id,new.id::text,invite.display_name,new.id);
  insert into public.nursing_payroll(center_id,staff_id)
    values(invite.center_id,new.id::text);
  update private.manager_invitations set consumed_by=new.id,consumed_at=now() where id=invite.id;
  return new;
end;
$$;
create trigger newcare_bind_invitation after insert on auth.users
for each row execute function private.bind_invited_manager();

create function public.update_my_manager_name(p_display_name text)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if not exists(select 1 from public.center_managers m
    where m.user_id=auth.uid() and private.is_manager(m.center_id)) then
    raise exception 'forbidden' using errcode='42501';
  end if;
  update public.manager_profiles set display_name=trim(p_display_name) where user_id=auth.uid();
  update public.nursing_staff set name=trim(p_display_name),version=version+1
    where manager_user_id=auth.uid();
end;
$$;

revoke all on function public.bootstrap_center(text,text,text,uuid,text),
 public.resolve_manager_login(uuid,text), public.create_manager_invitation(uuid,text,text,text),
 public.update_my_manager_name(text), private.bind_invited_manager() from public, anon;
grant execute on function public.bootstrap_center(text,text,text,uuid,text),
 public.resolve_manager_login(uuid,text), public.create_manager_invitation(uuid,text,text,text),
 public.update_my_manager_name(text) to authenticated;

comment on function public.resolve_manager_login(uuid,text) is
 'Enrolled-device-only username resolution. Never expose to anon or log returned email.';
