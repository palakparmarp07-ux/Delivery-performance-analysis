use olist_ecommerce;

create table olist_customers(
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

create table olist_orders(
	order_id varchar(32) PRIMARY KEY,
    customer_id varchar(32),
    order_status varchar(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    
     FOREIGN KEY (customer_id)
        REFERENCES olist_customers(customer_id)
);

create table olist_order_reviews(
	review_id  varchar(32) PRIMARY KEY,
    order_id varchar(32),
    review_score int,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    
	FOREIGN KEY (order_id)
        REFERENCES olist_orders(order_id)
);

ALTER TABLE olist_order_reviews
DROP PRIMARY KEY;	
 


select *from olist_orders
where order_status='delivered';

select count(*) from olist_orders
where order_id is null;

select order_status,count(*) 
from olist_orders
where order_delivered_customer_date is null
group by order_status;

select *  from olist_orders;

 -- query 1: : Calculates delay per order
 
select order_id, order_estimated_delivery_date, order_delivered_customer_date, 
datediff(order_estimated_delivery_date,order_delivered_customer_date) as date_diff
from olist_orders
where order_status='delivered'
	and order_delivered_customer_date is not null;

-- query 2:  Categorizes each order based on delivery

select order_estimated_delivery_date, order_delivered_customer_date,
datediff(order_estimated_delivery_date,order_delivered_customer_date) as date_diff,
case
	when datediff(order_estimated_delivery_date,order_delivered_customer_date)=0 then 'On time'
    when datediff(order_estimated_delivery_date,order_delivered_customer_date)<0 then 'Late delivery'
    when datediff(order_estimated_delivery_date,order_delivered_customer_date)>0 then 'Early delivery'
end as delivery_status
from olist_orders;

-- query 3: Join with reviews
  
  select * from olist_order_reviews;
  
select order_estimated_delivery_date, order_delivered_customer_date,
datediff(order_estimated_delivery_date,order_delivered_customer_date) as date_diff,
case
	when datediff(order_estimated_delivery_date,order_delivered_customer_date)=0 then 'On time'
    when datediff(order_estimated_delivery_date,order_delivered_customer_date)<0 then 'Late delivery'
    when datediff(order_estimated_delivery_date,order_delivered_customer_date)>0 then 'Early delivery'
end as delivery_status,reviews.review_score
from olist_orders as orders
join olist_order_reviews as reviews
	on orders.order_id=reviews.order_id;
    
-- query 4: Average review score by delay bucket

select 
case
	when datediff(order_estimated_delivery_date,order_delivered_customer_date)=0 then 'On time'
    when datediff(order_estimated_delivery_date,order_delivered_customer_date)<0 then 'Late delivery'
    when datediff(order_estimated_delivery_date,order_delivered_customer_date)>0 then 'Early delivery'
end as delivery_status,avg(review_score) as avg_rating
from olist_orders as orders
join olist_order_reviews as reviews
	on orders.order_id=reviews.order_id
where order_status='delivered' and order_delivered_customer_date is not null		
group by delivery_status
order by avg_rating desc;

-- query 5: Groups by state and calculates average delay and average review score per state to see which regions have the worst experience.

select * from olist_customers;
select * from olist_orders;

select 
    customers.customer_state,
    avg(datediff(order_estimated_delivery_date, order_delivered_customer_date)) as avg_delay,
    avg(review_score) as avg_rating
from olist_orders as orders
join olist_order_reviews as reviews
    on orders.order_id = reviews.order_id
join olist_customers as customers
    on orders.customer_id = customers.customer_id
where order_status = 'delivered' 
    and order_delivered_customer_date is not null		
group by customers.customer_state
order by avg_rating asc;


select 
    customers.customer_state,
    count(*) as total_orders,
    sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date) < 0 then 1 else 0 end) as late_orders,
    round(sum(case when datediff(order_estimated_delivery_date, order_delivered_customer_date) < 0 then 1 else 0 end) * 100.0 / count(*), 2) as pct_late,
    avg(review_score) as avg_rating
from olist_orders as orders
join olist_order_reviews as reviews
    on orders.order_id = reviews.order_id
join olist_customers as customers
    on orders.customer_id = customers.customer_id
where order_status = 'delivered' 
    and order_delivered_customer_date is not null		
group by customers.customer_state
order by pct_late desc;