--SELECT *
--FROM COVIDPortfolioProject..covid_vaccinations
--order by 3,4

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVIDPortfolioProject..covid_deaths
WHERE continent is not null
order by 1,2

-- Looking at total cases vs. total deaths
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM COVIDPortfolioProject..covid_deaths
where location = 'United Kingdom' AND continent is not null
order by 1,2

-- Looking at total cases vs. population as a percentage
SELECT location, date, population, total_cases, round((total_cases/population)*100,2) as CasePercentage
FROM COVIDPortfolioProject..covid_deaths
where location = 'United Kingdom' AND continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population))*100,2) as CasePercentage
FROM COVIDPortfolioProject..covid_deaths
WHERE continent is not null
group by location, population
order by CasePercentage desc

-- Looking at countries with highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM COVIDPortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Looking at continents with highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM COVIDPortfolioProject..covid_deaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) as DeathPercentage
FROM COVIDPortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at total population vs new vaccinations per date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..covid_deaths dea
Join COVIDPortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..covid_deaths dea
Join COVIDPortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, ROUND((RollingPeopleVaccinated/Population)*100,2) as RollingVaccinationPercentage
From PopvsVac

-- TEMP TABLE
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..covid_deaths dea
Join COVIDPortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating a view to store data for later visualisations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From COVIDPortfolioProject..covid_deaths dea
Join COVIDPortfolioProject..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 