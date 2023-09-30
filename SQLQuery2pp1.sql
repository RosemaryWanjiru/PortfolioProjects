SELECT *
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [dbo].[CovidVaccinations]
--ORDER BY 3,4

--SELECTING THE DATA THAT WE'LL USE
SELECT location, date,total_cases,new_cases,total_deaths,population
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE location like '%kenya%'
ORDER BY 1,2

--Looking at total cases vs population
--Popultion that is contracting covid
SELECT location, date,total_cases,population ,(total_cases/population)*100 as PopulationPercentage
FROM [dbo].[CovidDeaths]
WHERE location like '%states%'
ORDER BY 1,2

--Countries with highest infection rate vs population
SELECT location,MAX(total_cases)AS HighestInfectionCount,population ,MAX((total_cases/population))*100 as
 PercentPopulationInfected
FROM [dbo].[CovidDeaths]
GROUP BY location,population
--WHERE location like '%states%'
ORDER BY PercentPopulationInfected DESC

--Showing the countries with the highest death count per population
--SELECT location, MAX(cast(total_deaths as int)) as TotalDeath
--FROM CovidDeaths
--GROUP BY location
----WHERE location like '%states%'
--ORDER BY TotalDeath DESC
SELECT location, MAX(cast(total_deaths as int)) as TotalDeath
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeath DESC

--Highest Death by Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeath
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeath DESC

--Global Numbers
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int))as TotalDeaths,
 SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentGlobal
FROM [dbo].[CovidDeaths]
--WHERE location like '%kenya%'
WHERE continent is not null
ORDER BY 1,2



--population vs vaccination
With PopVac ( continent, location,date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject#1..CovidDeaths dea
Join CovidVaccinations vac
 ON dea.location = vac.location
and dea.date= vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVac

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject#1..CovidDeaths dea
Join PortfolioProject#1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject#1..CovidDeaths dea
Join PortfolioProject#1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
