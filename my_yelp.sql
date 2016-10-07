--1 Write a query to find the restaurant with the name 'Nienow, Kiehn and DuBuque'. Run the query and record the query run time.

select * from restaurant
where name = 'Nienow, Kiehn and DuBuque'
; -- 872ms

-- 2.
 Seq Scan on restaurant  (cost=0.00..57655.25 rows=48 width=23)
  Filter: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)

-- 3
create index on restaurant (name)
; --- 91.0 s

-- 4
select * from restaurant
where name = 'Nienow, Kiehn and DuBuque'
; -- 1ms, Yes the performance improved drastically.

-- 5
-- Bitmap Heap Scan on restaurant  (cost=4.80..190.37 rows=48 width=23)
--   Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--   ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.79 rows=48 width=0)
--         Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)

------------------------

--1. Write a query to find the top 10 reviewers based on karma. Run it and record the query run time
select * from reviewer
order by karma
;
 -- 15.0s


--2
-- Sort  (cost=495923.45..503423.70 rows=3000100 width=23)
--   Sort Key: karma
--   ->  Seq Scan on reviewer  (cost=0.00..50111.00 rows=3000100 width=23)

--3
create index on reviewer (karma)
  -- 6.9 seconds to create index on karma column

--4 Re-run the query in step 1. Is performance improved? Record the new runtime.
  -- 1.0 ms

--5
-- Limit  (cost=0.43..0.95 rows=10 width=23)
-- ->  Index Scan using reviewer_karma_idx on reviewer  (cost=0.43..157135.29 rows=3000100 width=23)

--------------------------------
--1. Write a query to list the restaurant reviews for 'Nienow, Kiehn and DuBuque'. Run and record the query run time.
Select * from review
inner join restaurant on review.restaurant_id = restaurant.id
where restaurant.name = 'Nienow, Kiehn and DuBuque'
; -- 4.0 seconds

-- -- 2 Re-run query with explain, and record the explain plan.
-- Hash Join  (cost=190.97..287064.81 rows=96 width=265)
--   Hash Cond: (review.restaurant_id = restaurant.id)
--   ->  Seq Scan on review  (cost=0.00..264372.64 rows=6000064 width=242)
--   ->  Hash  (cost=190.37..190.37 rows=48 width=23)
-- ->  Bitmap Heap Scan on restaurant  (cost=4.80..190.37 rows=48 width=23)
--       Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--       ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.79 rows=48 width=0)
--             Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)


-- 3 Write a query to find the average star rating for 'Nienow, Kiehn and DuBuque'. Run and record the query run time.
Select avg(review.stars) from review
inner join restaurant on review.restaurant_id = restaurant.id
where restaurant.name = 'Nienow, Kiehn and DuBuque'
; -- 3.5s

-- 4 Re-run query with explain, and save the explain plan.
--
-- Aggregate  (cost=287065.06..287065.07 rows=1 width=32)
--   ->  Hash Join  (cost=190.97..287064.81 rows=96 width=4)
--         Hash Cond: (review.restaurant_id = restaurant.id)
--         ->  Seq Scan on review  (cost=0.00..264372.64 rows=6000064 width=8)
--         ->  Hash  (cost=190.37..190.37 rows=48 width=4)
--               ->  Bitmap Heap Scan on restaurant  (cost=4.80..190.37 rows=48 width=4)
--                     Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--                     ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.79 rows=48 width=0)
--                           Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)

-- 5 Create an index for the foreign key used in the join to make the above queries faster.
create index on review (restaurant_id);
  -- 13.1s



-- 6 Re-run the query you ran in step 1. Is performance improved? Record the query run time.
 -- 1 ms

-- 7 Re-run the query you ran in step 3. Is performance improved? Record the query run time.
 -- 2 ms

-- 8 With explain, compare the before and after query plan of both queries.
 -- not doing seq serching.


 -------------------------------------------------------
1.
 select reviewer.name from reviewer
 inner join review on review.reviewer_id = reviewer.id
 inner join restaurant on review.restaurant_id = restaurant.id
 where restaurant.name = 'Nienow, Kiehn and DuBuque'
 ;  -- 3ms

 -- Nested Loop  (cost=5.66..1028.83 rows=96 width=4)
 --   ->  Nested Loop  (cost=5.23..983.09 rows=96 width=4)
 --         ->  Bitmap Heap Scan on restaurant  (cost=4.80..190.37 rows=48 width=4)
 --               Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
 --               ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.79 rows=48 width=0)
 --                     Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
 --         ->  Index Scan using review_restaurant_id_idx on review  (cost=0.43..16.48 rows=3 width=8)
 --               Index Cond: (restaurant_id = restaurant.id)
 --   ->  Index Scan using reviewer_pkey on reviewer  (cost=0.43..0.47 rows=1 width=8)
 --         Index Cond: (id = review.reviewer_id)


 2. -- 2ms
 select avg(reviewer.karma) from reviewer
 inner join review on review.reviewer_id = reviewer.id
 inner join restaurant on review.restaurant_id = restaurant.id
 where restaurant.name = 'Nienow, Kiehn and DuBuque'
 ;
 --
 -- Aggregate  (cost=1029.07..1029.08 rows=1 width=32)
 --   ->  Nested Loop  (cost=5.66..1028.83 rows=96 width=4)
 --         ->  Nested Loop  (cost=5.23..983.09 rows=96 width=4)
 --               ->  Bitmap Heap Scan on restaurant  (cost=4.80..190.37 rows=48 width=4)
 --                     Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
 --                     ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.79 rows=48 width=0)
 --                           Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
 --               ->  Index Scan using review_restaurant_id_idx on review  (cost=0.43..16.48 rows=3 width=8)
 --                     Index Cond: (restaurant_id = restaurant.id)
 --         ->  Index Scan using reviewer_pkey on reviewer  (cost=0.43..0.47 rows=1 width=8)
 --               Index Cond: (id = review.reviewer_id)

3.
create index on review (reviewer_id); -- 13.2

4.
-- 2ms for number 1
-- 1ms for number 2

-- Aggregate  (cost=983.34..983.35 rows=1 width=32)
--   ->  Nested Loop  (cost=5.23..983.09 rows=96 width=4)
--         ->  Bitmap Heap Scan on restaurant  (cost=4.80..190.37 rows=48 width=4)
--               Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--               ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.79 rows=48 width=0)
--                     Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--         ->  Index Scan using review_restaurant_id_idx on review  (cost=0.43..16.48 rows=3 width=8)
--               Index Cond: (restaurant_id = restaurant.id)
