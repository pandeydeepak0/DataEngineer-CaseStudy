-- #### Problem Statement Breakup #### :

-- 1. Find the clicks and booking for each hotel 
-- 2. Roll up the total clicks and booking at country level 
-- 3. Find conversion rate in each country using booking/clicks 
-- 4. Order results by Country 

-- #### Solution Approach #### :

-- We have total 3 tables Hotels, Clicks, Bookings. 
    -- Hotels: PK - hotel_id  ;  FK - NA 
    -- Clicks: PK - NA / (hotel_id, advertiser_id) ; FK - hotel_id 
    -- Bookings: PK - NA / (hotel_id, advertise_id) ; FK - hotel_id 

-- For each hotel I needed to find the total number of clicks and bookings in the given time period. 
-- Using left join with clicks and bookings I extracted data for all hotels (including ones having no clicks and/or no bookings). 
-- Further, I rolled up the total clicks and bookings at country level. 

-- I wrote a CTE to solve part 1 and 2 of problem statement breakup, 
-- which helped with logical breakup and simplified the query, in production usecases this might give performance improvements as well. 
-- A subquery can be used as an alternative.

-- The temporary table is further used to extract conversion rate, 
    -- I am using a CASE statement to handle divide by 0 cases by replacing their outcome with NULLs 
    -- Using a coalesce to handle cases with no bookings against clicks

-- Finally the results are ordered by Country. 


with hotel_data as (
    select 
        ht.country, 
        sum(ck.number_clicks) as total_clicks,
        sum(bk.number_bookings) as total_bookings
    from 
        hotels ht
    left join clicks ck
        on ht.hotel_id = ck.hotel_id
    left join bookings bk 
        on ht.hotel_id = bk.hotel_id
    group by ht.country
) 
select 
    country, 
    case when total_clicks > 0 then coalesce(total_bookings,0)::float/total_clicks else null end as booking_conversion 
from hotel_data
    order by country;