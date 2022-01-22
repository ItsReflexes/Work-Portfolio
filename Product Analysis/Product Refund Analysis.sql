-- Pull monthly product refund rates , by product
-- confirm if the quality issues are fixed
-- date until 09/2013, replaced the quality issues on 09/16/2014


use mavenfuzzyfactory;
SELECT
	YEAR(order_items.created_at) as yr,
    MONTH(order_items.created_at) as mo,
    COUNT(distinct case when product_id = 1 THEN order_items.order_item_id ELSE NULL END) as p1_orders,
	COUNT(distinct case when product_id = 1 THEN order_item_refunds.order_item_id ELSE NULL END)
		/COUNT(distinct case when product_id = 1 THEN order_items.order_item_id ELSE NULL END) as p1_refund_rt,
	COUNT(distinct case when product_id = 2 THEN order_items.order_item_id ELSE NULL END) as p2_orders,
	COUNT(distinct case when product_id = 2 THEN order_item_refunds.order_item_id ELSE NULL END)
		/COUNT(distinct case when product_id = 2 THEN order_items.order_item_id ELSE NULL END) as p2_refund_rt,
	COUNT(distinct case when product_id = 3 THEN order_items.order_item_id ELSE NULL END) as p3_orders,
	COUNT(distinct case when product_id = 3 THEN order_item_refunds.order_item_id ELSE NULL END)
		/COUNT(distinct case when product_id = 3 THEN order_items.order_item_id ELSE NULL END) as p3_refund_rt,
	COUNT(distinct case when product_id = 4 THEN order_items.order_item_id ELSE NULL END) as p4_orders,
	COUNT(distinct case when product_id = 4 THEN order_item_refunds.order_item_id ELSE NULL END)
		/COUNT(distinct case when product_id = 4 THEN order_items.order_item_id ELSE NULL END) as p4_refund_rt
FROM order_items
	LEFT JOIN order_item_refunds
ON order_items.order_item_id = order_item_refunds.order_item_id
WHERE order_items.created_at < '2014-10-15' -- date of request
GROUP By 1,2