-- โรงเรียนสามัคคีศรีวิชัย — run in a NEW Supabase project.
begin;
create extension if not exists pgcrypto;
create table public.school_profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null default '',
 role text not null default 'pending' check (role in ('pending','admin','director','teacher','academic_head','plan_head','finance','admin_sec')),
 homeroom text not null default '', active boolean not null default true,
 created_at timestamptz not null default now()
);
create table public.school_modules (key text primary key, title text not null, group_name text not null);
create table public.school_records (
 id uuid primary key default gen_random_uuid(), record_type text not null references public.school_modules(key),
 academic_year text not null default '2569', class_id text not null default '',
 data jsonb not null default '{}' check (jsonb_typeof(data) = 'object'),
 created_by uuid not null default auth.uid() references auth.users(id),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 version integer not null default 1
);
create index school_records_type_year on public.school_records(record_type,academic_year);
create index school_records_scope on public.school_records(class_id,created_by);
create unique index school_student_id on public.school_records ((data->>'student_id')) where record_type='Students';
create unique index school_teacher_id on public.school_records ((data->>'teacher_id')) where record_type='Teachers';
create unique index school_attendance_day on public.school_records (academic_year,class_id,(data->>'date')) where record_type='Attendance';
create unique index school_saving_ref on public.school_records ((data->>'request_id')) where record_type='ProjExpenses';
create table public.school_audit (
 id bigint generated always as identity primary key, actor uuid references auth.users(id) on delete set null,
 action text not null, record_type text, record_id uuid, created_at timestamptz not null default now()
);
create table public.school_settings (id boolean primary key default true check(id), academic_year text not null default '2569', school_name text not null default 'โรงเรียนสามัคคีศรีวิชัย', director_name text not null default '');
insert into public.school_settings default values;
insert into public.school_modules(key,title,group_name) values
('Students','ทะเบียนนักเรียน','ข้อมูลพื้นฐาน'),
('Teachers','ทะเบียนครูและบุคลากร','ข้อมูลพื้นฐาน'),
('Classrooms','ห้องเรียน','ข้อมูลพื้นฐาน'),
('Events','ปฏิทินปฏิบัติงาน','ข้อมูลพื้นฐาน'),
('Subjects','รายวิชา','งานวิชาการ'),
('Assignments','มอบหมายการสอน','งานวิชาการ'),
('Timetable','ตารางเรียน / ตารางสอน','งานวิชาการ'),
('Substitute','สอนแทน','งานวิชาการ'),
('ScoreStruct','โครงสร้างคะแนน','งานวิชาการ'),
('Scores','บันทึกผลการเรียน','งานวิชาการ'),
('Competency','สมรรถนะและคุณลักษณะ','งานวิชาการ'),
('StudentAnalysis','วิเคราะห์ผู้เรียน','งานวิชาการ'),
('LessonPlan','แผนการจัดการเรียนรู้','งานวิชาการ'),
('Supervision','นิเทศการสอน','งานวิชาการ'),
('SARContent','รายงาน SAR','งานวิชาการ'),
('Attendance','เช็กชื่อนักเรียน','ดูแลช่วยเหลือนักเรียน'),
('SDQ','ประเมิน SDQ','ดูแลช่วยเหลือนักเรียน'),
('LD','คัดกรอง LD','ดูแลช่วยเหลือนักเรียน'),
('EQAssessment','ประเมิน EQ','ดูแลช่วยเหลือนักเรียน'),
('Fitness','สมรรถภาพทางกาย','ดูแลช่วยเหลือนักเรียน'),
('DailyCheck','บันทึกกิจกรรมประจำวัน','ดูแลช่วยเหลือนักเรียน'),
('HealthCheck','ตรวจสุขภาพ','ดูแลช่วยเหลือนักเรียน'),
('GrowthRecord','การเจริญเติบโต','ดูแลช่วยเหลือนักเรียน'),
('Conduct','บันทึกพฤติกรรม','ดูแลช่วยเหลือนักเรียน'),
('Savings','เงินออมนักเรียน','ดูแลช่วยเหลือนักเรียน'),
('TeacherProfile','ประวัติบุคลากร','งานบุคลากร'),
('Trainings','พัฒนาตนเอง / อบรม','งานบุคลากร'),
('Leaves','การลา','งานบุคลากร'),
('PLCGroups','กลุ่ม PLC','งานบุคลากร'),
('PLCReports','รายงาน PLC','งานบุคลากร'),
('Projects','แผนงานและโครงการ','แผนงานและงบประมาณ'),
('ProjActivities','กิจกรรมโครงการ','แผนงานและงบประมาณ'),
('ProjRequests','คำขอเบิกจ่าย','แผนงานและงบประมาณ'),
('ProjExpenses','ทะเบียนการจ่ายเงิน','แผนงานและงบประมาณ'),
('PurchaseRequests','คำขอจัดซื้อ','งานพัสดุและจัดซื้อ'),
('PurchaseOrders','ใบสั่งซื้อ','งานพัสดุและจัดซื้อ'),
('ReceivingReports','ตรวจรับพัสดุ','งานพัสดุและจัดซื้อ'),
('Assets','ทะเบียนครุภัณฑ์','งานพัสดุและจัดซื้อ'),
('AssetAudits','ตรวจสอบพัสดุประจำปี','งานพัสดุและจัดซื้อ'),
('AssetAuditItems','ผลตรวจสอบครุภัณฑ์','งานพัสดุและจัดซื้อ'),
('AssetDisposals','จำหน่ายครุภัณฑ์','งานพัสดุและจัดซื้อ'),
('AssetLoans','ยืมคืนครุภัณฑ์','งานพัสดุและจัดซื้อ'),
('Supplies','ทะเบียนวัสดุ','งานพัสดุและจัดซื้อ'),
('SupplyLots','ล็อตวัสดุ','งานพัสดุและจัดซื้อ'),
('SupplyTransactions','รับจ่ายวัสดุ','งานพัสดุและจัดซื้อ'),
('Documents','หนังสือรับ / ส่ง','งานทั่วไป'),
('DocRecipients','รับทราบหนังสือ','งานทั่วไป'),
('Books','ทะเบียนหนังสือ','งานทั่วไป'),
('BookLoans','ยืมคืนหนังสือ','งานทั่วไป');
create function public.school_create_profile() returns trigger language plpgsql security definer set search_path=public,pg_temp as $$
begin insert into public.school_profiles(id,display_name) values(new.id,coalesce(new.raw_user_meta_data->>'display_name','')) on conflict do nothing; return new; end $$;
create trigger school_auth_user after insert on auth.users for each row execute function public.school_create_profile();
insert into public.school_profiles(id,display_name) select id,coalesce(raw_user_meta_data->>'display_name',email,'') from auth.users on conflict do nothing;
create function public.school_role() returns text language sql stable security definer set search_path=public,pg_temp as $$ select role from public.school_profiles where id=auth.uid() and active $$;
create function public.school_homeroom() returns text language sql stable security definer set search_path=public,pg_temp as $$ select homeroom from public.school_profiles where id=auth.uid() and active $$;
create function public.school_can_read(kind text, owner_id uuid, room text) returns boolean language plpgsql stable security definer set search_path=public,pg_temp as $$
declare r text:=public.school_role();
begin
 if r is null or r='pending' then return false; end if;
 if r in ('admin','director') then return true; end if;
 if kind in ('Projects','ProjActivities','Events','Subjects','Assignments','Timetable','Books','Assets') then return true; end if;
 if kind in ('ProjExpenses','ProjRequests') then return r in ('finance','plan_head') or owner_id=auth.uid(); end if;
 if kind in ('Students','Attendance','Scores','ScoreStruct','Competency','StudentAnalysis','SDQ','LD','EQAssessment','Fitness','DailyCheck','HealthCheck','GrowthRecord','Conduct','Savings') then return r='academic_head' or (r='teacher' and room<>'' and room=public.school_homeroom()); end if;
 if kind in ('Teachers','Classrooms') then return r in ('academic_head','admin_sec'); end if;
 if kind in ('BookLoans','AssetLoans') then return owner_id=auth.uid() or r in ('admin_sec','finance'); end if;
 if kind in ('PurchaseRequests','PurchaseOrders','ReceivingReports','AssetAudits','AssetAuditItems','AssetDisposals','AssetLoans','Supplies','SupplyLots','SupplyTransactions') then return r in ('finance','admin_sec'); end if;
 if kind in ('LessonPlan','Supervision','SARContent') then return r='academic_head' or owner_id=auth.uid(); end if;
 if kind in ('Documents','DocRecipients') then return r='admin_sec' or owner_id=auth.uid(); end if;
 return owner_id=auth.uid();
end $$;
create function public.school_can_write(kind text, owner_id uuid, room text) returns boolean language plpgsql stable security definer set search_path=public,pg_temp as $$
declare r text:=public.school_role();
begin
 if kind in ('ProjExpenses','ProjRequests','Savings','SupplyLots','SupplyTransactions','BookLoans','AssetLoans') then return false; end if;
 if r in ('admin','director') then return true; end if;
 if r is null or r='pending' then return false; end if;
 if kind in ('Projects','ProjActivities') then return r='plan_head'; end if;
 if kind in ('Teachers','Classrooms','Events','Documents','DocRecipients','Books') then return r='admin_sec'; end if;
 if kind in ('Subjects','Assignments','Timetable','Supervision','SARContent') then return r='academic_head'; end if;
 if kind in ('PurchaseRequests','PurchaseOrders','ReceivingReports','Assets','AssetAudits','AssetAuditItems','AssetDisposals','Supplies') then return r in ('finance','admin_sec'); end if;
 if kind in ('Students','Attendance','Scores','ScoreStruct','Competency','StudentAnalysis','SDQ','LD','EQAssessment','Fitness','DailyCheck','HealthCheck','GrowthRecord','Conduct') then return r='academic_head' or (r='teacher' and room<>'' and room=public.school_homeroom()); end if;
 return owner_id=auth.uid();
end $$;
create function public.school_record_guard() returns trigger language plpgsql set search_path=public,pg_temp as $$
declare spent numeric;
begin
 if tg_op='UPDATE' then
  if new.record_type<>old.record_type or new.created_by<>old.created_by or new.created_at<>old.created_at then raise exception 'Cannot change record identity'; end if;
  new.version:=old.version+1;
 end if;
 new.updated_at:=now();
 new.academic_year:=coalesce(nullif(new.data->>'academic_year',''),new.academic_year);
 new.class_id:=coalesce(nullif(new.data->>'class_id',''),case when coalesce(new.data->>'class_level','')<>'' then (new.data->>'class_level')||'/'||coalesce(nullif(new.data->>'room',''),'1') end,new.class_id,'');
 if new.academic_year !~ '^[0-9]{4}$' then raise exception 'Academic year must be four digits'; end if;
 if octet_length(new.data::text)>1000000 then raise exception 'Record too large'; end if;
 if new.record_type='Scores' then
  if nullif(new.data->>'total','') is null or (new.data->>'total')::numeric<0 or (new.data->>'total')::numeric>100 then raise exception 'Score must be between 0 and 100'; end if;
  new.data:=new.data||jsonb_build_object('grade',case when (new.data->>'total')::numeric>=80 then '4' when (new.data->>'total')::numeric>=75 then '3.5' when (new.data->>'total')::numeric>=70 then '3' when (new.data->>'total')::numeric>=65 then '2.5' when (new.data->>'total')::numeric>=60 then '2' when (new.data->>'total')::numeric>=55 then '1.5' when (new.data->>'total')::numeric>=50 then '1' else '0' end);
 end if;
 if new.record_type='Attendance' then
  if nullif(new.data->>'date','') is null or new.class_id='' then raise exception 'Date and classroom required'; end if;
  if coalesce((new.data->>'total')::integer,0)<>coalesce((new.data->>'present')::integer,0)+coalesce((new.data->>'late')::integer,0)+coalesce((new.data->>'leave')::integer,0)+coalesce((new.data->>'absent')::integer,0) then raise exception 'Attendance count mismatch'; end if;
  if least(coalesce((new.data->>'present')::integer,0),coalesce((new.data->>'late')::integer,0),coalesce((new.data->>'leave')::integer,0),coalesce((new.data->>'absent')::integer,0))<0 then raise exception 'Attendance cannot be negative'; end if;
 end if;
 if new.record_type='Students' and (coalesce(new.data->>'student_id','')='' or coalesce(new.data->>'first_name','')='') then raise exception 'Student code and name are required'; end if;
 if new.record_type='Teachers' and (coalesce(new.data->>'teacher_id','')='' or coalesce(new.data->>'first_name','')='') then raise exception 'Teacher code and name are required'; end if;
 if new.record_type='Projects' then
  if coalesce((new.data->>'budget_alloc')::numeric,0)<0 or coalesce((new.data->>'budget_activity')::numeric,0)<0 then raise exception 'Budget cannot be negative'; end if;
  select coalesce(sum((data->>'amount')::numeric),0) into spent from public.school_records where record_type='ProjExpenses' and data->>'proj_id'=new.id::text;
  if coalesce((new.data->>'budget_alloc')::numeric,0)+coalesce((new.data->>'budget_activity')::numeric,0)<spent then raise exception 'Budget below actual expenditure'; end if;
 end if;
 return new;
end $$;
create trigger school_record_guard before insert or update on public.school_records for each row execute function public.school_record_guard();
create function public.school_log() returns trigger language plpgsql security definer set search_path=public,pg_temp as $$
begin insert into public.school_audit(actor,action,record_type,record_id) values(auth.uid(),tg_op,coalesce(new.record_type,old.record_type),coalesce(new.id,old.id)); return coalesce(new,old); end $$;
create trigger school_audit_record after insert or update or delete on public.school_records for each row execute function public.school_log();
alter table public.school_profiles enable row level security;
alter table public.school_records enable row level security;
alter table public.school_modules enable row level security;
alter table public.school_settings enable row level security;
alter table public.school_audit enable row level security;
create policy profile_read on public.school_profiles for select to authenticated using (id=auth.uid() or public.school_role() in ('admin','director'));
create policy modules_read on public.school_modules for select to authenticated using(public.school_role() is not null and public.school_role()<>'pending');
create policy settings_read on public.school_settings for select to authenticated using(public.school_role() is not null and public.school_role()<>'pending');
create policy settings_write on public.school_settings for update to authenticated using(public.school_role()='admin') with check(public.school_role()='admin');
create policy record_read on public.school_records for select to authenticated using(public.school_can_read(record_type,created_by,class_id));
create policy record_insert on public.school_records for insert to authenticated with check(created_by=auth.uid() and public.school_can_write(record_type,created_by,class_id));
create policy record_update on public.school_records for update to authenticated using(public.school_can_write(record_type,created_by,class_id)) with check(public.school_can_write(record_type,created_by,class_id));
create policy record_delete on public.school_records for delete to authenticated using(public.school_can_write(record_type,created_by,class_id) and record_type<>'Projects');
create policy audit_read on public.school_audit for select to authenticated using(public.school_role() in ('admin','director'));
-- Profile changes must use this function; ordinary users have no INSERT/UPDATE policy.
create function public.school_set_role(target uuid, new_role text, room text default '', enabled boolean default true) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 if public.school_role() is distinct from 'admin' or auth.uid()=target then raise exception 'Admin required; cannot change your own access'; end if;
 update public.school_profiles set role=new_role,homeroom=room,active=enabled where id=target;
 if not found then raise exception 'User not found'; end if;
 insert into public.school_audit(actor,action,record_type,record_id) values(auth.uid(),'ROLE_CHANGE','Profiles',target);
end $$;
-- Exact request/project amounts are checked inside the database, never trusted from the client.
create function public.school_submit_request(project_id uuid, description text, amount numeric, activity_id text default '') returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare p public.school_records; rid uuid; r text:=public.school_role();
begin
 if r is null or r='pending' then raise exception 'Active staff required'; end if;
 if amount<=0 or amount>1000000000 or length(trim(description))=0 then raise exception 'Invalid amount or description'; end if;
 select * into p from public.school_records where id=project_id and record_type='Projects';
 if not found or p.data->>'status'<>'อนุมัติ' then raise exception 'Project must be approved'; end if;
 insert into public.school_records(record_type,academic_year,created_by,data) values('ProjRequests',p.academic_year,auth.uid(),jsonb_build_object('proj_id',project_id,'proj_name',p.data->>'name','act_id',activity_id,'description',description,'amount_request',amount,'status','ยื่นแล้ว','requested_name',(select display_name from public.school_profiles where id=auth.uid()),'request_date',current_date)) returning id into rid;
 return rid;
end $$;
create function public.school_transition_request(request_id uuid, next_status text) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare q public.school_records; p public.school_records; r text:=public.school_role(); amount numeric; budget numeric; used numeric;
begin
 if r is null or r='pending' then raise exception 'Active staff required'; end if;
 select * into q from public.school_records where id=request_id and record_type='ProjRequests' for update;
 if not found then raise exception 'Request not found'; end if;
 if not ((q.data->>'status'='ยื่นแล้ว' and next_status='เสนอ ผอ.' and r in ('admin','plan_head')) or (q.data->>'status'='เสนอ ผอ.' and next_status in ('อนุมัติ','ปฏิเสธ') and r in ('admin','director')) or (q.data->>'status'='อนุมัติ' and next_status='จ่ายแล้ว' and r in ('admin','finance'))) then raise exception 'Invalid transition or permission denied'; end if;
 if next_status='จ่ายแล้ว' then
  select * into p from public.school_records where id=(q.data->>'proj_id')::uuid and record_type='Projects' for update;
  if not found or p.data->>'status'<>'อนุมัติ' then raise exception 'Project unavailable'; end if;
  amount:=(q.data->>'amount_request')::numeric;
  budget:=coalesce((p.data->>'budget_alloc')::numeric,0)+coalesce((p.data->>'budget_activity')::numeric,0);
  select coalesce(sum((data->>'amount')::numeric),0) into used from public.school_records where record_type='ProjExpenses' and data->>'proj_id'=p.id::text;
  if amount<=0 or amount>budget-used then raise exception 'Insufficient project balance'; end if;
  insert into public.school_records(record_type,academic_year,created_by,data) values('ProjExpenses',q.academic_year,auth.uid(),jsonb_build_object('request_id',q.id,'proj_id',p.id,'proj_name',p.data->>'name','description',q.data->>'description','amount',amount,'expense_date',current_date,'balance_before',budget-used,'balance_after',budget-used-amount));
 end if;
 update public.school_records set data=data||jsonb_build_object('status',next_status,'last_action_by',auth.uid(),'last_action_at',now()) where id=q.id;
end $$;
create function public.school_transition_project(project_id uuid, next_status text) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare p public.school_records; r text:=public.school_role();
begin
 select * into p from public.school_records where id=project_id and record_type='Projects' for update;
 if not found then raise exception 'Project not found'; end if;
 if not coalesce(((p.data->>'status'='ร่าง' and next_status='เสนอ ผอ.' and r in ('admin','plan_head')) or (p.data->>'status'='เสนอ ผอ.' and next_status in ('อนุมัติ','ไม่อนุมัติ') and r in ('admin','director')) or (p.data->>'status'='อนุมัติ' and next_status='เสร็จสิ้น' and r in ('admin','plan_head'))) ,false) then raise exception 'Invalid transition or permission denied'; end if;
 update public.school_records set data=data||jsonb_build_object('status',next_status) where id=p.id;
end $$;
-- Prevent project status changes through generic CRUD. Only definer workflows can change it.
create function public.school_project_status_guard() returns trigger language plpgsql set search_path=public,pg_temp as $$
begin
 if new.record_type='Projects' and current_user not in ('postgres','supabase_admin') then
  if tg_op='INSERT' then new.data:=new.data||'{"status":"ร่าง"}'::jsonb;
  elsif (new.data->>'status') is distinct from (old.data->>'status') then raise exception 'Use project approval workflow'; end if;
 end if;
 return new;
end $$;
create trigger school_project_status before insert or update on public.school_records for each row execute function public.school_project_status_guard();
-- Atomic savings ledger. No generic write policy; no negative balances or duplicate payment.
create function public.school_savings(student_record_id uuid, txn_type text, amount numeric, memo text default '') returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare s public.school_records; balance numeric; rid uuid;
begin
 select * into s from public.school_records where id=student_record_id and record_type='Students' for update;
 if not found or not public.school_can_write('Students',s.created_by,s.class_id) then raise exception 'Student permission denied'; end if;
 if txn_type not in ('ฝาก','ถอน') or amount<=0 or amount>1000000000 then raise exception 'Invalid transaction'; end if;
 select coalesce(sum(case when data->>'txn_type'='ฝาก' then (data->>'amount')::numeric else -(data->>'amount')::numeric end),0) into balance from public.school_records where record_type='Savings' and data->>'student_id'=s.data->>'student_id';
 balance:=balance+case when txn_type='ฝาก' then amount else -amount end;
 if balance<0 then raise exception 'Insufficient savings balance'; end if;
 insert into public.school_records(record_type,academic_year,class_id,created_by,data) values('Savings',s.academic_year,s.class_id,auth.uid(),jsonb_build_object('student_id',s.data->>'student_id','student_name',coalesce(s.data->>'first_name','')||' '||coalesce(s.data->>'last_name',''),'class_id',s.class_id,'txn_type',txn_type,'amount',amount,'balance_after',balance,'txn_date',current_date,'note',memo)) returning id into rid;
 return rid;
end $$;
-- Default function EXECUTE grants in PostgreSQL are broad; lock down all school functions.
revoke all on public.school_profiles, public.school_records, public.school_modules, public.school_settings, public.school_audit from anon;
grant select on public.school_profiles,public.school_modules,public.school_audit to authenticated;
grant select,insert,update,delete on public.school_records to authenticated;
grant select,update on public.school_settings to authenticated;
revoke all on function public.school_create_profile(),public.school_record_guard(),public.school_log(),public.school_project_status_guard() from public,anon,authenticated;
revoke all on function public.school_role(),public.school_homeroom(),public.school_can_read(text,uuid,text),public.school_can_write(text,uuid,text),public.school_set_role(uuid,text,text,boolean),public.school_submit_request(uuid,text,numeric,text),public.school_transition_request(uuid,text),public.school_transition_project(uuid,text),public.school_savings(uuid,text,numeric,text) from public,anon;
grant execute on function public.school_role(),public.school_homeroom(),public.school_can_read(text,uuid,text),public.school_can_write(text,uuid,text),public.school_set_role(uuid,text,text,boolean),public.school_submit_request(uuid,text,numeric,text),public.school_transition_request(uuid,text),public.school_transition_project(uuid,text),public.school_savings(uuid,text,numeric,text) to authenticated;
create function public.school_inventory_guard() returns trigger language plpgsql set search_path=public,pg_temp as $$
begin
 if current_user not in ('postgres','supabase_admin') then
  if new.record_type='Supplies' then
   if tg_op='INSERT' then new.data:=new.data||'{"current_stock":0}'::jsonb;
   elsif (new.data->>'current_stock') is distinct from (old.data->>'current_stock') then raise exception 'Use stock receive/issue workflow'; end if;
  end if;
  if new.record_type='Books' then
   if tg_op='INSERT' then new.data:=new.data||jsonb_build_object('copies_available',coalesce((new.data->>'copies_total')::integer,0));
   elsif (new.data->>'copies_available') is distinct from (old.data->>'copies_available') or (new.data->>'copies_total') is distinct from (old.data->>'copies_total') then raise exception 'Cannot change stock after creation'; end if;
  end if;
 end if;
 return new;
end $$;
create trigger school_inventory_guard before insert or update on public.school_records for each row execute function public.school_inventory_guard();
revoke all on function public.school_inventory_guard() from public,anon,authenticated;
create function public.school_supply(supply_id uuid, txn_type text, quantity numeric, price numeric default 0, memo text default '') returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare s public.school_records; l public.school_records; rid uuid; stock numeric; remaining numeric; take_qty numeric; cost numeric:=0;
begin
 if not coalesce(public.school_role() in ('admin','director','finance','admin_sec'),false) then raise exception 'Stock permission denied'; end if;
 if txn_type not in ('รับ','จ่าย') or quantity<=0 or quantity>1000000000 or price<0 then raise exception 'Invalid stock transaction'; end if;
 select * into s from public.school_records where id=supply_id and record_type='Supplies' for update;
 if not found then raise exception 'Supply not found'; end if;
 stock:=coalesce((s.data->>'current_stock')::numeric,0);
 if txn_type='จ่าย' and quantity>stock then raise exception 'Insufficient stock'; end if;
 if txn_type='รับ' then
  stock:=stock+quantity; cost:=quantity*price;
  insert into public.school_records(record_type,academic_year,created_by,data) values('SupplyLots',s.academic_year,auth.uid(),jsonb_build_object('supply_id',s.id,'qty_received',quantity,'qty_remaining',quantity,'unit_price',price,'received_date',current_date));
 else
  remaining:=quantity;
  for l in select * from public.school_records where record_type='SupplyLots' and data->>'supply_id'=s.id::text and (data->>'qty_remaining')::numeric>0 order by created_at,id for update loop
   take_qty:=least(remaining,(l.data->>'qty_remaining')::numeric);cost:=cost+take_qty*(l.data->>'unit_price')::numeric;
   update public.school_records set data=data||jsonb_build_object('qty_remaining',(l.data->>'qty_remaining')::numeric-take_qty) where id=l.id;
   remaining:=remaining-take_qty; exit when remaining=0;
  end loop;
  if remaining>0 then raise exception 'Stock lots inconsistent'; end if;
  stock:=stock-quantity;
 end if;
 update public.school_records set data=data||jsonb_build_object('current_stock',stock) where id=s.id;
 insert into public.school_records(record_type,academic_year,created_by,data) values('SupplyTransactions',s.academic_year,auth.uid(),jsonb_build_object('supply_id',s.id,'supply_name',s.data->>'name','txn_type',txn_type,'txn_date',current_date,'qty',quantity,'unit_price',cost/quantity,'purpose',memo)) returning id into rid;
 return rid;
end $$;
create function public.school_borrow(item_id uuid, borrower text, due_date date) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare item public.school_records; rid uuid; kind text; available integer;
begin
 if public.school_role() is null or public.school_role()='pending' then raise exception 'Staff required'; end if;
 if due_date<current_date or length(trim(borrower))=0 then raise exception 'Borrower and valid due date required'; end if;
 select * into item from public.school_records where id=item_id and record_type in ('Books','Assets') for update;
 if not found then raise exception 'Item not found'; end if;
 if item.record_type='Books' then
  available:=coalesce((item.data->>'copies_available')::integer,0);if available<1 then raise exception 'No copies available'; end if;
  update public.school_records set data=data||jsonb_build_object('copies_available',available-1) where id=item.id;kind:='BookLoans';
 else
  if exists(select 1 from public.school_records where record_type='AssetLoans' and data->>'item_id'=item.id::text and data->>'status'='ยืมอยู่') then raise exception 'Asset already on loan'; end if;kind:='AssetLoans';
 end if;
 insert into public.school_records(record_type,academic_year,created_by,data) values(kind,item.academic_year,auth.uid(),jsonb_build_object('item_id',item.id,'book_title',item.data->>'title','asset_name',item.data->>'name','asset_no',item.data->>'asset_no','borrower_name',borrower,'borrow_date',current_date,'loan_date',current_date,'due_date',due_date,'status','ยืมอยู่')) returning id into rid;
 return rid;
end $$;
create function public.school_return(loan_id uuid) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare loan public.school_records; item public.school_records;
begin
 select * into loan from public.school_records where id=loan_id and record_type in ('BookLoans','AssetLoans') for update;
 if not found or not coalesce((loan.created_by=auth.uid() or public.school_role() in ('admin','director','admin_sec')),false) or public.school_role() is null or public.school_role()='pending' then raise exception 'Loan permission denied'; end if;
 if loan.data->>'status'<>'ยืมอยู่' then raise exception 'Already returned'; end if;
 select * into item from public.school_records where id=(loan.data->>'item_id')::uuid for update;
 if not found then raise exception 'Item not found'; end if;
 if item.record_type='Books' then update public.school_records set data=data||jsonb_build_object('copies_available',(data->>'copies_available')::integer+1) where id=item.id;end if;
 update public.school_records set data=data||jsonb_build_object('status','คืนแล้ว','return_date',current_date) where id=loan.id;
end $$;
revoke all on function public.school_supply(uuid,text,numeric,numeric,text),public.school_borrow(uuid,text,date),public.school_return(uuid) from public,anon;
grant execute on function public.school_supply(uuid,text,numeric,numeric,text),public.school_borrow(uuid,text,date),public.school_return(uuid) to authenticated;


create function public.school_delete_guard() returns trigger language plpgsql security definer set search_path=public,pg_temp as $$
begin
 if exists(select 1 from public.school_records r where r.id<>old.id and (r.data->>'item_id'=old.id::text or r.data->>'supply_id'=old.id::text or r.data->>'proj_id'=old.id::text or (old.record_type='Students' and r.record_type<>'Students' and r.data->>'student_id'=old.data->>'student_id') or (old.record_type='Teachers' and r.record_type<>'Teachers' and r.data->>'teacher_id'=old.data->>'teacher_id'))) then raise exception 'This record is referenced by other records'; end if;
 return old;
end $$;
create trigger school_delete_guard before delete on public.school_records for each row execute function public.school_delete_guard();
revoke all on function public.school_delete_guard() from public,anon,authenticated;
create index school_records_project_ref on public.school_records ((data->>'proj_id')) where record_type in ('ProjExpenses','ProjRequests','ProjActivities');
create index school_records_student_ref on public.school_records ((data->>'student_id')) where record_type in ('Savings','Scores','SDQ','LD','EQAssessment');
create index school_records_stock_ref on public.school_records ((data->>'supply_id')) where record_type='SupplyLots';
create index school_audit_actor on public.school_audit(actor);

commit;
