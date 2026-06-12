-- Automatically keep parking_lots.rating in sync with reviews.
-- Run this after docs/supabase_schema.sql.

create or replace function public.refresh_parking_lot_rating(p_lot_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.parking_lots lot
  set rating = coalesce(
    (
      select round(avg(review.rating)::numeric, 1)
      from public.reviews review
      where review.parking_lot_id = p_lot_id
    ),
    0
  )
  where lot.id = p_lot_id;
end;
$$;

create or replace function public.refresh_parking_lot_rating_from_review()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.refresh_parking_lot_rating(old.parking_lot_id);
    return old;
  end if;

  perform public.refresh_parking_lot_rating(new.parking_lot_id);

  if tg_op = 'UPDATE' and old.parking_lot_id <> new.parking_lot_id then
    perform public.refresh_parking_lot_rating(old.parking_lot_id);
  end if;

  return new;
end;
$$;

drop trigger if exists refresh_parking_lot_rating_from_review on public.reviews;
create trigger refresh_parking_lot_rating_from_review
after insert or update or delete on public.reviews
for each row execute function public.refresh_parking_lot_rating_from_review();
