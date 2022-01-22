-- 1, Identify the relevant /cart page views and their sessions
CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT
CASE
	WHEN created_at < '2013-09-25' THEN 'A. Pre_Cross_Sell'
    WHEN created_at >= '2013-01-06' THEN 'B. Post_Cross_Sell'
    ELSE 'check logic'
END as time_period,
	website_session_id as cart_session_id,
    website_pageview_id as cart_pageview_id
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND pageview_url = '/cart'
LIMIT 100000;

CREATE TEMPORARY TABLE cart_sessions_seeing_another_page
SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    MIN(website_pageviews.website_pageview_id) as pv_id_afer_cart
FROM sessions_seeing_cart
	LEFT JOIN website_pageviews ON
	website_pageviews.website_session_id = sessions_seeing_cart.cart_session_id
	AND website_pageviews.website_pageview_id > sessions_seeing_cart.cart_pageview_id
GROUP By
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id
HAVING 
	MIN(website_pageviews.website_pageview_id) IS NOT NULL;

CREATE TEMPORARY TABLE pre_post_sessions_orders
SELECT
	time_period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
FROM sessions_seeing_cart
	INNER JOIN orders
		ON sessions_seeing_cart.cart_session_id = orders.website_session_id;

-- subquery
SELECT 
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NOT NULL THEN 0 ELSE 1 END as clicked_to_another_page,
    CASE WHEN pre_post_sessions_orders.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
FROM sessions_seeing_cart
	LEFT JOIN cart_sessions_seeing_another_page
		ON sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
	LEFT JOIN pre_post_sessions_orders
		ON sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
ORDER BY
	cart_session_id
;

SELECT
	time_period,
    COUNT(distinct cart_session_id) as cart_sessions,
    SUM(clicked_to_another_page) as clickthroughs,
    SUM(clicked_to_another_page)/COUNT(distinct cart_session_id) as cart_ctr,
    SUM(placed_order) as orders_placed,
    SUM(items_purchased) as products_purchased,
    SUM(items_purchased)/SUM(placed_order) as products_per_order,
    SUM(price_usd) as revenue,
    SUM(price_usd)/SUM(placed_order) as aov,
    SUM(price_usd)/COUNT(distinct cart_session_id) as rev_per_cart_session
FROM(
SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_orders.order_id IS NULL THEN 0 ELSE 1 END as placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
FROM sessions_seeing_cart	
LEFT JOIN cart_sessions_seeing_another_page
		ON sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
	LEFT JOIN pre_post_sessions_orders
		ON sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
ORDER BY
	cart_session_id
) as full_data
GROUP BY time_period
