

SELECT location, date, total_cases, new_cases, total_deaths, population
From portfolio..CovidDeaths$
Where continent is not null
order by 1,2


--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio..CovidDeaths$
Where location like '%Philippines%'
and continent is not null
order by 1,2

--- Looking at Total cases vs Population
--- Shows what percentage of population got COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From portfolio..CovidDeaths$
Where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From portfolio..CovidDeaths$
Group by location, population
order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount DESC


-- LETS BREAK DOWN BY CONTINENT
-- Showing continents with highhest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolio..CovidDeaths$
Where continent is not null
Group by Date
order by 1,2


-- Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
  as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
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
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 