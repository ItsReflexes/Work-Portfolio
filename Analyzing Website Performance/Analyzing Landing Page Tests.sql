-- Analyzing Landing Page Tests
-- WHERE /lander 1 is LIVE!!!!
-- Outlook: landing_page, total_sessions, bounced_sessions, bounce_rate
-- STEP 1: first instance of lander1 launched
-- STEP 2: find the first website_pageview_id for each session
-- STEP 3: identify the landing page of each session
-- STEP 4: count pageviews for each session to calculate "bounces"
-- STEP 5: count total sesions and bounced sessions, GROUP BY landing page

-- 1 and 2
SELECT
	MIN(created_at) as first_created_at,
    MIN(website_pageview_id) as first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
AND created_at IS NOT NULL;

-- created at : '2012-06-19 00:35:54', '23504'
-- 3
CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id, 
	MIN(website_pageview_id) as min_pageview_id
FROM website_pageviews
	Inner JOIN website_sessions ON
    website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at < '2012-07-28' -- arbitrary
    AND website_pageviews.website_pageview_id > 23504
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	website_pageviews.website_session_id;

-- landing page of each session
CREATE temporary table nonbrand_test_sessions_w_landing_page
SELECT 
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url as landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews ON
    first_test_pageviews.min_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

SELECT * FROM nonbrand_test_sessions_w_landing_page; -- TEST

-- COUNT of pageviews per session
CREATE Temporary table nonbrand_test_bounced_sessions
SELECT
	nonbrand_test_sessions_w_landing_page.website_session_id,
	nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) as count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN website_pageviews ON
    website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
GROUP BY
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;

SELECT * FROM nonbrand_test_bounced_sessions; -- TEST

-- total sesions and bounced sessions test
SELECT
	nonbrand_test_sessions_w_landing_page.website_session_id,
	nonbrand_test_sessions_w_landing_page.landing_page,
    nonbrand_test_bounced_sessions.website_session_id as bounced_website_sessions_id
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions ON
    nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY
	nonbrand_test_sessions_w_landing_page.website_session_id;

-- COUNT of total sessions and bounced sessions test
SELECT
	nonbrand_test_sessions_w_landing_page.landing_page,
	COUNT(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as sessions,
    COUNT(distinct nonbrand_test_bounced_sessions.website_session_id) as bounced_sessions,
    COUNT(distinct nonbrand_test_bounced_sessions.website_session_id)/COUNT(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as bounce_rate
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions ON
    nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY
	nonbrand_test_sessions_w_landing_page.landing_page;
