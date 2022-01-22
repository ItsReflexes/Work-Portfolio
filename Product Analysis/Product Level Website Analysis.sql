

SELECT distinct
	-- website_session_id,
    website_pageviews.pageview_url,
    COUNT(distinct website_pageviews.website_session_id) as sessions,
    COUNT(distinct order_id) as orders,
    COUNT(distinct order_id)/ COUNT(distinct website_pageviews.website_session_id) as viewed_product_to_order_rate
FROM website_pageviews
	LEFT JOIN orders ON
    orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at BETWEEN '2013-02-01' AND '2013-03-01'
	AND website_pageviews.pageview_url IN('/the-original-mr-fuzzy', '/the-forever-love-bear')
group by 1
