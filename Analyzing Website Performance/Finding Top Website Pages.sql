-- FINDING TOP Website Pages
-- WHERE created_at < '2012-06-09'

-- IF needed, might not be neccessary
CREATE TEMPORARY TABLE most_page_views
 SELECT 
 website_session_id,
 MAX(website_pageview_id) as max_pv_id
 FROM website_pageviews
 GROUP BY website_session_id;

-- Top Website Page Outlook
SELECT 
 website_pageviews.pageview_url, 
COUNT(distinct website_pageview_id) as sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC;