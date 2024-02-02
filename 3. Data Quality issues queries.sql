-- I find the dates in the files to be incorrect. Below is the query I would use to do data quality check on the date columns in receipt and user table

-- Query to check if purchase_dt, scan_dt, finish_dt, modified_dt,points_award_dt is valid or not
--    I am taking anything after 2013-01-01 as valid since Fetch was founded in 2013 according to Linkedin
select
case when 
isdate(purchase_dt)=1 and purchase_dt between '2013-01-01' and getdate() then 'Valid'
else 'Invalid' end as "Purchase Date Flag",
case when 
isdate(scan_dt)=1 and scan_dt between '2013-01-01' and getdate() then 'Valid'
else 'Invalid' end as "Scan Date Flag",
case when 
isdate(finish_dt)=1 and finish_dt between '2013-01-01' and getdate() then 'Valid'
else 'Invalid' end as "Finish Date Flag",
case when 
isdate(created_dt)=1 and created_dt between '2013-01-01' and getdate() then 'Valid'
else 'Invalid' end as "Created Date Flag",
case when 
isdate(modified_dt)=1 and modified_dt between '2013-01-01' and getdate() then 'Valid'
else 'Invalid' end as "Modified Date Flag",
case when 
isdate(points_award_dt)=1 and points_award_dt between '2013-01-01' and getdate() then 'Valid'
else 'Invalid' end as "Points Awarded Date Flag",
from receipt


-- 2. Query to check if last_login_dt and created_dt are valid dates from user

select
case when 
isdate(last_login_dt)=1 and last_login_dt between '2013-01-01' and getdate() then 'Valid'
else 'Invalid' end as "Last Login Date Flag",
case when 
isdate(created_dt)=1 and created_dt between '2013-01-01' and getdate() then 'Valid'
else 'Invalid' end as "Created Date Flag",
from user


