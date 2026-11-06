-- Approved paper catalogue: names only. No prices and no invented stock.
create table private.catalogue_seed (
  id text primary key,
  kind text not null check (kind in ('procedure','stock')),
  name text not null check (length(trim(name)) > 0),
  unique(kind,name)
);
alter table private.catalogue_seed enable row level security;
revoke all on private.catalogue_seed from public, anon, authenticated;
insert into private.catalogue_seed(id,kind,name) values
('newcare-procedure-01','procedure','تركيب كانيولا كبار'),
('newcare-procedure-02','procedure','متابعة كبار + زيارة'),
('newcare-procedure-03','procedure','غيار'),
('newcare-procedure-04','procedure','اختبار حساسية'),
('newcare-procedure-05','procedure','قسطرة'),
('newcare-procedure-06','procedure','تعليق حديد'),
('newcare-procedure-07','procedure','تعليق دم'),
('newcare-procedure-08','procedure','قياس سكر'),
('newcare-procedure-09','procedure','جلسة'),
('newcare-procedure-10','procedure','خياطة'),
('newcare-procedure-11','procedure','قياس ضغط'),
('newcare-procedure-12','procedure','قياس ضغط وسكر'),
('newcare-procedure-13','procedure','غيار فاكيوم شامل الجهاز'),
('newcare-procedure-14','procedure','تركيب رايل'),
('newcare-procedure-15','procedure','حقنة شرجية'),
('newcare-procedure-16','procedure','غسول أنف'),
('newcare-procedure-17','procedure','علاج طبيعي على الصدر'),
('newcare-procedure-18','procedure','تشفيط'),
('newcare-procedure-19','procedure','متابعة أطفال'),
('newcare-procedure-20','procedure','تركيب كانيولا أطفال'),
('newcare-stock-01','stock','سرنجات 1 / 3 / 5'),
('newcare-stock-02','stock','كانيولا'),
('newcare-stock-03','stock','ماسك جلسات'),
('newcare-stock-04','stock','ماسك أكسجين'),
('newcare-stock-05','stock','جهاز وريد'),
('newcare-stock-06','stock','جهاز نقل دم'),
('newcare-stock-07','stock','كيس جمع بول'),
('newcare-stock-08','stock','نيزل مقاسات'),
('newcare-stock-09','stock','رباط شاش مقاسات'),
('newcare-stock-10','stock','رباط ضغط'),
('newcare-stock-11','stock','سرنجة 20 سم'),
('newcare-stock-12','stock','محاليل بأنواعها'),
('newcare-stock-13','stock','محلول ديامنت'),
('newcare-stock-14','stock','محلول بانثول'),
('newcare-stock-15','stock','سرنجة رايل');

create function private.seed_new_center_catalogue()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare actor uuid := auth.uid();
declare procedures jsonb;
declare stock jsonb;
begin
  if actor is null then return new; end if;
  select jsonb_agg(jsonb_build_object('id',s.id,'ar',s.name,'en',s.name,'active',true) order by s.id)
    into procedures from private.catalogue_seed s where s.kind='procedure';
  select jsonb_agg(jsonb_build_object('id',s.id,'name',s.name,'quantity',0,'active',true,'version',1) order by s.id)
    into stock from private.catalogue_seed s where s.kind='stock';
  insert into public.workspace_operations(center_id,operation_id,action,payload,created_by)
    values(new.id,'newcare.catalogue.v1','catalogueSeeded',jsonb_build_object(
      'version',1,'settings','{}'::jsonb,'collections',jsonb_build_object(
        'procedures',jsonb_build_object('upsert',procedures,'remove','[]'::jsonb),
        'stockItems',jsonb_build_object('upsert',stock,'remove','[]'::jsonb)
      )),actor);
  return new;
end;
$$;
revoke all on function private.seed_new_center_catalogue() from public, anon, authenticated;
create trigger seed_new_center_catalogue after insert on public.centers
for each row execute function private.seed_new_center_catalogue();
