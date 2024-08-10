
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null 
order by 3,4


SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
Where continent is not null 
order by 3,4


--SELECT Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2



--Looking at Total Cases vs Total Deaths
--	Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


--Looking at Highest Infection Rate compared To Population 

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
  PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


---LETS BREAK THINGS DOWN BY CONTINENT CORRECT NUMBERS
	
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
Group by location
order by TotalDeathCount desc



--Showing Continents with the highest death count per population 

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by date
order by 1,2


--Looking at Total population vs Vaccinations method 1


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location)
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null 
  Order by 2,3 

  -- Looking at Total Population vs Vaccinations method 2 

  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
-- (RollingPeopleVaccinated) 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null 
  Order by 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
-- (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null 
--  Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
--Where dea.continent is not null 
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3

Select *
FROM PercentPopulationVaccinated 