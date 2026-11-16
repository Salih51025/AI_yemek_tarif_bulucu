-- ============================================================
-- AI Chef — Supabase Schema
-- Run these migrations in order via Supabase SQL Editor.
-- ============================================================

-- ---------------------------------------------------------------
-- 1. USER PROFILES
--    Extends Supabase auth.users with app-specific data.
--    region_country / region_city drive local cuisine recommendations.
-- ---------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url  text,
  region_country text,        -- e.g. "TR" (ISO 3166-1 alpha-2)
  region_city    text,        -- e.g. "Bursa"
  preferred_language text default 'en',
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

alter table public.profiles enable row level security;
create policy "Users can read own profile"
  on public.profiles for select using (auth.uid() = id);
create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);
create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = id);

-- ---------------------------------------------------------------
-- 2. RECIPES HISTORY (enhanced)
--    Stores every AI-generated recipe tied to a user.
--    favorite_count is denormalized for efficient trending queries.
-- ---------------------------------------------------------------
create table if not exists public.recipes_history (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid references auth.users(id) on delete cascade,
  title               text not null,
  description         text,
  ingredients         jsonb default '[]'::jsonb,
  steps               jsonb default '[]'::jsonb,
  cooking_time_minutes int default 30,
  prep_time_minutes   int default 0,
  difficulty          text default 'Medium',
  category            text default 'Dinner',
  servings            int default 2,
  calories_per_serving int,
  image_url           text,
  image_prompt        text,       -- AI-generated Unsplash keyword
  tags                jsonb default '[]'::jsonb,
  is_favorite         boolean default false,
  favorite_count      int default 0,   -- denormalized, updated via trigger
  generation_count    int default 1,   -- how many times this was generated
  source              text default 'ai',
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

alter table public.recipes_history enable row level security;
create policy "Users can read own recipes"
  on public.recipes_history for select using (auth.uid() = user_id);
create policy "Users can insert own recipes"
  on public.recipes_history for insert with check (auth.uid() = user_id);
create policy "Users can update own recipes"
  on public.recipes_history for update using (auth.uid() = user_id);
create policy "Users can delete own recipes"
  on public.recipes_history for delete using (auth.uid() = user_id);

-- ---------------------------------------------------------------
-- 3. GLOBAL TRENDING RECIPES
--    Anonymized view of popular recipes across all users.
--    Powered by favorite_count — no PII exposed.
-- ---------------------------------------------------------------
create table if not exists public.trending_recipes (
  id                  uuid primary key default gen_random_uuid(),
  title               text not null,
  description         text,
  ingredients         jsonb default '[]'::jsonb,
  steps               jsonb default '[]'::jsonb,
  cooking_time_minutes int default 30,
  difficulty          text default 'Medium',
  category            text default 'Dinner',
  servings            int default 2,
  calories_per_serving int,
  image_url           text,
  image_prompt        text,
  tags                jsonb default '[]'::jsonb,
  favorite_count      int default 0,
  generation_count    int default 0,
  region_country      text,       -- null = global, 'TR' = Turkey-specific
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

-- Public read access for trending (no auth required to browse).
alter table public.trending_recipes enable row level security;
create policy "Anyone can read trending recipes"
  on public.trending_recipes for select using (true);

-- Index for efficient trending queries.
create index if not exists idx_trending_favorite_count
  on public.trending_recipes (favorite_count desc, generation_count desc);
create index if not exists idx_trending_region
  on public.trending_recipes (region_country, favorite_count desc);

-- ---------------------------------------------------------------
-- 4. TRIGGER: sync favorites count to trending_recipes
--    When a recipe is favorited in recipes_history, upsert into
--    trending_recipes and increment the counter.
-- ---------------------------------------------------------------
create or replace function public.sync_favorite_to_trending()
returns trigger language plpgsql security definer as $$
begin
  if new.is_favorite = true and (old.is_favorite is null or old.is_favorite = false) then
    -- Upsert into trending_recipes keyed on title (normalized).
    insert into public.trending_recipes (
      title, description, ingredients, steps,
      cooking_time_minutes, difficulty, category,
      servings, calories_per_serving, image_url, image_prompt, tags,
      favorite_count, generation_count
    )
    values (
      new.title, new.description, new.ingredients, new.steps,
      new.cooking_time_minutes, new.difficulty, new.category,
      new.servings, new.calories_per_serving, new.image_url, new.image_prompt, new.tags,
      1, 1
    )
    on conflict (title) do update
      set favorite_count = trending_recipes.favorite_count + 1,
          updated_at = now();
  elsif new.is_favorite = false and old.is_favorite = true then
    update public.trending_recipes
      set favorite_count = greatest(0, favorite_count - 1),
          updated_at = now()
      where title = new.title;
  end if;
  return new;
end;
$$;

create unique index if not exists idx_trending_title
  on public.trending_recipes (lower(title));

drop trigger if exists trg_sync_favorite on public.recipes_history;
create trigger trg_sync_favorite
  after update of is_favorite on public.recipes_history
  for each row execute function public.sync_favorite_to_trending();
