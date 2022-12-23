

--TEST OF THE DATABASE, TO CHECK IF IT WAS CORRECTLY UPLOAD

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT Location, date, total_cases, total_deaths,new_cases, population 
 FROM PortfolioProject..CovidDeaths
 ORDER BY 1,2
-- Looking at total cases vs Population

 SELECT Location, date, population, total_cases,
 (total_cases/population)*100 As PercentageInfected
 FROM PortfolioProject..CovidDeaths
 WHERE location like '%Colombia%'
 ORDER BY 1,2 DESC

  -- Which country has the highest infection rate

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,
 MAX((total_cases/population))*100 As PercentInfected
 FROM PortfolioProject..CovidDeaths
 GROUP BY Location, population
 --HAVING location = 'Colombia'
 ORDER BY PercentInfected DESC;

 --Highest infection in your particular Country, you just have to replace the name of your country

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,
 MAX((total_cases/population))*100 As PercentInfected
 FROM PortfolioProject..CovidDeaths
 GROUP BY Location, population
 HAVING location = 'Colombia';

 -- Showing Country with highest Death count

SELECT Location, population, MAX(CAST (total_deaths AS int)) AS DeathCount
 FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY Location, population
 ORDER BY DeathCount DESC;

 -- Showing Continent with highest Death count

SELECT location, MAX(CAST (total_deaths AS int)) AS DeathCount 
 FROM PortfolioProject..CovidDeaths
 WHERE continent IS NULL
 GROUP BY location 
 HAVING location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low income', 'International')
 ORDER BY DeathCount DESC;


 --GLOBAL NUMBERS

--Looking at Total Death VS Total Cases
 -- Shows the Likelihood of Dying if you contract covid in your country

 SELECT SUM (new_cases) AS TotalCases, SUM ( cast (new_deaths AS INT)) AS TotalDeaths ,SUM ( cast (new_deaths AS INT))/SUM(NEW_cases)*100 As GlobalDeathPercentage
 FROM PortfolioProject..CovidDeaths
 --WHERE location like '%Colombia%' AND
 WHERE continent IS NOT NULL
-- GROUP BY date
 ORDER BY 1,2;

 -- COVID VACCINATION TABLE

 SELECT *
 FROM PortfolioProject..CovidVaccinations AS CovidVaccination
 ORDER BY 3,4;

 --  Inner Join Deaths table With Vaccination Table

SELECT *
FROM PortfolioProject..CovidVaccinations AS Vac
INNER JOIN PortfolioProject..CovidDeaths AS Dea
ON Vac.location = Dea.location
AND Vac.date = Dea.date;

-- Looking at Total Population Vs  Total Vaccinations

SELECT Dea. Continent,Dea.Location, Dea.date,  Dea.population, Vac.new_vaccinations,
 SUM (CONVERT(BIGINT, Vac.new_vaccinations)) OVER ( PARTITION BY Dea. Location ORDER BY Dea.Location, Dea.date)AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidVaccinations AS Vac
INNER JOIN PortfolioProject..CovidDeaths AS Dea
ON Vac.location = Dea.location 
AND Vac.date = Dea.date
WHERE Dea.Continent IS NOT NULL
ORDER BY 2,3;

--USE CTE

WITH  RollPopVsVac (Continent, Location, date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(SELECT Dea. Continent,Dea.Location, Dea.date,  Dea.population, Vac.new_vaccinations,
 SUM (CONVERT(BIGINT, Vac.new_vaccinations)) OVER ( PARTITION BY Dea. Location ORDER BY Dea.Location, Dea.date)AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidVaccinations AS Vac
INNER JOIN PortfolioProject..CovidDeaths AS Dea
ON Vac.location = Dea.location 
AND Vac.date = Dea.date
WHERE Dea.Continent IS NOT NULL)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagepeopleVaccinated
FROM RollPopVsVac;
--WHERE Location = 'Colombia';


--TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated

  (Continent VARCHAR (255),
  Location VARCHAR (255),
  Date DATETIME,
  Population NUMERIC,
  New_Vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC);

INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT Dea. Continent,Dea.Location, Dea.date,  Dea.population, Vac.new_vaccinations,
 SUM (CAST(Vac.new_vaccinations AS BIGINT)) OVER ( PARTITION BY Dea. Location ORDER BY Dea.Location, Dea.date)AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidVaccinations AS Vac
INNER JOIN PortfolioProject..CovidDeaths AS Dea
ON Vac.location = Dea.location 
AND Vac.date = Dea.date
WHERE Dea.date IS NOT NULL;

SELECT *  --(RollingPeopleVaccinated/population)*100 AS PercentagepeopleVaccinated
FROM #PercentPopulationVaccinated;


-- Create a view

CREATE VIEW 
PercentPopulationaVaccinated AS

SELECT Dea. Continent,Dea.Location, Dea.date,  Dea.population, Vac.new_vaccinations,
 SUM (CAST(Vac.new_vaccinations AS bigint)) OVER ( PARTITION BY Dea. Location ORDER BY Dea.Location, Dea.date)AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidVaccinations AS Vac
INNER JOIN PortfolioProject..CovidDeaths AS Dea
ON Vac.location = Dea.location 
AND Vac.date = Dea.date
WHERE Dea.date IS NOT NULL;

SELECT *
FROM PercentPopulationaVaccinated














