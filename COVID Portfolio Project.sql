
SELECT *
FROM PortfolioProject..CovidDeaths 
ORDER BY 3,4


--Select Data that we are going to be using

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS PopWithCovid
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Showing countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)))*100 AS PercentPopInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopInfected DESC

--Showing countries with largest percent of population dead due to Covid

SELECT location, population, MAX(total_deaths) AS TotalDeathCount, MAX((CONVERT(float,total_deaths)/NULLIF(CONVERT(float,population),0)))*100 AS PercentDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentDeath DESC

--Showing Countries with highest Death Count Per Population

SELECT location, MAX(CONVERT(int, total_deaths)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count

SELECT location, MAX(CONVERT(int, total_deaths)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income' AND location NOT LIKE 'World'
GROUP BY location
ORDER BY TotalDeathCount DESC


--Global Death Percentage per day

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Global Death Percentage

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Joining Covid Deaths and Covid Vaccinations tables
--Looking at a Rolling Vaccination Count per Country

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Looking at Total Population vs Vaccinations
--Using a CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinationCount) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingVaccinationCount/population)*100 AS RollingPercentofPopVaccinated
FROM PopvsVac


--Creating View to store data for later visualizations

CREATE VIEW RollingPercentofPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM RollingPercentofPopVaccinated 