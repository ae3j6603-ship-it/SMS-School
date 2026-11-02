-- Normalize Gregorian academic years before the existing record validation trigger.
create or replace function public.school_normalize_year() returns trigger language plpgsql set search_path=public,pg_temp as $$
declare y text;
begin
 y:=coalesce(nullif(new.data->>'academic_year',''),new.academic_year);
 if y ~ '^[0-9]{4}$' and y::integer between 1900 and 2200 then y:=(y::integer+543)::text; end if;
 new.academic_year:=y;
 new.data:=new.data||jsonb_build_object('academic_year',y);
 return new;
end $$;
revoke all on function public.school_normalize_year() from public,anon,authenticated;
create trigger school_a_normalize_year before insert or update on public.school_records for each row execute function public.school_normalize_year();
