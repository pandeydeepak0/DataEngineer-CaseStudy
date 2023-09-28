-- #### Problem Statement Breakup #### :

-- 1. Each row in the input represents the booking reservation, the target here is to find the most number of overlapping bookings on the same day. 
      -- The number of bookings on same day represent total rooms occupied 
-- 2. This information is to be extracted for all days from first checkin till last checkout date. 
-- 3. For each week, the maximum overlapping bookings on a single day is the number of minimum rooms we need to prepare for guests

-- #### Solution Approach #### :

-- We have total 1 tables reservations
    -- reservations: PK - reservation_id 

-- For the entire range of dates, I needed to get overlapping bookings for each day, including ones not having any booking activity
-- I used the GENERATE_SERIES function the extract all dates from first checkin till last checkout date.

-- I wrote another CTE to find out for each date in date range, the number of occupied rooms 
-- For all records in reservations; I pulled the count of reservations (parallel bookings) for that date 
-- Considering that "room can always be made available the same day as the check-out date", I kept non-strict upper bound on check out date

-- Further, I rolled up the data, by week using maximum count for any day of that week. (max. room needed at same time)

-- Finally the results were ordered by week. 


with daterange as (
    select
        generate_series(
            (select min(check_in_date) from reservations),
            (select max(check_out_date) from reservations),
            interval '1 day'
        )::date as date_in_range
),

bookings as (
   select
      dr.date_in_range,
      count(rv.reservation_id) as rooms_booked
   from
      daterange dr
   left join
      reservations rv
   -- on dr.reservation_date between r.check_in_date and r.check_out_date
   on
      dr.date_in_range >= rv.check_in_date
   and
      dr.date_in_range < rv.check_out_date
   group by
      dr.date_in_range
)
select
    concat(extract(year from date_in_range), '-0', extract(week from date_in_range)) as week,
    max(rooms_booked) as number_of_rooms
from
    bookings
group by week 
order by week;
