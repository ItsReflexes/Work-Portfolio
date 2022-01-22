-- Product Conversion Funnels
-- Analyze the conversion funnels from each product page to conversion
-- Compare the two conversion funnels, for all website traffic

-- 1 , select all pageviews for relevant sessions
CREATE TEMPORARY TABLE sessions_seeing_product_pages
SELECT
	website_session_id,
    website_pageview_id,
    pageview_url as product_page_seen
FROM website_pageviews
WHERE created_at < '2013-04-10'
	AND created_at > '2013-01-06'
    AND pageview_url IN('/the-original-mr-fuzzy', '/the-forever-love-bear')
LIMIT 100000;

-- 2, find the right pageview_urls to build the funnel
SELECT distinct
	website_pageviews.pageview_url
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews ON
    website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
    AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id;
 -- '/cart', '/shipping', '/billing-2' ,'/thank-you-for-your-order'

-- 3, make use of a subquery to look over the pageview-level results
SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
		CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END as cart_page,
        CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END as shipping_page,
        CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END as billing_page,
        CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END as thankyou_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews ON
    website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
    AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
ORDER BY 
	sessions_seeing_product_pages.website_session_id,
    website_pageviews.created_at;
 
 -- TEMP TABLE w/ subquery
 
CREATE TEMPORARY TABLE session_product_level_made_it
SELECT
	website_session_id,
CASE 
	WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
    WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
    ELSE 'check logic'
    END as product_seen,
    MAX(cart_page) as cart_made_it,
    MAX(shipping_page) as shipping_made_it,
    MAX(billing_page) as billing_made_it,
    MAX(thankyou_page) as thankyou_made_it
FROM(
SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
		CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END as cart_page,
        CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END as shipping_page,
        CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END as billing_page,
        CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END as thankyou_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews ON
    website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
    AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
ORDER BY 
	sessions_seeing_product_pages.website_session_id,
    website_pageviews.created_at
) as pageview_level
GROUP BY 
	website_session_id,
    CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
		WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
		ELSE 'check logic'
	END
;
-- final analysis part 1
SELECT
	product_seen,
    COUNT(distinct website_session_id) as sessions,
    COUNT(distinct case when cart_made_it = 1 THEN website_session_id ELSE NULL END) as to_cart,
    COUNT(distinct case when shipping_made_it = 1 THEN website_session_id ELSE NULL END) as to_shipping,
	COUNT(distinct case when billing_made_it = 1 THEN website_session_id ELSE NULL END) as to_billing,
	COUNT(distinct case when thankyou_made_it = 1 THEN website_session_id ELSE NULL END) as to_thankyou
FROM session_product_level_made_it
GROUP BY 1;

-- Translate the output to rates
SELECT
	product_seen,
    COUNT(distinct case when cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct website_session_id) as product_page_rate,
    COUNT(distinct case when shipping_made_it = 1 THEN website_session_id ELSE NULL END)/ COUNT(distinct case when cart_made_it = 1 THEN website_session_id ELSE NULL END) as cart_click_rate,
	COUNT(distinct case when billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct case when shipping_made_it = 1 THEN website_session_id ELSE NULL END) as shipping_click_rate,
	COUNT(distinct case when thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(distinct case when billing_made_it = 1 THEN website_session_id ELSE NULL END) as billing_click_rate
FROM session_product_level_made_it
GROUP BY 1;
 
	