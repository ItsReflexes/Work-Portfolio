-- Device Type
-- sessions, orders, conv. rate
-- GROUP By device type

-- TEST and Outlook
SELECT device_type,
COUNT(distinct website_sessions.website_session_id) as sessions,
COUNT(distinct orders.order_id) as orders,
COUNT(distinct orders.order_id)/COUNT(distinct website_sessions.website_session_id) as session_to_order_conv_rt
FROM website_sessions
	LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
    WHERE website_sessions.created_at < '2012-05-11'
		AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
    GROUP BY device_type;