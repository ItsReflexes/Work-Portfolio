-- Finding Top Pages
 use mavenfuzzyfactory;
 
 SELECT 
	pageview_url, 
    COUNT(distinct website_pageview_id) as pvs
 FROM website_pageviews
 WHERE website_pageview_id < 1000
 GROUP BY pageview_url
 order by pvs DESC;
 
 -- Entry Page Analysis
 CREATE TEMPORARY TABLE first_page_view
 SELECT 
 website_session_id,
 MIN(website_pageview_id) as min_pv_id
 FROM website_pageviews
 WHERE website_pageview_id < 1000
 GROUP BY website_session_id;
 
 SELECT first_page_view.website_session_id,
 website_pageviews.pageview_url AS landing_page, -- entry page
 COUNT(distinct first_page_view.website_session_id) as sessions_hitting_this_lander
 FROM first_page_view
	LEFT JOIN website_pageviews ON
    first_page_view.min_pv_id = website_pageview_id
    GROUP BY website_pageviews.pageview_url
 
 