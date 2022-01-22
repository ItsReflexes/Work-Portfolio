-- Cross-sell analysis
-- Analyze orders and order_items data, use pageviews to see if cross-selling hurts conversion rates, 
-- This data will help us to understand the customer purchase behaviours

-- TEST
SELECT 
    orders.primary_product_id,
    order_items.product_id as cross_sell_product,
    COUNT(distinct orders.order_id) as orders
FROM orders
	LEFT JOIN order_items ON
		order_items.order_id = orders.order_id
		AND order_items.is_primary_item = 0
WHERE orders.order_id BETWEEN 10000 and 11000
GROUP BY 1,2;

-- TEST 2 
SELECT 
    orders.primary_product_id,
    COUNT(distinct orders.order_id) as orders,
    COUNT(distinct case when order_items.product_id = 1 THEN orders.order_id ELSE NULL END) as cross_sell_prod1,
    COUNT(distinct case when order_items.product_id = 2 THEN orders.order_id ELSE NULL END) as cross_sell_prod2,
    COUNT(distinct case when order_items.product_id = 3 THEN orders.order_id ELSE NULL END) as cross_sell_prod3
FROM orders
	LEFT JOIN order_items ON
		order_items.order_id = orders.order_id
		AND order_items.is_primary_item = 0
WHERE orders.order_id BETWEEN 10000 and 11000
GROUP BY 1;

-- TEST 3 (rates)
SELECT 
    orders.primary_product_id,
	COUNT(distinct case when order_items.product_id = 1 THEN orders.order_id ELSE NULL END)/COUNT(distinct orders.order_id) as prod1_rate,
    COUNT(distinct case when order_items.product_id = 2 THEN orders.order_id ELSE NULL END)/COUNT(distinct orders.order_id) as prod2_rate,
    COUNT(distinct case when order_items.product_id = 3 THEN orders.order_id ELSE NULL END)/COUNT(distinct orders.order_id) as prod3_rate
FROM orders
	LEFT JOIN order_items ON
		order_items.order_id = orders.order_id
		AND order_items.is_primary_item = 0
WHERE orders.order_id BETWEEN 10000 and 11000
GROUP BY 1