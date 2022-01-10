-- Calculating Bounce Rates

-- STEP 1: find the first website_pageview_id for each session
-- STEP 2: identify the landing page of each session
-- STEP 3: count pageviews for each session, identify "bounces"
-- Step 4: count toal sessions and bounced sessions

CREATE TEMPORARY TABLE first_pageviews
SELECT
website_session_id, 
MIN(website_pageview_id) as min_pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

SELECT *FROM first_pageviews;  -- TEST

-- landing page
CREATE temporary table sessions_w_home_landing_page
SELECT 
first_pageviews.website_session_id,
website_pageviews.pageview_url AS landing_page
 FROM first_pageviews
	LEFT JOIN website_pageviews ON
   website_pageviews.website_pageview_id = first_pageviews.min_pageview_id
   WHERE website_pageviews.pageview_url = '/home';
   
 SELECT * FROM sessions_w_home_landing_page; -- TEST

-- count of pageviews per session
CREATE temporary table bounced_sessions
SELECT
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page,
    COUNT(Distinct website_pageviews.website_pageview_id) as count_of_pages_viewed
FROM sessions_w_home_landing_page
LEFT JOIN website_pageviews ON
sessions_w_home_landing_page.website_session_id = website_pageviews.website_session_id
GROUP BY 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page
HAVING 
	COUNT(website_pageviews.website_pageview_id) = 1;
 
-- TEST RUN
SELECT 
    sessions_w_home_landing_page.website_session_id,
    bounced_sessions.website_session_id as bounced_website_session_id
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions ON
sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY
	sessions_w_home_landing_page.website_session_id;

-- COUNT of total sessions and bounced sesions
	SELECT 
    COUNT(distinct sessions_w_home_landing_page.website_session_id) as sessions,
    COUNT(distinct bounced_sessions.website_session_id) as bounced_sessions,
    COUNT(distinct sessions_w_home_landing_page.website_session_id)/COUNT(distinct bounced_sessions.website_session_id) as bounce_rate
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions ON
sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id

    
    
    
