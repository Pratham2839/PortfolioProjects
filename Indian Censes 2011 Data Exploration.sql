
-- About this project : --
--In this project i have extracted the data of Indian censes of 2011 and carried out some basic quieries and some advnace queries. I have used concepts of sub queries, temp table, window functions and also used some basic algebra to come up with certain new columns of data--

-- Viewing the datasets-- 
select * from [Portfolio Project ].dbo.data1 
select * from [Portfolio Project ].dbo.data2

--To know the no. of rows in the dataset--
select count(*) from [Portfolio Project ].dbo.data1

-- Data for Maharashtra -- 
select * from [Portfolio Project ].dbo.data1
where state in ('Maharashtra')

--Population of india--
select sum(Population) as Total_Population_India
from [Portfolio Project ].dbo.data2


-- Average Population Growth Of India--
select Avg(Growth)*100 as Average_Growth_Rate from [Portfolio Project ].dbo.data1

-- Average Population Growth Of Each State--
select State, round(Avg(Growth),3) *100 as Avg_Growth from [Portfolio Project ].dbo.data1 group by State Order by Avg_Growth desc

-- Average Sex ratio Of Each State--
select State, round(Avg(Sex_Ratio),0) as Avg_Sex_Ratio from [Portfolio Project ].dbo.data1 group by State Order by Avg_Sex_Ratio desc

-- Average Literacy ratio Of State--
select State, round(Avg(Literacy),0) as Literacy_Ratio from [Portfolio Project ].dbo.data1 group by State Having round(Avg(Literacy),0)>60 Order by Literacy_Ratio desc;


--Q 1 : Growth Rate By State -- 

select  State, round(Avg(Growth),3) *100 as Bottom_5_Growth_Rate from [Portfolio Project ].dbo.data1 group by State Order by Bottom_5_Growth_Rate desc


-- Q2 :  Top 5 States having highest and lowest literacy rate using a temp table -- 
Drop Table if exists Literacy_Rate
Create Table Literacy_Rate
(state nvarchar(225),Literacy_Rate float)
insert into Literacy_Rate
select State as State, round(Avg(Literacy),3) as Literacy_Rate from [Portfolio Project ].dbo.data1 group by State Order by Literacy_Rate desc 
select * from Literacy_Rate


-- Q3 - Finding the number of male and female in the population Using Sub Queries-- 
select d.state,sum(d.males) Total_males, sum(d.females) Total_females from
(select c.district, c.state, round(c.population/(c.sex_ratio+1),0) as males, round((c.population*c.sex_ratio)/(sex_ratio+1),0) as females from
(select a.district,a.state,a.Sex_Ratio/1000 as sex_ratio, b.Population from [Portfolio Project ]..data1 a inner join [Portfolio Project ]..data2 b on a.District=b.District) c) d
Group by d.state

-- Q4 - Total Literate and Illerate People In Each State-- 
select State, sum(Total_Literate_People) Literate_People, sum(Total_Illiterate_People) as Illiterate_people from 
(select c.District, c.State, round((c.Literacy_ratio*c.Population),0) as Total_Literate_People, round(((1-c.Literacy_ratio)* c.Population),0) as Total_Illiterate_People from
(Select a.district as District,a.state State,a.Literacy/100 as Literacy_ratio, b.Population from [Portfolio Project ]..data1 a inner join [Portfolio Project ]..data2 b on a.District=b.District) c) d 
Group by d.State 


-- Q5 - Finding the Current Population Per Sq. Km and Previous Censes Population Per Sq. Km -- 
select (x.Previous_Censes_Population/x.Total_Area) as Previous_Pop_PerSqKm, (x.Current_Population/x.Total_Area) as Current_Pop_PerSqKm from
(select q.*,r.Total_Area from
(select '1' as K_ey,f. * from 
(select sum(e.Previous_Censes_Population) as Previous_Censes_Population,sum(e.Current_Population) as Current_Population from 
(select State, sum(Population) Current_Population, sum(Previous_Censes_Population) as Previous_Censes_Population from 
(Select c.District, c.State, c.Population, round((c.Population/(1+c.growth)),0) Previous_Censes_Population from
(Select a.district as District,a.state State,a.Growth, b.Population from [Portfolio Project ]..data1 a inner join [Portfolio Project ]..data2 b on a.District=b.District) c ) d
group by State) e)f) q inner join
(select '1' as K_ey,g. * from 
(select SUM(Area_km2) as Total_Area from [Portfolio Project ]..data2) g) r  on q.K_ey = r.K_ey) x


--Q6 Finding Top 3 Districts with highest literacy rate--

select a.* from
(select district, state, Literacy, RANK() over (partition by state order by literacy desc) r_ank  from [Portfolio Project ]..data1) a
where a.r_ank in (1,2,3)
