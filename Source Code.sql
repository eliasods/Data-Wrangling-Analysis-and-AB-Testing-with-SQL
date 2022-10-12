-- EXERCISE 1:
--We are running an experiment at an item-level, which means all users who visit will see the same page, but the layout of different item pages may differ.
--Compare this table to the assignment events we captured for user_level_testing.
--Does this table have everything you need to compute metrics like 30-day view-binary?

SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa
  
-- EXERCISE 2:  
--Reformat the final_assignments_qa to look like the final_assignments table, filling in any missing values with a placeholder of the appropriate data type.
-- Starter code:
--SELECT
-- * 
--FROM 
-- dsv1069.final_assignments_qa

SELECT item_id,
       test_a AS test_assignment,
       CASE WHEN test_a is not null then 'item_test_1'
       END AS test_number ,
       CASE WHEN test_a is not null then CAST('2013-01-05 00:00:00' AS date)
       END AS test_start_date
FROM dsv1069.final_assignments_qa
UNION
SELECT item_id,
       test_b AS test_assignment ,
       CASE WHEN test_b is not null then 'item_test_2'
       END AS test_number ,
       CASE WHEN test_b is not null then CAST('2015-03-14 00:00:00' AS date)
       END AS test_start_date
FROM dsv1069.final_assignments_qa
UNION
SELECT item_id,
       test_c AS test_assignment ,
       CASE WHEN test_c is not null then 'item_test_3'
       END AS test_number ,
       CASE WHEN test_c is not null then CAST('2016-01-07 00:00:00' AS date)
       END AS test_start_date
FROM dsv1069.final_assignments_qa
ORDER BY test_number

-- EXERCISE 3:
-- Use this table to 
-- compute order_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT
	test_assignment,
	COUNT(item_id) AS items,
	SUM(order_binary_30d) AS orders_completed
FROM	
(	
SELECT
	final_assignments.test_number,
	final_assignments.test_assignment,
	final_assignments.item_id,
	MAX(CASE WHEN (orders.created_at > final_assignments.test_start_date AND
			DATE_PART('day', created_at - test_start_date) <= 30)
	THEN  1 ELSE 0 END) AS order_binary_30d
FROM
dsv1069.final_assignments
LEFT JOIN
	dsv1069.orders
ON
	orders.item_id = final_assignments.item_id
WHERE 
	test_number = 'item_test_2'
GROUP BY
	final_assignments.test_number,
	final_assignments.test_assignment,
	final_assignments.item_id
) order_binary
WHERE 
	test_number = 'item_test_2'
GROUP BY
	test_assignment
  
--EXERCISE 4:
-- Use this table to 
-- compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT
  test_assignment,
	COUNT(item_id) AS items,
	SUM(view_binary_30d) AS views_binary_30d
FROM
(
SELECT
	final_assignments.test_number,
	final_assignments.test_assignment,
	final_assignments.item_id,
	MAX(CASE WHEN (event_time > final_assignments.test_start_date AND
			DATE_PART('day', event_time - test_start_date) <= 30)
	THEN  1 ELSE 0 END) AS view_binary_30d
FROM dsv1069.final_assignments
LEFT OUTER JOIN
	dsv1069.view_item_events
ON
	view_item_events.item_id = final_assignments.item_id
GROUP BY
  final_assignments.test_number,
	final_assignments.test_assignment,
	final_assignments.item_id) AS view_binary
WHERE 
	test_number = 'item_test_2'
GROUP BY
  test_assignment

-- EXECERCISE 5:
--Use the https://thumbtack.github.io/abba/demo/abba.html to compute the lifts in metrics and the p-values for the binary metrics 
-- (30 day order binary and 30 day view binary) using a interval 95% confidence.
