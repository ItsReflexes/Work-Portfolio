-- Course Project
use mavenfuzzyfactory; -- database 

-- 1. Pull Monthly Trends for gsearch sessions and orders to showcase growth
-- date = 2012-11-27
SELECT 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    COUNT(DISTINCT website_sessions.website_session_id) as sessions,
    COUNT(DISTINCT orders.order_id) as orders 
FROM website_sessions
	LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 1, 2;

--  2. Split nonbrand sessions and brand campaign sessions seperately
-- Checking for "brand" traffic
-- CASE statement for nonbrand and brand sessions
SELECT 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) as nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.website_session_id ELSE NULL END) as nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) as brand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.website_session_id ELSE NULL END) as brand_orders
FROM website_sessions
	LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY 1, 2;

--  3. From gsearch, pull monthly sessions and orders split by device type
 -- device types: mobile and desktop
 SELECT 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) as mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.website_session_id ELSE NULL END) as mobile_orders,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) as dekstop_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.website_session_id ELSE NULL END) as desktop_orders
FROM website_sessions
	LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1, 2;

-- 4. Pull monthly trends for gsearch and monthly trends for other channels
-- find various utm sources
SELECT distinct
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27';

-- gsearch, bsearch, http_referer
 SELECT 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) as gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) as bsearch_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) as organic_search_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) as direct_search_sessions
FROM website_sessions
	LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;

--  5. Website Performance Improvements (session to order conversion rates by month)
SELECT 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    COUNT(distinct website_sessions.website_session_id) as sessions,
    COUNT(distinct orders.order_id) as orders,
    COUNT(distinct orders.order_id)/COUNT(distinct website_sessions.website_session_id) as conversion_rate
FROM website_sessions
LEFT JOIN orders ON
	orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27' -- arbitrary
GROUP BY 1,2;

-- 6. For gsearch lander test, estimate the revenue that the test produced. (date June 19 - July 28th) (nonbrand sessions)
SELECT
	min(website_pageview_id) as first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';
	-- first_test_pv = 23504

-- Temporary Table Concept to find the first pageview
CREATE temporary Table first_test_pageviews
SELECT
	website_pageviews.website_session_id,
	min(website_pageviews.website_pageview_id) as first_test_pv
FROM website_pageviews
	INNER JOIN website_sessions ON
website_pageviews.website_session_id = website_sessions.website_session_id
	AND website_pageviews.created_at < '2012-07-28'
	AND website_pageviews.created_at > '2012-6-19'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand' -- because we want nonbrand sessions
GROUP BY
	website_pageviews.website_session_id;

-- bring in the landing page to each session, restricting to home or lander-1
CREATE TEMPORARY TABLE sessions_w_landing_pages
SELECT
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url as landing_page
FROM first_test_pageviews
LEFT JOIN website_pageviews ON
website_pageviews.website_pageview_id = first_test_pageviews.first_test_pv
WHERE website_pageviews.pageview_url IN('/home','/lander-1');
 -- SELECT * FROM sessions_w_landing_pages;

-- to estimate revenue, we need to bring in a table for orders
CREATE TEMPORARY TABLE sessions_w_orders
SELECT
    orders.order_id as order_id,
    sessions_w_landing_pages.website_session_id,
    sessions_w_landing_pages.landing_page
FROM sessions_w_landing_pages
LEFT JOIN orders ON
orders.website_session_id = sessions_w_landing_pages.website_session_id
GROUP BY 2;
SELECT * FROM sessions_w_orders;

-- add a coversion rate for the orders
SELECT
	landing_page,
	COUNT(distinct order_id) as orders,
    COUNT(distinct website_session_id) as sessions,
    COUNT(distinct order_id)/COUNT(distinct website_session_id) as conv_rate
FROM sessions_w_orders
GROUP BY 1;

SELECT 
	COUNT( website_session_id) as sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
AND website_session_id > 17145 -- max website session
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand';
-- 22,972 website sessions since the test of June 19th

-- 7. For the previous landing page test, produce a full conversion funnel from each of the two pages to orders. (Jun 19th - July 28th)

CREATE TEMPORARY TABLE sessions_that_made_it
SELECT
website_session_id,
	MAX(products_page) as product_made_it,
    MAX(mrfuzzy_page) as mrfuzzy_made_it,
    MAX(cart_page) as cart_made_it,
    MAX(homepage) as saw_homepage,
    MAX(custom_lander) as saw_custom_lander,
    MAX(shipping_page) as shipping_made,
    MAX(billing_page) as billing_made,
    MAX(thankyou_page) as thankyou_made
FROM (
    SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_pageviews.created_at AS pageview_created_at,
		CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END as products_page,
        CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END as mrfuzzy_page,
        CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END as homepage,
        CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END as cart_page,
        CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END as shipping_page,
        CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END as billing_page,
        CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END as custom_lander,
        CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END as thankyou_page
FROM website_sessions
		LEFT JOIN website_pageviews ON 
			website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-07-28' 
AND website_sessions.created_at > '2012-06-19' -- arbitrary
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY
	website_sessions.website_session_id
    ) as pageview_level
		GROUP BY
				website_session_id;

--  final output
SELECT 
	CASE 
		WHEN saw_homepage = 1 THEN 'homepage_seen'
        WHEN saw_custom_lander = 1 THEN 'lander_seen'
        ELSE 'check logic'
	END as segment,
    COUNT(distinct website_session_id) as sessions,
    COUNT(distinct case when product_made_it = 1 THEN website_session_id ELSE NULL END) as to_products,
	COUNT(distinct case when mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) as to_mrfuzzy,
	COUNT(distinct case when cart_made_it = 1 THEN website_session_id ELSE NULL END) as to_cart,
    COUNT(distinct case when shipping_made = 1 THEN website_session_id ELSE NULL END) as to_shipping,
	COUNT(distinct case when billing_made = 1 THEN website_session_id ELSE NULL END) as to_billing,
	COUNT(distinct case when thankyou_made = 1 THEN website_session_id ELSE NULL END) as to_thankyou
FROM sessions_that_made_it
GROUP BY 1;

-- final output / click rates
SELECT 
	CASE 
		WHEN saw_homepage = 1 THEN 'homepage_seen'
        WHEN saw_custom_lander = 1 THEN 'lander_seen'
        ELSE 'check logic'
	END as segment,
    COUNT(distinct website_session_id) as sessions,
    COUNT(distinct case when product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct website_session_id) as lander_click_rt,
	COUNT(distinct case when mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct case when product_made_it = 1 THEN website_session_id ELSE NULL END) as products_rate,
	COUNT(distinct case when cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct case when mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) as mrfuzzy_rate,
    COUNT(distinct case when shipping_made = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct case when cart_made_it = 1 THEN website_session_id ELSE NULL END) as cart_rate,
	COUNT(distinct case when billing_made = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct case when shipping_made = 1 THEN website_session_id ELSE NULL END) as shipping_rate,
	COUNT(distinct case when thankyou_made = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct case when billing_made = 1 THEN website_session_id ELSE NULL END) as billing_rate
FROM sessions_that_made_it
GROUP BY 1;

-- Quanitfy the impact of our billing test, analyze the lift generated from (Sep 10 - Nov 10) by revenue per billing page session, 
-- Then pull the number of billing page sessions for the past month to understand impact.

SELECT 
	billing_version_seen,
    COUNT(distinct website_session_id) as seesions,
    SUM(price_usd)/COUNT(distinct website_session_id) as revenue_per_billing
FROM(
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url as billing_version_seen,
    orders.order_id,
    orders.price_usd
FROM website_pageviews
LEFT JOIN orders ON
orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10'
AND website_pageviews.created_at < '2012-11-10' -- arbitrary
AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
) as billing_pageviews_and_order_data
GROUP BY 1;
-- billing : $22.83
-- billing-2 : $31.34
-- LIFT: $8.51

SELECT
	COUNT(website_session_id) as billing_sessions_past_month
FROM website_pageviews
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2')
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27' -- past month
    
-- 1,194 billing sessions
-- LIFT: $8.51 per billing session
-- $10,160 value over the past month ( 1,194 * $8.51) VALUE OF BILLING TEST
