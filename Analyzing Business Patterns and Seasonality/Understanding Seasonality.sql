-- Understanding Seasonality
-- yr, month, sessions, orders

-- First Query Result
SELECT 
	YEAR(website_sessions.created_at) as yr,
	MONTH(website_sessions.created_at) as mo,
	COUNT(distinct website_sessions.website_session_id) as sessions,
	COUNT(distinct orders.order_id) as orders
FROM website_sessions
LEFT JOIN orders on
orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2;

-- week_start_date, sessions, orders
SELECT
-- yearweek(website_sessions.created_at) as year_week,
    MIN(DATE(website_sessions.created_at)) as week_start_date,
    COUNT(distinct website_sessions.website_session_id) as sessions,
	COUNT(distinct orders.order_id) as orders
FROM website_sessions
LEFT JOIN orders on
orders.website_session_id = website_sessions.website_session_id
GROUP BY YEARWEEK(website_sessions.created_at)