USE mavenfuzzyfactory;

SELECT 
    WEEK(created_at),
    YEAR(created_at),
    MIN(DATE(created_at)) as week_start,
    COUNT(Distinct website_session_id) as sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 and 150000
GROUP By 1,2