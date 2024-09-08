

select * from db_finance..headphones_Price_Bangladesh t

select count(1) from db_finance..headphones_Price_Bangladesh t
--3080

select t.Company_Name, count(1)C from db_finance..headphones_Price_Bangladesh t
group by t.Company_Name


select * from db_finance..headphones_Price_Bangladesh t
WHERE T.Company_Name LIKE '%?%'
select * from db_finance..headphones_Price_Bangladesh t
--WHERE T.Company_Name IS NULL
WHERE T.Company_Name = ' '

select REPLACE(T.Company_Name, '?','') COMPANY_NAME from db_finance..headphones_Price_Bangladesh t
WHERE T.Company_Name LIKE '%?%'

UPDATE db_finance..headphones_Price_Bangladesh 
SET COMPANY_NAME  = REPLACE(Company_Name, '?','') 
WHERE Company_Name LIKE '%?%'

UPDATE db_finance..headphones_Price_Bangladesh 
SET COMPANY_NAME  = 'Bulls Head'
WHERE Company_Name = ''

select * from
(select t.Company_Name, count(1)C from db_finance..headphones_Price_Bangladesh t
group by t.Company_Name)v
order by v.C desc


--***Find top 15 highest brand in daraz***
with cte as (
select t.Company_Name, count(1) as Brancd_count from db_finance..headphones_Price_Bangladesh t
group by t.Company_Name
)
select * from (
select *
, row_number() over(partition by  Company_Name order by Brancd_count desc) as rn
from cte
) A
where rn<=15



--***Find  brand wise total price***

select * from
(select t.Company_Name, sum(t.dicounted_price)  price from db_finance..headphones_Price_Bangladesh t
group by t.Company_Name)v
order by v.price desc


--***Find most popular colour type wise***
select t.Type, t.Colour , count(1)C from db_finance..headphones_Price_Bangladesh t
group by t.Type,t.Colour 



--***Find sentiment analysis***
select t.sentiment, count(1)C from db_finance..headphones_Price_Bangladesh t
group by t.sentiment


--***Different price range segments for headphones in Bangladesh***
--Ranges: low = less than 500, medium = 500 - 1500, high = 1500+

select * from
(select v1.Price_range, count(1) Number_of_earphone, sum(v1.dicounted_price) Total_Price  from
(select t.Company_Name, 
	case when t.dicounted_price < 500 then 'low'
		 when t.dicounted_price between 500 and 1500 then 'medium'
		 when t.dicounted_price > 1500 then 'high'
		 end price_range, t.dicounted_price
from db_finance..headphones_Price_Bangladesh t)v1
group by v1.price_range)v2
order by v2.Number_of_earphone desc
