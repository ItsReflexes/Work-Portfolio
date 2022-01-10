-- Building Conversion Funnels & Conversion Paths
 -- sessions ids, pageview_url 
 -- track where the volume has ended on each page
--  MAX(shipping_page) as shipping_made_it,
 --   MAX(billing_page) as billing_made_it,
--    MAX(thankyou_page) as thankyou_made_it
use mavenfuzzyfactory;
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
		CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END as products_page,
        CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END as mrfuzzy_page,
        CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END as cart_page
FROM website_sessions
		LEFT JOIN website_pageviews ON 
			website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- arbitrary
	AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	website_sessions.website_session_id;
    
-- subquery   
SELECT 
	website_session_id,
	MAX(products_page) as product_made_it,
    MAX(mrfuzzy_page) as mrfuzzy_made_it,
    MAX(cart_page) as cart_made_it
FROM(
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
		CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END as products_page,
        CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END as mrfuzzy_page,
        CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END as cart_page
FROM website_sessions
		LEFT JOIN website_pageviews ON 
			website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- arbitrary
	AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	website_sessions.website_session_id
    ) as pageview_level
		GROUP BY
				website_session_id;
-- temp table option
CREATE Temporary Table session_level_made_it_flags_demo
SELECT 
	website_session_id,
	MAX(products_page) as product_made_it,
    MAX(mrfuzzy_page) as mrfuzzy_made_it,
    MAX(cart_page) as cart_made_it
FROM(
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
		CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END as products_page,
        CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END as mrfuzzy_page,
        CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END as cart_page
FROM website_sessions
		LEFT JOIN website_pageviews ON 
			website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- arbitrary
	AND website_pageviews.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	website_sessions.website_session_id
    ) as pageview_level
		GROUP BY
				website_session_id;
-- TEST 
SELECT * FROM session_level_made_it_flags_demo;
-- FINAL OUTPUT (counting website sessions w/ flagged as 1 for products, mrfuzzy, and cart)
SELECT 
COUNT(distinct website_session_id) as sessions,
COUNT(distinct case when product_made_it = 1 THEN website_session_id ELSE NULL END) as to_products,
COUNT(distinct case when mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) as to_mrfuzzy,
COUNT(distinct case when cart_made_it = 1 THEN website_session_id ELSE NULL END) as to_cart
FROM session_level_made_it_flags_demo;

-- Translate the count of sessions to click rates
SELECT 
COUNT(distinct website_session_id) as sessions,
COUNT(distinct case when product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct website_session_id) as lander_clickthrough_rate,
COUNT(distinct case when mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct case when product_made_it = 1 THEN website_session_id ELSE NULL END) as product_clickthrough_rate,
COUNT(distinct case when cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct case when mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) as mrfuzzy_clickthrough_rate
FROM session_level_made_it_flags_demo;