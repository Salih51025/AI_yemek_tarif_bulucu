-- Run in Supabase SQL Editor if load() fails with:
-- "column recipes_history.is_favorite does not exist"
alter table public.recipes_history
  add column if not exists is_favorite boolean default false;

create index if not exists idx_recipes_history_user_favorite
  on public.recipes_history (user_id, is_favorite)
  where is_favorite = true;
