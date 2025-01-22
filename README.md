# Netflix Tv Shows and Movies data analysis using SQL
![](https://github.com/alekhyakotha15/netflix_sql_project/blob/main/logo.png)
## Overview
This project involves analysis of Netflix's Movies and Tv Shows data using SQL. The main goal of working on this project is to extract valuable insights which are used to answer some important business problems. The following README provides a detailed account of my project's objective, business problems, solutions, approach and conclusions.

## Objectives

- Analyzing different content present in Netflix. (Movies vs Tv Shows)
- Identifying genre wise content present along with the top genre with most number of content.
- Listing and analzsing content based on release years, countries and also durations.
- Categorizing data based on specific keywords.
- Finding top n actors who appeared in most content produced by specific country.

## Dataset

The data for this project is collected from Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## My Approach
  I have imported the relevant dataset into my SQL Server. Below shows my way of answering some business problems which are very important to identify in order to build relevant business strategics.

## Business Problems and Solutions

### 1) Counting the Number of movies and Tv shows

'''select type,count(type) as Total_Number from dbo.netflix_titles
group by type
order by count(type)'''

**Objective:** To Determine the distribution of Content in Netflix.

### 2)List all Tv Shows released in a specific year (example : 2019)

'''select title from dbo.netflix_titles
where release_year=2021 and type='TV Show';'''

**Objective:** To retrieve all Tv shows in a specific year.

### 3)Finding the most common rating for Movies and Tv Shows

'''select type, rating
from
(
select 
type,rating,
count(*) as count_rating,
Rank() over(partition by type order by count(*) desc) as ranking
from dbo.netflix_titles
group by type,rating
) as t1
where ranking=1;'''

**Objective:** To identify what is most common rating in Netflix.

### 4) Identifying the longest movie duration

'''with converted as(
select show_id, type, duration,
cast(substring(duration,1,charindex(' ',duration)-1) as int) as dminutes
from dbo.netflix_titles where type='Movie'
)
select * from dbo.netflix_titles where 
show_id in (select show_id from converted where dminutes
= (select max(dminutes) from converted))'''

**Objective:** To find the longest movie present in Netflix.

### 5) List all Tv shows with more than n seasons ( example : 5 seasons)

'''select * from dbo.netflix_titles where type='TV Show' and 
cast(substring(duration,1,charindex(' ',duration)-1) as INT)>=5;'''

**Objective:** To find the Tv show with certain number of shows.

### 6)Finding the top 5 countries with the least content on Netflix

'''with splitvalue as (
select 
TRIM(value) countries,show_id
from dbo.netflix_titles
cross apply string_split(country,',')
)
select top 5 countries,count(show_id) as Total_Content
from splitvalue
group by countries
order by count(show_id);'''

**Objective:** To find the least performing countries to take certain action.

### 7) Finding content added to Netflix in the last 5 years

'''select * from dbo.netflix_titles
where date_added >= Dateadd(YEAR,-5,GETDATE())'''

**Objective:** To identify the content added in last n number of years which is key factor to attract customers.

### 8) Finding all the movies/TV shows by director 'Rajiv Chilaka'

'''with dir as (
select show_id,type, trim(value) directors
from dbo.netflix_titles
cross apply string_split(director,',')
)select * from dir where directors='Rajiv Chilaka'''

**Objective:** To find the content directed by specific director.

### 9) Counting the number of content items in each genre

'''with split_value as (
select type,Trim(value) list
from dbo.netflix_titles
cross apply string_split(listed_in,',')
)
select count(type) as Total_Content,list from split_value
group by list
order by count(type) desc'''

**Objective:** To identify which genre has most content in Netflix

### 10) List all movies that are documentaries
### some are combination of documentary and other genre.
'''select * from dbo.netflix_titles where listed_in like '%Documentaries%'''

### Alone documentaries 
'''select show_id,title,type,listed_in from dbo.netflix_titles
where listed_in like 'Documentaries'''

**Objective:** To identify all content related to one genre.

### 11) Finding all content without a director

'''select show_id,title,type,director,listed_in from dbo.netflix_titles
where director is null;'''

**Objective:** To find content who director has not been listed.

### 12) Finding how many movies actor 'salman khan' appeared in last 10 years

'''with split_actor as (
select *,Trim(value) actor
from dbo.netflix_titles
cross apply string_split(cast,',')
)
select * from split_actor
where actor like '%Salman Khan%' and  release_year>year(getdate())-10;'''

**Objective:** To find out particular actors content present in Netflix

### 13) Find the top 10 actors who have appeared in the highest number of movies produced in United States.

'''with splitactors as (
select show_id,type,title,director,Trim(f1.value) as actor, Trim(f2.value)as countries
from dbo.netflix_titles
cross apply string_split([cast],',')f1
cross apply string_split(country,',')f2
)
select top 10 actor,count(type) as Total_Movies from splitactors
where countries like 'United States'
group by actor
order by count(type) desc'''

**Objective:** To list top n actors who appeared in content produced by United States.

### 14) Finding each year and the average number of content release by Canada on netflix ( return top 5 year with highest avg content release)

'''select top 5
country,release_year,
count(show_id) as total_release,
round(cast(count(show_id) as float)/(select count(show_id) from dbo.netflix_titles 
where country='Canada')*100,2) as avg_release
from dbo.netflix_titles 
where country='Canada'
group by country,release_year
order by avg_release desc'''

**Objective:** To find top 5 years of avg content release by Canada

### 15) Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

'''select category,count(*) as content_count
from
(
select 
	case
		when lower(description) like '%Driver%' or lower(description) like '%violence%' then 'Bad'
		else 'Good'
	end as category
from dbo.netflix_titles
) as categorized
group by category;'''

**Objective:** To categorize content based on certain keywords.

