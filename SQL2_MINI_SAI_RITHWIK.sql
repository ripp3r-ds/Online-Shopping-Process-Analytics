#Q1)
#all tables combined view using joins
select * from market_fact m 
join cust_dimen d on m.Cust_id=c.Cust_id  
join orders_dimen o on o.Ord_id=m.Ord_id
join prod_dimen p on p.Prod_id=m.Prod_id
join shipping_dimen s on s.Ship_id=m.Ship_id;

#Q2)
#top 3 cust_ids with max number of orders... (all multi-item orders are treated as one distinct order)
select cust_id from 
(select cust_id,row_number() over(order by c desc) ran from 
(select  Cust_id,count(distinct ord_id) c from market_fact group by Cust_id)co)d where ran<4;

#Q3)
#new query for viewing days taken to ship (under column name DaysTakenForDelivery) for each order_id
select s.order_id,datediff(str_to_date(s.ship_date,'%d-%m-%Y'),str_to_date(o.order_date,'%d-%m-%Y')) DaysTakenForDelivery 
from shipping_dimen s 
join orders_dimen o on o.Order_ID=s.Order_ID
order by DaysTakenForDelivery desc;


#Q4)
#customer ID whose order took the longest time to ship....
#using above query for DaysTakenForDelivery and fetching the cust_id for the order through sub queries
select cust_id from market_fact
where Ord_id = 
(select Ord_id from orders_dimen where Order_ID = 
any(select Order_ID from (select s.order_id,
datediff(str_to_date(s.ship_date,'%d-%m-%Y'),str_to_date(o.order_date,'%d-%m-%Y')) DaysTakenForDelivery 
from shipping_dimen s 
join orders_dimen o on o.Order_ID=s.Order_ID
order by DaysTakenForDelivery desc
limit 1)de));

#Q5)
#total sales for each product is displayed alongside product and its sale for each order...
select ord_id,prod_id,sales,sum(sales) over(partition by Prod_id) toal_prod_sale from market_fact;

#Q6)
#total profit for each product is displayed alongside product and its profit for each sale for each order...
select ord_id,prod_id,Profit,sum(Profit) over(partition by Prod_id) toal_prod_profit from market_fact;

#Q7)
#total no. of unique customers who made atleast one order in jan 2011...
select count(distinct cust_id) uniq_jan_cust from market_fact
where Ord_id=any(select Ord_id from orders_dimen where str_to_date(order_date,'%d-%m-%Y') between '2011-01-01'
and '2011-01-31');
#total customers who came bank every month in 2011..
# we calculate dense rank over each month number for every unique customer
# thus january ie 1 gets rank 1 february ie 2 get rank 2 and so on
# if customer ordered every month from jan to dec then his rank from dec ie 12th month will be 12....
select Cust_id from
(select cust_id,o.order_date,month(str_to_date(order_date,'%d-%m-%Y')) order_month,
dense_rank() over(partition by Cust_id order by month(str_to_date(order_date,'%d-%m-%Y'))) rnk
from market_fact m
join orders_dimen o on o.Ord_id= m.Ord_id
where str_to_date(order_date,'%d-%m-%Y') between '2011-01-01'
and '2011-12-31')m
where order_month=12 and rnk=12;











