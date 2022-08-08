--select *
--from [Portfolio Project ]..['covid deaths$']
--order by 3,4

--select *
--from [Portfolio Project ]..['covid vaccination$']
--order by 3,4
select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project ]..['covid deaths$']
order by 1,2

-- Shows the % Chance that an indivdual could die if he/she contracted covid 19 as of today
select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project ]..['covid deaths$']
where location like '%India%'
order by 1,2

-- Looking at Total Cases Vs Population : Shows what % of population got covid  
select Location, date,population, total_cases,(total_cases/population)*100 as PopulationPercent
From [Portfolio Project ]..['covid deaths$']
where location like '%india%'
order by 1,2

-- Lookuing at countries with highest infection rate compared to population 
select Location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as InfectionRate
From [Portfolio Project ]..['covid deaths$']
--where location like '%india%'
Group by location, population
order by InfectionRate desc

-- showing countries with highest death count per population 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount,MAX((total_deaths/population))*100 as DeathRate 
From [Portfolio Project ]..['covid deaths$']
where continent is null
Group by location
order by DeathRate desc

--GLOBAL NUMBERS : Cases accross the world by date --
select date, SUM(new_cases) as Newcases, SUM(cast(new_deaths as int)) as NewDeaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as deathprecentage
From [Portfolio Project ]..['covid deaths$']
where continent is not null
Group by date
order by 1,2

--GLOBAL NUMBERS : Cases accross the world summed--
select SUM(new_cases) as Newcases, SUM(cast(new_deaths as int)) as NewDeaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as deathprecentage
From [Portfolio Project ]..['covid deaths$']
where continent is not null
order by 1,2

-- Looking at Total Population Vs Total Vaccination : Cumulative Count/Day  --
--USE CTE-- 
With PopvsVac (Continent, location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From [Portfolio Project ]..['covid deaths$'] dea 
Join [Portfolio Project ]..['covid vaccination$'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinated
from PopvsVac


-- Looking at Total Population Vs Total Vaccination : Cumulative Count/Day  --
--USE TEMP TABLE-- 
Drop Table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
date datetime,
Population  numeric, 
New_Vaccination numeric, 
RollingPeopleVaccination numeric
)
Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccination
From [Portfolio Project ]..['covid deaths$'] dea 
Join [Portfolio Project ]..['covid vaccination$'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Select *, (RollingPeopleVaccination/Population)*100 as PeopleVaccinated
from #PercentPopVaccinated

--Creating View to store data for later visualization\

Create View RollingPeopleVacc as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVacc
From [Portfolio Project ]..['covid deaths$'] dea 
Join [Portfolio Project ]..['covid vaccination$'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

