
SELECT 
	 -- YEAR(created_at) as YR,
     -- WEEK(created_at) as WK,
    MIN(DATE(created_at)) as week_started_at,
    count(distinct website_session_id) as sessions
    FROM website_sessions
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    group by 
		YEAR(created_at),
        WEEK(created_at)