-- #### Problem Statement Breakup #### :

-- 1. Find all the combinations of two people we can have eg. (P1, P1) such that P1 != P2 
-- 2. Find all (P1, P2) such that age difference >= 16
-- 3. Find the hotel in which one of the person from this combination has stayed (P1, hotel)
-- 4. Check for every (P1, hotel) if P2 has stayed in same hotel i.e. if (P2, hotel) exists in guest list of any hotel

-- #### Solution Approach #### :

-- We have total 2 tables Hotels, gust_list
    -- travelers: PK - name  ;  FK - NA 
    -- guest_kist: PK - NA / (hotel, traveler) ; FK - traveler 

-- For each person in travelers table; I needed to find all the pairs that can be made; 
-- Using join with the same table I extracted all combinations further this was restricted for case P1 != P2, 
-- and age difference >= 16 years; as same person can't be parent and child. I have considered P1 as child and P2 as Parent. 

-- For each child I pulled the hotel they stayed at from guest_list table, 
-- I wrote a CTE to solve part 1, 2 and 3 of problem statement breakup. 

-- Using the CTE table, I further checked if against the child and hotel records corresponding parent and hotel record exist in guest_list, 
    -- This indicates that 2 seperate people stayed in same hotel
    -- For all cases that are true; Further I took distinct child records as child and parent can be Many to Many relation.

-- Finally the results are ordered by child names. 

with all_booking_pairs as (
   select 
      t1.name as child,
      t2.name as parent,
      t1.age as child_age, 
      t2.age as parent_age,
      gl.hotel
   from 
      travelers t1 
   join guest_list gl on t1.name = gl.traveler 
   join travelers t2 on t1.name != t2.name 
   where t2.age - t1.age >= 16
)
select 
   distinct child as traveler_name
from all_booking_pairs 
where (hotel, parent) in (select hotel, traveler from guest_list)
order by child;