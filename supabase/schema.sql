-- Family Day MVP schema. Run in Supabase SQL Editor as project owner.
create extension if not exists pgcrypto;

create table if not exists public.families (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.family_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  user_id uuid not null unique references auth.users(id) on delete cascade,
  role text not null check (role in ('parent','child')),
  display_name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.homework (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  title text not null,
  subject text,
  due_date date not null default current_date,
  details text,
  is_done boolean not null default false,
  completed_at timestamptz,
  completed_by uuid references auth.users(id) on delete set null,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.family_events (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  title text not null,
  event_date date not null,
  start_time time,
  end_time time,
  member_label text not null default '가족',
  notes text,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.timetable_entries (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  class_date date not null,
  period integer not null,
  subject text not null,
  memo text,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(family_id, class_date, period)
);

create or replace function public.is_family_member(target_family uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.family_members where family_id = target_family and user_id = auth.uid()); $$;

create or replace function public.create_family(p_family_name text, p_display_name text)
returns uuid language plpgsql security definer set search_path = public
as $$
declare new_family_id uuid;
begin
  if auth.uid() is null then raise exception '로그인이 필요합니다.'; end if;
  if exists(select 1 from public.family_members where user_id = auth.uid()) then raise exception '이미 가족 공간에 가입되어 있습니다.'; end if;
  insert into public.families(name, created_by) values (coalesce(nullif(trim(p_family_name),''),'우리 가족'), auth.uid()) returning id into new_family_id;
  insert into public.family_members(family_id,user_id,role,display_name) values(new_family_id,auth.uid(),'parent',coalesce(nullif(trim(p_display_name),''),'부모'));
  return new_family_id;
end; $$;

grant execute on function public.create_family(text,text) to authenticated;

alter table public.families enable row level security;
alter table public.family_members enable row level security;
alter table public.homework enable row level security;
alter table public.family_events enable row level security;
alter table public.timetable_entries enable row level security;

create policy "family members read family" on public.families for select to authenticated using (public.is_family_member(id));
create policy "members read family members" on public.family_members for select to authenticated using (public.is_family_member(family_id));
create policy "parents manage family members" on public.family_members for all to authenticated using (public.is_family_member(family_id) and exists(select 1 from public.family_members m where m.family_id=family_id and m.user_id=auth.uid() and m.role='parent')) with check (public.is_family_member(family_id));
create policy "family read homework" on public.homework for select to authenticated using (public.is_family_member(family_id));
create policy "family add homework" on public.homework for insert to authenticated with check (public.is_family_member(family_id) and exists(select 1 from public.family_members m where m.family_id=homework.family_id and m.user_id=auth.uid() and m.role='parent'));
create policy "family update homework" on public.homework for update to authenticated using (public.is_family_member(family_id)) with check (public.is_family_member(family_id));
create policy "family read events" on public.family_events for select to authenticated using (public.is_family_member(family_id));
create policy "family manage events" on public.family_events for all to authenticated using (public.is_family_member(family_id)) with check (public.is_family_member(family_id));
create policy "family read timetable" on public.timetable_entries for select to authenticated using (public.is_family_member(family_id));
create policy "parents manage timetable" on public.timetable_entries for all to authenticated using (public.is_family_member(family_id) and exists(select 1 from public.family_members m where m.family_id=timetable_entries.family_id and m.user_id=auth.uid() and m.role='parent')) with check (public.is_family_member(family_id));
