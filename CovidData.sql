SELECT *
FROM Portfolio..CovidDeaths;

SELECT *
FROM Portfolio..CovidVaccination;

SELECT location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
ORDER by 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths 
Where location ='India'
ORDER by 1,2;

--Total cases vs Population

SELECT location, date,  total_cases, population, (total_cases/population)*100 as CasePopulation
FROM Portfolio..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2  

--Country at highest infection rate compare to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as CasePopulation
FROM Portfolio..CovidDeaths
GROUP BY location, population
ORDER BY CasePopulation desc

SELECT location, MAX(total_deaths) as TotalDeathCount
From Portfolio..CovidDeaths
GROUP BY location
order by MAX(total_deaths) desc

SELECT location, MAX(CAST(total_deaths as int)) as MaximumCASE
From Portfolio..CovidDeaths
GROUP BY location
ORDER BY MaximumCASE desc

SELECT *
FROM Portfolio..CovidDeaths
WHERE continent is not null


--Total deaths by location
SELECT location, MAX(CAST(total_deaths as int)) as TOTALCOUNT
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP By location
ORDER BY TOTALCOUNT desc

--Total deaths by continent--
SELECT location, MAX(CAST(total_deaths as int)) as TOTALCOUNT
FROM Portfolio..CovidDeaths
WHERE continent is null
GROUP By location
ORDER BY TOTALCOUNT desc

--Continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as Total_deaths, MAX(total_deaths/population)*100  as totalDeathsPerPopulation
FROM Portfolio..CovidDeaths
GROUP BY continent

SELECT date, SUM(new_cases)
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT date, MAX(CAST(new_cases as int)) as total_cases
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT date, SUM(new_cases) as newCase, SUM(CAST(new_deaths as int)) as newDeaths
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP by date
ORDER by 1,2

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--(CONVERT(bigint,vac.new_vaccinations))
-- we use bigint because getting error like arithmetic overflow error
SUM(CAST(vac.new_vaccinations as bigint))
OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeoplePopulation
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

CREATE view percentPopulationVaccination as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations))
OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
