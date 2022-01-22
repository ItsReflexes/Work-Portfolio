-- Pull through clickthrough rates from /products since the product launch on 01/06/2013
-- GROUP By product
-- compare the 3 months leading up to launch as baseline


-- 1, find the products pageviews 
CREATE TEMPORARY TABLE product_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
CASE
	WHEN created_at < '2013-01-06' THEN 'A. Pre_Product_2'
    WHEN created_at >= '2013-01-06' THEN 'B. Post_Product_2'
    ELSE 'check logic'
END as time_period
FROM website_pageviews
WHERE created_at < '2013-04-06' -- date of request
	AND created_at > '2012-10-06' -- 3 month before product 2 launch
    AND pageview_url = '/products'
LIMIT 100000;

-- 2. find the next pageview id that occurs after the product pageview
CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT 
	product_pageviews.time_period,
    product_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) as min_next_pageview_id
FROM product_pageviews
LEFT JOIN website_pageviews ON
website_pageviews.website_pageview_id > product_pageviews.website_pageview_id
	AND website_pageviews.website_session_id = product_pageviews.website_session_id
GROUP BY 1,2
LIMIT 100000;

-- 3. find the pageview_url assocaited with any applicable next pageview id
CREATE TEMPORARY TABLE sessions_w_next_pageview_url
SELECT
    sessions_w_next_pageview_id.time_period,
    sessions_w_next_pageview_id.website_session_id,
    website_pageviews.pageview_url as next_pageview_url
FROM sessions_w_next_pageview_id
LEFT JOIN website_pageviews ON
sessions_w_next_pageview_id.min_next_pageview_id = website_pageviews.website_pageview_id
LIMIT 100000;

-- 4. summarize the data and analyze the pre vs post periods
SELECT
	time_period,
    COUNT(distinct website_session_id) as sessions,
    COUNT(distinct CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) as w_next_pg,
	COUNT(distinct CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(distinct website_session_id) as pct_w_next_pg,
	COUNT(distinct CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) as to_mrfuzzy,
    COUNT(distinct CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/  COUNT(distinct website_session_id) as pct_to_mrfuzzy,
    COUNT(distinct CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) as to_lovebear,
	COUNT(distinct CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/COUNT(distinct website_session_id) as pct_to_lovebear
FROM sessions_w_next_pageview_url
GROUP BY 1
LIMIT 500000;