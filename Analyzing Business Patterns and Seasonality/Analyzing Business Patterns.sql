-- Analyzing Business Patterns
-- avg website session volume, by hour and day of week
-- date range of 9/15 and 11/15, 2012



SELECT 
	HOUR(created_at),
	-- AVG(website_sessions) as avg_sessions,
    AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END) AS mon,
	AVG(CASE WHEN wkday = 1 THEN website_sessions ELSE NULL END) AS tues,
	AVG(CASE WHEN wkday = 2 THEN website_sessions ELSE NULL END) AS wed,
	AVG(CASE WHEN wkday = 3 THEN website_sessions ELSE NULL END) AS thur,
	AVG(CASE WHEN wkday = 4 THEN website_sessions ELSE NULL END) AS fri,
	AVG(CASE WHEN wkday = 5 THEN website_sessions ELSE NULL END) AS sat,
	AVG(CASE WHEN wkday = 6 THEN website_sessions ELSE NULL END) AS sun
FROM (
SELECT
	DATE(created_at) as created_date,
	HOUR(created_at) as hr,
	WEEKDAY(created_at) as wkday,
	COUNT(distinct website_session_id) as sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3
) as daily_hourly_sessions
GROUP BY 1
ORDER BY 1