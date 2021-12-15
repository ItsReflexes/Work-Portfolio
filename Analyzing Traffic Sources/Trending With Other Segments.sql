-- Conversion Rate
-- Weekly Start Date (SQL Date Function)
-- dekstop and mobile sessions
-- gsearch and nonbrand (utm source and campaign)

SELECT
MIN(DATE(created_at)) as week_start_date,
COUNT(DISTINCT CASE WHEN  device_type = 'desktop' THEN website_session_id ELSE NULL END) as dtop_sessions, 
COUNT(Distinct CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) as mob_sessions
FROM website_sessions
WHERE created_at < '2012-06-09'
	AND website_sessions.created_at > '2012-04-15'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
YEAR(created_at), 
WEEK(created_at)