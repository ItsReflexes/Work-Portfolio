-- Impact of New Product Launch
-- Pull monthly order volume
-- overall conversion rates, per session, and a breakdown of sales by product
-- since 04/01/2012 and 04/05/2013

SELECT
	YEAR(website_sessions.created_at) as yr,
	MONTH(website_sessions.created_at) as mo,
	COUNT(distinct website_sessions.website_session_id) as sessions,
	COUNT(distinct orders.order_id) as orders,
    COUNT(distinct orders.order_id)/COUNT(distinct website_sessions.website_session_id) as conv_rate,
    SUM(orders.price_usd)/COUNT(distinct website_sessions.website_session_id) as revenue_per_session,
    COUNT(distinct CASE WHEN primary_product_id = 1 THEN order_id ELSE NULL END) as product_one_orders,
	COUNT(distinct CASE WHEN primary_product_id = 2 THEN order_id ELSE NULL END) as product_two_orders
FROM website_sessions
	LEFT JOIN orders ON
    orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY 1,2;
