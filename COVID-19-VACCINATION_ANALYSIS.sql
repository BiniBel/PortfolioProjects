
SELECT *
FROM CovidDeaths$
ORDER BY 3, 4


--SELECT * 
--FROM CovidVaccinations$
--ORDER BY 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in any country, i have used my homeland, Ethiopia here.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location like '%Ethiopia%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths$
Where location like '%Ethiopia%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%Ethiopia%'
Group by Location, Population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%Ethiopia%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%Ethiopia%'
Where continent is null 
Group by location
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccinations$.new_vaccinations
, SUM(CONVERT(int,CovidVaccinations$.new_vaccinations)) OVER (Partition by CovidDeaths$.Location Order by CovidDeaths$.location, CovidDeaths$.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$
Join CovidVaccinations$
	On CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
where CovidDeaths$.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccinations$.new_vaccinations
, SUM(CONVERT(int,CovidVaccinations$.new_vaccinations)) OVER (Partition by CovidDeaths$.Location Order by CovidDeaths$.location, CovidDeaths$.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$
Join CovidVaccinations$
	On CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
where CovidDeaths$.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccinations$.new_vaccinations
, SUM(CONVERT(int,CovidVaccinations$.new_vaccinations)) OVER (Partition by CovidDeaths$.Location Order by CovidDeaths$.location, CovidDeaths$.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$
Join CovidVaccinations$
	On CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
where CovidDeaths$.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccinations$.new_vaccinations
, SUM(CONVERT(int,CovidVaccinations$.new_vaccinations)) OVER (Partition by CovidDeaths$.Location Order by CovidDeaths$.location, CovidDeaths$.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$
Join CovidVaccinations$
	On CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
where CovidDeaths$.continent is not null 



-- Checking our view query
SELECT *
FROM PercentPopulationVaccinated
