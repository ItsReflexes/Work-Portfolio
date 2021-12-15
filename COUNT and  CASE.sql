SELECT 
primary_product_id,
COUNT(distinct CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS single_item_orders,
COUNT(Distinct CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS two_item_orders
 FROM orders
WHERE order_id BETWEEN 31000 and 32000
GROUP BY 1