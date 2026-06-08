-- ============================================================
-- 燎原 FIRE Atlas · Supabase Schema
-- 步骤：
--   1. 在 Supabase 控制台 → SQL Editor → Run 执行一次即可
--   2. 设置 Supabase Dashboard → Authentication → Providers → Anonymous Sign-ins → 开启 Enable Anonymous Sign-ins
-- ============================================================

create extension if not exists "uuid-ossp";

-- ── 1. 月度记录表 ──────────────────────────────────────────
create table if not exists fire_records (
  id         bigint generated always as identity primary key,
  user_id    uuid not null,                              -- auth.uid() 或匿名设备 ID
  month      text not null,                               -- "2026-06"
  values     jsonb not null default '{}',
  memo       text not null default '',
  proud      text not null default '',
  adjust     text not null default '',
  updated_at timestamptz not null default now(),
  unique (user_id, month)
);

alter table fire_records enable row level security;

-- RLS：当前用户只能访问自己的记录
create policy "own_records_select" on fire_records for select
  using (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);

create policy "own_records_insert" on fire_records for insert
  with check (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);

create policy "own_records_update" on fire_records for update
  using (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);

create policy "own_records_delete" on fire_records for delete
  using (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);

-- ── 2. 指标配置表 ─────────────────────────────────────────
create table if not exists fire_metrics (
  id         bigint generated always as identity primary key,
  user_id    uuid not null,
  metrics    jsonb not null,
  updated_at timestamptz not null default now(),
  unique (user_id)
);

alter table fire_metrics enable row level security;

create policy "own_metrics_select" on fire_metrics for select
  using (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);

create policy "own_metrics_upsert" on fire_metrics for insert
  with check (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);

create policy "own_metrics_update" on fire_metrics for update
  using (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);

-- ── 3. 目标 & 偏好配置表 ───────────────────────────────────
create table if not exists fire_prefs (
  id          bigint generated always as identity primary key,
  user_id     uuid not null,
  goal_config jsonb not null default '{"targetAmount":500,"raiseEvery3Years":0.2,"savingsRate":0.5}',
  ui_prefs    jsonb not null default '{"activeView":"entry"}',
  updated_at  timestamptz not null default now(),
  unique (user_id)
);

alter table fire_prefs enable row level security;

create policy "own_prefs_select" on fire_prefs for select
  using (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);

create policy "own_prefs_upsert" on fire_prefs for insert
  with check (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);

create policy "own_prefs_update" on fire_prefs for update
  using (auth.uid() = user_id or user_id = '00000000-0000-0000-0000-000000000000'::uuid);
