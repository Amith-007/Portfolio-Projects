
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths


SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths



--Looking at Total Cases vs Total Deaths
--shows the chances of dying if you contract covid in your country

SELECT location, date, total_cases,total_deaths, (cast(total_deaths as float )/ cast(total_cases as float)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'india'
order by 1,2

--Looking at Total Cases vs Population
-- shows what percentage of population got covid

SELECT location, date, population,total_cases,(cast(total_cases as int) / population)* 100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
where location = 'india'
order by 1,2


--looking at the countries with high infection rate compared to population


SELECT location, population,max(cast(total_cases as float)) as HighestInfectedCount,max((cast(total_cases as float) / population))* 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
group by location,population
order by 4 desc

SELECT location, population,max(cast(total_cases as float)) as HighestInfectedCount,max((cast(total_cases as float) / population))* 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where population > 1000000
group by location,population
order by 4 desc

SELECT location, population,max(cast(total_cases as float)) as HighestInfectedCount,max((cast(total_cases as float) / population))* 100 as PercentPopulationInfected,
 max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent = 'Asia' and population >1000000
group by location,population
order by 2 desc

--showing countries with highest death count per population

SELECT location, max(cast(total_cases as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--LETS CHECK BY CONTINENT with highest death count per population
-- this one is correct though..
--also if we check with continent its not showing the correct value,like for eg:north america only showing the death count of united states,
--asia - china, europe-france...likewiwse..so had to check with location..and where continent is null

SELECT location, max(cast(total_cases as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is null 
group by location
order by TotalDeathCount desc

 
SELECT continent, max(cast(total_cases as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- globally

SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths,
CASE
	WHEN SUM(new_cases) = 0 THEN 0
	ELSE SUM(new_deaths)/SUM(new_cases) * 100
END as Deathpercentage
FROM PortfolioProject..CovidDeaths
where continent is not null		 


--Looking at Total population vs Vaccination

--SELECT CovidDeaths.location,CovidDeaths.date,population,total_cases,total_deaths,people_vaccinated
--FROM PortfolioProject..CovidDeaths dea
--INNER JOIN PortfolioProject..CovidVaccinations vac
--	ON CovidDeaths.location = CovidVaccinations.location
--WHERE CovidDeaths.continent IS NOT NULL and CovidDeaths.location = 'India'
--order by date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

--CTEs

WITH vacvspop(Continent, Location, Date, Population, NewVaccinations, RollingPeopleInfected)  as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingPeopleInfected/Population)* 100
from vacvspop



--Temp tables

Drop table if exists #vacc
Create Table #vacc(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
NewVaccinatoin numeric,
RollingPeopleInfected numeric)

Insert into #vacc 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

SELECT *, (RollingPeopleInfected/Population)*100
from #vacc


-- total vaccinations , including those that have received vaccines and those that have not.

SELECT dea.continent,dea.location,  MAX(CAST(ISNULL(vac.total_vaccinations,0) AS bigint)) as TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
LEFT JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location
ORDER BY TotalVaccinations desc,dea.continent,dea.location

--creating view to store data for later visualization

Create View PeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null







