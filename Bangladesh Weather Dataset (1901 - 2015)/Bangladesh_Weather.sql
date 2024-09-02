use db_finance
go

--truncate table Temp_and_rain
select count(1) from Temp_and_rain--1380
select * from Temp_and_rain
order by year,month

select min(year) from Temp_and_rain
--1901
select max(year) from Temp_and_rain
--2015


select * from Temp_and_rain



select year, max(tem) max_tem from Temp_and_rain
group by year
order by year
select year, max(rain) max_rain from Temp_and_rain
group by year
order by year


select year, avg(tem) avg_tem from Temp_and_rain
group by year
order by year
select year, avg(rain) avg_rain from Temp_and_rain
group by year
order by year


--find top 5 highest Temperature in each year
with cte as (
select year,month, tem as Temp
from Temp_and_rain
)
select * from (
select *
, row_number() over(partition by year order by Temp desc) as rn
from cte
) A
where rn<=5
order by year,month



--find top 5 highest rain in each year
with cte as (
select year,month, rain as rain
from Temp_and_rain
)
select * from (
select *
, row_number() over(partition by year order by rain desc) as rn
from cte
) A
where rn<=5
order by year,month


--find top 5 lowest Temperature in each year
with cte as (
select year,month, tem as Temp
from Temp_and_rain
)
select * from (
select *
, row_number() over(partition by year order by Temp asc) as rn
from cte
) A
where rn<=5
order by year,month


--find top 5 lowest rain in each year
with cte as (
select year,month, rain as rain
from Temp_and_rain
)
select * from (
select *
, row_number() over(partition by year order by rain asc) as rn
from cte
) A
where rn<=5
order by year,month