use mavenfuzzyfactory;
-- Date Functions Concept 
SELECT
website_session_id,
HOUR(created_at) as hr,
WEEKDAY(created_at) as wkday,-- 0 = Mon, 1 = Tuesday
CASE
	WHEN weekday(created_at) = 0 THEN 'Monday'
    WHEN weekday(created_at) = 1 THEN 'Tuesday'
    ELSE 'other_day'
    END as clean_weekday,
    QUARTER(created_at) as qtr,
    MONTH(created_at) as mo,
    DATE(created_at) as date,
    WEEK(created_at) as wk
FROM website_sessions
WHERE website_session_id BETWEEN 150000 AND 155000