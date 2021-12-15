USE mavenfuzzyfactory;

SELECT website_sessions.utm_content,
COUNT(distinct website_sessions.website_session_id) as sessions,
COUNT(distinct orders.order_id) as orders,
COUNT(distinct orders.order_id)/COUNT(distinct website_sessions.website_session_id) as session_to_order_conv_rt
FROM website_sessions 
	LEFT JOIN orders
    ON orders.website_session_id=website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 and 2000
GROUP BY 1
ORDER BY sessions DESC;