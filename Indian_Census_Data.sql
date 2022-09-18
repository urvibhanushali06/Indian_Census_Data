Select * from Indian_Census_Data.dbo.Data1;

Select * from Indian_Census_Data.dbo.Data2;

-- Number of rows in our Datasaet
Select count(*) from Indian_Census_Data.dbo.Data1;
Select count(*) from Indian_Census_Data.dbo.Data2;

--Dataset for Jharkhand and Bihar
Select * from Indian_Census_Data.dbo.Data1
where State in ('Jharkhand','Bihar');

--population of India
select SUM(Population) as Population 
from Indian_Census_Data.dbo.Data2;

--Avg Growth
select Avg(Growth)*100 as Avg_Growth 
from Indian_Census_Data.dbo.Data1;

--Avg Growth by State
select State,Avg(Growth)*100 as Avg_Growth 
from Indian_Census_Data.dbo.Data1 
group by State
order by Avg_Growth desc;
   
--Avg Sex R
select State,Round(Avg(Sex_Ratio),0) as Avg_Sex_Ratio 
from Indian_Census_Data.dbo.Data1 
group by State
order by Avg_Sex_Ratio desc;

--Avg Literacy rate
select State,Round(Avg(Literacy),0) as Literacy_Rate 
from Indian_Census_Data.dbo.Data1 
group by State
order by Literacy_Rate desc;

--where clause is used to filter out the rows and it is used onto the rows
--having clause is used on the aggregated rows

--Avg Literacy rate
select State,Round(Avg(Literacy),0) as Literacy_Rate 
from Indian_Census_Data.dbo.Data1 
group by State
having Round(Avg(Literacy),0)>90
order by Literacy_Rate desc;

--Top 3 states 

--1.Highest Growth Ratio
select top 3 State,Avg(Growth)*100 as Avg_Growth 
from Indian_Census_Data.dbo.Data1 
group by State
order by Avg_Growth desc;

--Bottom 3 states
select top 3 State,Avg(Sex_Ratio)*100 as sex_Ratio 
from Indian_Census_Data.dbo.Data1 
group by State
order by sex_Ratio asc;

--Top and Bottom # states by literacy Rate
drop table if exists TopStates
Create table TopStates
( state nvarchar(255),
topstates float
)

Insert into TopStates
select State,Round(Avg(Literacy),0) as Literacy_Rate 
from Indian_Census_Data.dbo.Data1 
group by State
order by Literacy_Rate desc;

Select top 3 * from TopStates order by topstates.topstates desc;

drop table if exists BottomStates
Create table BottomStates
( state nvarchar(255),
bottomstates float
)

Insert into BottomStates
select State,Round(Avg(Literacy),0) as Literacy_Rate 
from Indian_Census_Data.dbo.Data1 
group by State
order by Literacy_Rate desc;

Select top 3 * from BottomStates order by BottomStates.bottomstates asc;

--union operator
Select * from (
Select top 3 * from TopStates order by topstates.topstates desc) a
union
Select * from (
Select top 3 * from BottomStates order by BottomStates.bottomstates asc) b
order by TopStates desc;
;

--Sates starting with letter 'a' oe 'b'
select distinct state from Indian_Census_Data.dbo.Data2
where LOWER (state) like 'a%' or LOWER(state) like 'b%' ;

--joining the tables
--total males and females

--f/m = sex_ratio  
--f+m=population 
--f=population-males 
-- population - males = sex_ratio*males
--population = males(sex_ration +1)
-- males = population/(sex_ration+1)
-- females = population -population/(sex_ratio+1)

select d.state,sum(d.male) as total_males , sum(d.female) total_females from
(select c.District , c.state,round(c.population/(c.sex_ratio+1),0) as male , round(((c.population*c.sex_ratio)/(c.sex_ratio+1)),0) as female from
(select a.District , a.State, a.sex_ratio/1000 sex_ratio , b.population
from Indian_Census_Data.dbo.Data1 a inner join Indian_Census_Data.dbo.Data2 b
on a.District = b.District)c)d
group by d.state;

--total literacy rate
Select c.state,sum(literate_people) total_literate_people ,sum(illiterate_people) total_illiterate_people from
(Select d.district , d.state,round(d.literacy_ratio*d.population,0) literate_people , round((1-d.literacy_ratio)*d.population,0) illiterate_people from
(select a.District , a.State, a.literacy/100 literacy_ratio, b.population
from Indian_Census_Data.dbo.Data1 a inner join Indian_Census_Data.dbo.Data2 b
on a.District = b.District)d)c
group by c.State;

--Population in previous census

--population
--previous_census +growth *previous_census = population
--previous_census = population/(1+growth)
select sum(e.previous_census_population) previous_census_population , sum(e.current_census_population) current_census_population from
(select d.state , sum(d.previous_census_population)previous_census_population , sum(d.current_census_population) current_census_population from
(select c.district,c.state,round(c.population/(1+growth),0) previous_census_population,c.population current_census_population from
(select a.District , a.State,a.Growth, b.population
from Indian_Census_Data.dbo.Data1 a inner join Indian_Census_Data.dbo.Data2 b
on a.District = b.District)c)d
group by d.State)e

--population/area
select g.total_area/g.previous_census_population previous_census_population_area, g.total_area/g.current_census_population current_census_population_area from
(
Select q.*,r.total_area from
(
Select '1' as keyy,n.* from
(select sum(e.previous_census_population) previous_census_population , sum(e.current_census_population) current_census_population from
(select d.state , sum(d.previous_census_population)previous_census_population , sum(d.current_census_population) current_census_population from
(select c.district,c.state,round(c.population/(1+growth),0) previous_census_population,c.population current_census_population from
(select a.District , a.State,a.Growth, b.population
from Indian_Census_Data.dbo.Data1 a inner join Indian_Census_Data.dbo.Data2 b
on a.District = b.District)c)d
group by d.State)e)n)q
inner join
(
select '1' as keyy,z.* from
(Select sum(Area_km2) total_area from Indian_Census_Data.dbo.Data2)z)r
on q.keyy=r.keyy)g

--window
--top 3 districts from each state with highest literacy state
Select a.* from
(select district, state,literacy,rank() over (partition by state order by literacy desc) rnk from Indian_Census_Data..Data1)a
where a.rnk in(1,2,3)
order by State

--Bottom 3 districts from each state with highest literacy state
Select a.* from
(select district, state,literacy,rank() over (partition by state order by literacy asc) rnk from Indian_Census_Data..Data1)a
where a.rnk in(1,2,3)
order by State



