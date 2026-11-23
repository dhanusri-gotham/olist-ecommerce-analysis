select coalesce(t.product_category_name_english, p.product_category_name) as category,
  count(*) as items_sold,
  round(sum(i.price), 2) as revenue
from olist_order_items_dataset i
join olist_orders_dataset o on i.order_id = o.order_id
join olist_products_dataset p on i.product_id = p.product_id
left join product_category_name_translation t on p.product_category_name = t.product_category_name
where o.order_status = 'delivered'
group by category order by revenue desc;
use olist;

select c.customer_state,
  count(*) as orders,
  round(sum(r.revenue), 2) as revenue,
  round(avg(datediff(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) as avg_days,
  round(100 * sum(o.order_delivered_customer_date > o.order_estimated_delivery_date) / count(*), 2) as late_pct
from olist_orders_dataset o
join olist_customers_dataset c on o.customer_id = c.customer_id
join (select order_id, sum(price) as revenue from olist_order_items_dataset group by order_id) r
  on o.order_id = r.order_id
where o.order_status = 'delivered' and o.order_delivered_customer_date is not null
group by c.customer_state order by revenue desc;

select case when o.order_delivered_customer_date > o.order_estimated_delivery_date
       then 'Late' else 'On time' end as delivery,
  count(*) as orders,
  round(avg(r.review_score), 2) as avg_score
from olist_orders_dataset o
join olist_order_reviews_dataset r on o.order_id = r.order_id
where o.order_status = 'delivered' and o.order_delivered_customer_date is not null
group by delivery;