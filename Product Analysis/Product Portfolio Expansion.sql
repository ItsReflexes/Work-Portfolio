SELECT
	CASE
		WHEN website_sessions.created_at < '2013-12-12' THEN 'A. Pre_Birthday_Bear'
		WHEN website_sessions.created_at >= '2013-12-12' THEN 'B. Post_Birthday_Bear'
        ELSE 'check logic'
	END as time_period,
    COUNT(distinct website_sessions.website_session_id) as sessions,
    COUNT(distinct orders.order_id) as orders,
    COUNT(distinct orders.order_id)/COUNT(distinct website_sessions.website_session_id) as conv_rate,
    SUM(orders.price_usd) as total_revenue,
    SUM(orders.items_purchased) as total_products_sold,
    SUM(orders.price_usd)/COUNT(distinct orders.order_id) as average_order_value,
	SUM(orders.items_purchased)/COUNT(distinct orders.order_id) as products_per_order,
    SUM(orders.price_usd)/COUNT(distinct website_sessions.website_session_id) as revenue_per_session
FROM website_sessions
	LEFT JOIN orders
    ON orders.website_session_id =  website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1;