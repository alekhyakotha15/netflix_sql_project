/*counting the no.of total rows in the table*/ 
select count(*) as Total_rows from dbo.netflix_titles;

/*Selecting only top 5 rows of table*/
select top 5 * from dbo.netflix_titles;

/*selecting all rows and columns from table*/
select * from dbo.netflix_titles;

/* selecting only distinct types of movies from data*/
select distinct type from dbo.netflix_titles;

--Answering Business Problems by using SQL queries

--1) Count the Number of movies and Tv shows

select type,count(type) as Total_Number from dbo.netflix_titles
group by type
order by count(type)

--2) Find the most common rating for Movies and Tv Shows

select type, rating
from
(
select 
type,rating,
count(*) as count_rating,
Rank() over(partition by type order by count(*) desc) as ranking
from dbo.netflix_titles
group by type,rating
) as t1
where ranking=1;

--3)List all movies released in a specific year (example : 2021)

select title from dbo.netflix_titles
where release_year=2021 and type='Movie';

--4)Find the top 5 countries with the most content on Netflix

with splitvalue as (
select 
TRIM(value) countries,show_id
from dbo.netflix_titles
cross apply string_split(country,',')
)
select top 5 countries,count(show_id) as Total_Content
from splitvalue
group by countries
order by count(show_id) desc;

--5) Identify the longest movie duration

with converted as(
select show_id, type, duration,
cast(substring(duration,1,charindex(' ',duration)-1) as int) as dminutes
from dbo.netflix_titles where type='Movie'
)
select * from dbo.netflix_titles where 
show_id in (select show_id from converted where dminutes
= (select max(dminutes) from converted)
);

--6) Find content added in the last 5 years

select * from dbo.netflix_titles
where date_added >= Dateadd(YEAR,-5,GETDATE())

--7) Find all the movies/TV shows by director 'Rajiv Chilaka'

with dir as (
select show_id,type, trim(value) directors
from dbo.netflix_titles
cross apply string_split(director,',')
)
select * from dir where directors='Rajiv Chilaka'

--8) List all Tv shows with more than 5 seasons

select * from dbo.netflix_titles where type='TV Show' and 
cast(substring(duration,1,charindex(' ',duration)-1) as INT)>=5;

--9) Count the number of content items in each genre

with split_value as (
select type,Trim(value) list
from dbo.netflix_titles
cross apply string_split(listed_in,',')
)
select count(type) as Total_Content,list from split_value
group by list
order by count(type) desc

--10) Find each year and the average number of content release 
--by india on netflix ( return top 5 year with highest avg content release)

select top 5
country,release_year,
count(show_id) as total_release,
round(cast(count(show_id) as float)/(select count(show_id) from dbo.netflix_titles 
where country='India')*100,2) as avg_release
from dbo.netflix_titles 
where country='India'
group by country,release_year
order by avg_release desc


--11) List all movies that are documentaries
--some are combination of documentary and other genre.
select * from dbo.netflix_titles where listed_in like '%Documentaries%'

--Alone documentaries 
select show_id,title,type,listed_in from dbo.netflix_titles
where listed_in like 'Documentaries'

--12) Find all content without a director

select show_id,title,type,director,listed_in from dbo.netflix_titles
where director is null;

--13) Find how many movies actor 'salman khan' appeared in last 10 years

with split_actor as (
select *,Trim(value) actor
from dbo.netflix_titles
cross apply string_split(cast,',')
)
select * from split_actor
where actor like '%Salman Khan%' and  release_year>year(getdate())-10;

--14) Find the top 10 actors who have appeared in the highest number of movies 
--produced in India.

with splitactors as (
select show_id,type,title,director,Trim(f1.value) as actor, Trim(f2.value)as countries
from dbo.netflix_titles
cross apply string_split([cast],',')f1
cross apply string_split(country,',')f2
)
select top 10 actor,count(type) as Total_Movies from splitactors
where countries like '%India'
group by actor
order by count(type) desc

--15) Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

select category,count(*) as content_count
from
(
select 
	case
		when lower(description) like '%kill%' or lower(description) like '%violence%' then 'Bad'
		else 'Good'
	end as category
from dbo.netflix_titles
) as categorized
group by category;