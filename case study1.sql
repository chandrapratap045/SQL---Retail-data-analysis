use db_SQLCaseStudies;

select * from customer;
select * from Transactions;
select * from prod_cat_info;

--DATA PREPARATION AND UNDERSTANDING

--Ques.1
select 'CUST_TABLE' as ALL_TABLES , count(customer_Id) as TOT_RECORDS from Customer
union all
select 'TRANS_TABLE',count(transaction_id) from Transactions
union all
select 'PROD_CAT_TABLE',count(*) from prod_cat_info;

--Ques.2
select count(transaction_id) as TOT_RETURN_TRANS
from Transactions
where cast( total_amt as float) < 0; 

--Ques.3
select
DOB,
convert(date,DOB,105) as CONVERTED_DOB,
TRAN_DATE,
convert(date,tran_date,105) as CONVERTED_TRAN_DATE
from customer inner join Transactions on customer_id = cust_id;

--Ques.4
select
datediff(day,min(convert(date,tran_date,105)),max(convert(date,tran_date,105))) NO_OF_DAYS,
datediff(month,min(convert(date,tran_date,105)),max(convert(date,tran_date,105))) NO_OF_MONTHS,
datediff(year,min(convert(date,tran_date,105)),max(convert(date,tran_date,105))) NO_OF_YEARS
from Transactions;

--Ques.5
select
PROD_SUBCAT,PROD_CAT
from prod_cat_info
where prod_subcat = 'DIY';

--DATA ANALYSIS

--Ques.1
select * from 
(
select
ROW_NUMBER() over(order by count(transaction_id) desc) as RNUM,
store_type,
count(transaction_id) as Tot_Trans
from Transactions
group by store_type ) as T1
where rnum = 1;

--Ques.2
select GENDER, count(customer_id) as CNT_OF_CUST
from customer
where gender in ('M','F')
group by gender;

--Ques.3
select 
TOP 1 CITY_CODE,count(Customer_id) as NO_OF_CUST
from customer
group by city_code
order by NO_OF_CUST desc;

--Ques.4
select prod_cat CATEGORY,
count(prod_sub_cat_code) CNT_OF_SUBCAT	
from prod_cat_info
where prod_cat = 'Books'
group by prod_cat;


--Ques.5
select max(qty) as MAX_QTY
from Transactions;

--Ques.6
select prod_cat as CATEGORY,
sum(cast(total_amt as float)) as TOT_REVENUE
from prod_cat_info A inner join Transactions B on
A.prod_cat_code = B.prod_cat_code and A.prod_sub_cat_code = B.prod_subcat_code
where prod_cat in ('Electronics','Books')
group by prod_cat;


--Ques.7
select count(CUST_ID) as NO_OF_CUST from (
select
CUST_ID,
count(transaction_id) as NO_OF_TRANS
from Transactions
where cast(total_amt as float) > 0
group by CUST_ID
having count(transaction_id)>10
) as T1;


--Ques.8
select
'ELECTRONICS AND CLOTHING' as CATEGORY,
sum(cast(total_amt as float)) as TOT_REVENUE
from prod_cat_info A inner join Transactions B
on prod_sub_cat_code = prod_subcat_code and A.prod_cat_code = B.Prod_cat_code 
where prod_cat in ('Electronics','Clothing') and store_type = 'flagship store';


--Ques.9
select
PROD_SUBCAT SUB_CATEGORY,
sum(round(cast(total_amt as float),2)) as TOT_REVENUE
from prod_cat_info A inner join Transactions B
on prod_subcat_code = prod_sub_cat_code and A.prod_cat_code = B.prod_cat_code
inner join customer on customer_Id = cust_id
where Gender = 'M' and prod_cat = 'Electronics'
group by prod_subcat;

--Ques.10 : What is the percentage of Sales and returns by product sub-categories; Display only top 5 sub categories in terms of Sales
select
TOP 5
prod_subcat as SUB_CATEGORY,
round(sum(case when cast(total_amt as float) >=0 then cast(total_amt as float) end) / 
(select sum(cast(total_amt as float)) from Transactions)*100,2) as [% SALES],
round(sum(case when cast(total_amt as float) < 0 then abs(cast(total_amt as float)) end) / 
(select sum(cast(total_amt as float)) from Transactions)*100,2) as [% RETURNS]
from prod_cat_info A inner join Transactions B
on prod_subcat_code = prod_sub_cat_code and A.prod_cat_code = B.prod_cat_code
group by prod_subcat
order by [% SALES] desc;

--Ques.11
select
datediff(year,convert(date,DOB,105),getdate()) CUST_AGE,
sum(cast(total_amt as float)) as TOT_REVENUE
from Customer inner join Transactions on
customer_id = cust_id
where datediff(year,convert(date,DOB,105),getdate()) between 25 and 35
and convert(date,tran_date,105) >= (select dateadd(day,-30,max(convert(date,tran_date,105))) from Transactions)
group by datediff(year,convert(date,DOB,105),getdate());

--Ques.12
select
TOP 1 prod_cat as CATEGORY,
SUM(cast(total_amt as float)) as SALES_AMT
from Transactions A inner join prod_cat_info B
on prod_sub_cat_code = prod_subcat_code and B.prod_cat_code = A.prod_cat_code
where cast(total_amt as float) < 0 and
convert(date,tran_date,105) >= (select dateadd(month,-3,max(convert(date,tran_date,105))) from Transactions)
group by prod_cat
order by SALES_AMT;

--Ques.13
select
TOP 1
STORE_TYPE,
ROUND(sum(cast(total_amt as float)),2) as TOT_SALES_AMT,
sum(cast(qty as float)) TOT_QTY_SOLD
from Transactions
group by store_type
order by TOT_SALES_AMT desc, TOT_QTY_SOLD desc;

--Ques.14
select
prod_cat as CATEGORY,
avg(cast(total_amt as float)) as AVG_REVENUE
from Transactions A
inner join prod_cat_info B
on prod_sub_cat_code = prod_subcat_code and A.prod_cat_code = B.prod_cat_code
group by prod_cat
having avg(cast(total_amt as float)) > (select avg(cast(total_amt as float)) from Transactions);

--Ques.15
select PROD_SUBCAT,
avg(cast(total_amt as numeric)) as AVG_REVENUE,
sum(cast(total_amt as numeric)) as TOT_REVENUE
from Transactions A inner join prod_cat_info B on
A.prod_cat_code = B.prod_cat_code and prod_subcat_code = prod_sub_cat_code
where A.prod_cat_code in
(
select TOP 5
prod_cat_code from Transactions
group by prod_cat_code
order by sum(cast(qty as int)) desc
)
group by prod_subcat;