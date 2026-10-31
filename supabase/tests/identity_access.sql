-- Run against the migrated project with a trusted development SQL connection.
-- No accounts or medical records are created. All state is rolled back.
begin;
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"1410ceef-ea75-401f-bafa-465cbb6bd706","role":"authenticated"}',true);
do $$
begin
  if exists(select 1 from public.centers) or exists(select 1 from public.nursing_payroll) then
    raise exception 'RLS isolation failed';
  end if;
  begin
    perform public.resolve_manager_login('1410ceef-ea75-401f-bafa-465cbb6bd706','unknown');
    raise exception 'Unenrolled username lookup was allowed';
  exception when insufficient_privilege then null;
  end;
  begin
    perform public.create_manager_invitation('1410ceef-ea75-401f-bafa-465cbb6bd706',
      'fake','Fake','fake@example.invalid');
    raise exception 'Unauthorized manager creation was allowed';
  exception when insufficient_privilege then null;
  end;
  begin
    perform public.enroll_center_device('1410ceef-ea75-401f-bafa-465cbb6bd706',
      '1410ceef-ea75-401f-bafa-465cbb6bd706','Fake');
    raise exception 'Unauthorized device enrollment was allowed';
  exception when insufficient_privilege then null;
  end;
  begin
    perform public.update_my_manager_contact_email('fake@example.invalid');
    raise exception 'Unauthorized profile edit was allowed';
  exception when insufficient_privilege then null;
  end;
end;
$$;
rollback;
