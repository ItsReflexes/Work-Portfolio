-- TOP Entry Pages
-- STEP 1: find the first pageview for each session
-- STEP 2: find the url the customer saw on that first pageview

CREATE temporary table first_pv_per_session
SELECT website_session_id, 
MIN(website_pageview_id) as first_pv
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY website_session_id;

SELECT website_pageviews.pageview_url as landing_page_url,
COUNT(Distinct first_pv_per_session.website_session_id) as sessions_hitting_this_lander
FROM first_pv_per_session
LEFT JOIN website_pageviews ON 
first_pv_per_session.first_pv = website_pageview_id
GROUP BY website_pageviews.pageview_url;
