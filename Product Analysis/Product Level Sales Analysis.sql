-- Sales Trends
-- Pull Monthly Trends for sales, revenue, and total margin generated
-- 1/04/2013 date range

SELECT
	YEAR(created_at) as yr,
    MONTH(created_at) as mo,
    COUNT(order_id) as number_of_sales,
    SUM(price_usd) as total_revenue,
    SUM(price_usd - cogs_usd) as total_margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY 1,2