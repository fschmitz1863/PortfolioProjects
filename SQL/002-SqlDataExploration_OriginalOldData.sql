SELECT *
FROM PortfolioProject..CovidDeaths_OldData
WHERE continent IS NOT NULL
--WHERE location LIKE '%income'
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations_OldData
--ORDER BY 3,4

-- Select data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths_OldData
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Likelihood of dying if contracting COVID
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths_OldData
WHERE continent IS NOT NULL
--WHERE location LIKE 'Japan'
ORDER BY 1,2



-- Total Cases vs Population
-- Percentage of Population infected
SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths_OldData
WHERE continent IS NOT NULL
--WHERE location LIKE '%states'
ORDER BY 1,2


-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS InfectionRate
FROM PortfolioProject..CovidDeaths_OldData
WHERE continent IS NOT NULL
--WHERE location LIKE '%states'
GROUP BY location, population
ORDER BY InfectionRate DESC


-- Countries with highest death count per population
-- Grouped by location
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths_OldData
WHERE continent IS NOT NULL
--WHERE location LIKE '%states'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Grouped by continent
-- TODO: Query below does not include all data
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths_OldData
WHERE continent IS NOT NULL
	--AND location NOT LIKE ('%income')
	--AND location NOT LIKE ('World')
	--AND location NOT LIKE ('%Union')
--WHERE location LIKE '%states'
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- TODO: Query below is the correct alternative to include all data
--SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths_OldData
--WHERE continent IS NULL
--	AND location NOT LIKE ('%income')
--	--AND location NOT LIKE ('World')
--	--AND location NOT LIKE ('%Union')
----WHERE location LIKE '%states'
--GROUP BY location
--ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths_OldData
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT location, date, new_cases
FROM PortfolioProject..CovidDeaths_OldData



-- Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths_OldData AS dea
JOIN PortfolioProject..CovidVaccinations_OldData AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Produce calculated column "PercentageOfPopulationVaccinated"): (RollingPeopleVaccinated/dea.population)*100
-- (1) CTE
WITH PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths_OldData AS dea
JOIN PortfolioProject..CovidVaccinations_OldData AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageOfPopulationVaccinated
FROM PopVsVac
ORDER BY 2,3


-- (2) TEMP TABLE
DROP TABLE IF EXISTS #PercentageOfPopulationVaccinated
CREATE TABLE #PercentageOfPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentageOfPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths_OldData AS dea
JOIN PortfolioProject..CovidVaccinations_OldData AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageOfPopulationVaccinated
FROM #PercentageOfPopulationVaccinated
ORDER BY 2,3


-- VIEW: Data storage for later visualisation
DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths_OldData AS dea
JOIN PortfolioProject..CovidVaccinations_OldData AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

