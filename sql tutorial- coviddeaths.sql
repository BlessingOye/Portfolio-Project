SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM [Portfolio Project]..CovidVacc
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (CAST(total_cases as float)/CAST(population as float))*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1,2


--Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases as float)/CAST(population as float)))*100 AS PercentagePopulationInfected 
FROM [Portfolio Project]..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


--Showing the Countries with Highest Death Count  per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount  
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount  
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


--Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount  
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases,SUM(new_deaths) as total_deaths,NULLIF(SUM(new_deaths),0)/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2




SELECT *
FROM [Portfolio Project]..CovidVacc

SET ANSI_WARNINGS ON
GO

--Looking at Total Population vs Vaccianations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location,dea.Date)
 AS RollingPopleVaccinated ,(RollingPeopleVaccinated/Population)*100
 FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USING CTE
With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location,dea.Date)
 AS RollingPeopleVaccinated 
 FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100
FROM PopVsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population nvarchar(255),
New_vaccinations float,
RollingPeopleVaccinated float
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location,dea.Date)
 AS RollingPeopleVaccinated 
 FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location,dea.Date)
 AS RollingPeopleVaccinated 
 FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3





SET ANSI_WARNINGS ON
GO
