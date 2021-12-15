--Traffic Source Conversion Rate
--sessions, orders, session_to order_conv_rate
--WHERE created at less than 2021-04-12


--TEST
SELECT
COUNT(distinct website_sessions.website_session_id) as sessions,
COUNT(distinct orders.order_id) as orders,
COUNT(distinct orders.order_id)/COUNT(distinct website_sessions.website_session_id) as session_to_order_conv_rt
FROM website_sessions 
	LEFT JOIN orders
    ON orders.website_session_id=website_sessions.website_session_id
WHERE created_at < '2012-04-14'

--Final Outlook
SELECT
COUNT(distinct website_sessions.website_session_id) as sessions,
COUNT(distinct orders.order_id) as orders,
COUNT(distinct orders.order_id)/COUNT(distinct website_sessions.website_session_id) as session_to_order_conv_rt
FROM website_sessions
	LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'