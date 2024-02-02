-- Please note that I am using SQL Server syntax for the queries below

--1. What are the top 5 brands by receipts scanned for most recent month?


-- Get count of each top brand for most recent month
with scanned_brands as 
(select b.brand_nm as brand_name,count(*) brand_count
from
receipt r
join receipt_detail rd on r.receipt_uuid=rd.receipt_uuid
join brand b on rd.brand_uuid=b.brand_uuid and b.top_brand_flg='true'  -- filtering for top brands
where format(r.scan_dt,'yyyy-MM')=(select max(format(r1.scan_dt,'yyyy-MM')) from receipt r1)  -- filter for most recent month
group by  b.brand_nm
)


-- Get top 5 brand
select
TOP 5
scanned_brands
from cte
order by brand_count desc

-- 2. How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?


-- Get count of each top brand for most recent month

with scanned_brands_recent as 
(select b.brand_nm as brand_name,count(*) brand_count
from
receipt r
join receipt_detail rd on r.receipt_uuid=rd.receipt_uuid
join brand b on rd.brand_uuid=b.brand_uuid and top_brand_flg='true'  -- filtering for top brands
where format(r.scan_dt,'yyyy-MM')=(select max(format(r1.scan_dt,'yyyy-MM')) from receipt r1)      -- filter for most recent month
group by  b.brand_nm
),

-- Get count of each top brand for  previous  month

scanned_brands_previous as 
(select b.brand_nm as brand_name,count(*) brand_count
from
receipt r
join receipt_detail rd on r.receipt_uuid=rd.receipt_uuid
join brand b on rd.brand_uuid=b.brand_uuid
where year(r.scan_dt)=(select case when month(max(r1.scan_dt))=1 then year(max(r1.scan_dt))-1 else year(max(r1.scan_dt)) end as max_year from receipt r1)    -- filter for previous month and year
and month(r.scan_dt)=(select case when month(max(r1.scan_dt))=1 then 12 else month(max(r1.scan_dt))-1 end as max_mnt from receipt r1)   
group by  b.brand_nm
),

-- rank based on count of most recent month
scanned_brands_recent_rnk as 
(
select brand_name, brand_count, dense_rank() over (order by brand_count desc) as rnk
from
scanned_brands_recent
),

-- rank based on count of previous month

scanned_brands_previous_rnk as 
(
select brand_name, brand_count, dense_rank() over (order by brand_count desc) as rnk
from
scanned_brands_previous
)


-- Compare both recent month top 5 brands with previous month rank
select
b_rec.brand_name, b_rec.rnk as "Recent Month Rank",b_prev.rnk as "Previous Month Rank"
from scanned_brands_recent_rnk b_rec
join scanned_brands_previous_rnk b_prev on b_rec.brand_name=b_prev.brand_name
where b_rec.rnk<=5


-- 3.  When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

select 
TOP 1
rewards_receipt_status
from (
select rewards_receipt_status,avg(total_spent_amt*1.0) as avg_spend -- Calculating average total spend for each rewards_receipt_status 
from receipt
group by rewards_receipt_status) t
order by t.avg_spend desc

-- 4. When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

select 
TOP 1
rewards_receipt_status
from (
select rewards_receipt_status,sum(purchase_item_cnt) as tot_count   -- Calculating average total purchase item count for each rewards_receipt_status 
from receipt
group by rewards_receipt_status) t
order by t.tot_count desc


-- 5. Which brand has the most spend among users who were created within the past 6 months?


-- Get max created date from user
with cte_max as (
select max(cast(created_dt as date))  as max_dt from user
),


--calcauting total spend for each brand
brand_spend(
select
brand_nm, sum(total_spent_amt) as total_spend 
from receipt r
join user u on r.user_uuid=u.user_uuid
join receipt_detail rd on r.receipt_uuid=rd.receipt_uuid
join brand b on rd.brand_uuid=b.brand_uuid
where created_dt between dateadd(month,-6,(select max_dt from cte_max)) and (select max_dt  from cte_max) -- Filtering for users created in last 6 months 
group by brand_nm
)


-- Calcualting brand with most spend in last 6 months
select brand_nm as brand_name
from 
(select
brand_nm, dense_rank() over (order by total_spend desc) as rnk
from brand_spend) t
where t.rnk=1


-- 6. Which brand has the most transactions among users who were created within the past 6 months?


-- Get max created date from user
with cte_max as (
select max(cast(created_dt as date))  as max_dt from user
),


--calcauting total transactions for each brand
brand_transactions(
select
brand_nm, count(distinct receipt_uuid) as total_trans
from receipt r
join user u on r.user_uuid=u.user_uuid
join receipt_detail rd on r.receipt_uuid=rd.receipt_uuid
join brand b on rd.brand_uuid=b.brand_uuid
where created_dt between dateadd(month,-6,(select max_dt from cte_max)) and (select max_dt from cte_max)  -- Filtering for users created in last 6 months 
group by brand_nm
)

-- Calcualting brand with most transactions in last 6 months

select brand_nm as brand_name
from 
(select
brand_nm, dense_rank() over (order by total_trans desc) as rnk
from brand_transactions) t
where t.rnk=1
