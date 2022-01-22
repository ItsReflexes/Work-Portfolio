-- BETWEEN 08/22 and 9/18
-- device_type, utm_source, sessions, orders, conv_rate
SELECT
	device_type,
    utm_source,
    COUNT(distinct website_sessions.website_session_id) as sessions,
    COUNT(distinct orders.order_id) as orders,
    COUNT(distinct orders.order_id)/COUNT(distinct website_sessions.website_session_id) as conv_rate
FROM website_sessions
LEFT JOIN orders ON
orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-19'
AND utm_campaign = 'nonbrand'
GROUP By 1,2