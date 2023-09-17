select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


-- select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%Pakistan%'
and continent is not null
order by 1,2

-- Looking at Total cases vs Population
-- show what percentage of people got covid

select Location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%Pakistan%'
and continent is not null
order by 1,2

-- looking at Countries with Highest Infection Rate compared to Population

select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population
-- using cast due to total_deaths data type issue

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

-- let'break things down by continent

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc


-- global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


-- covid vaccines table

select *
from PortfolioProject..CovidVaccinations$


-- join CovidDeaths and CovidVaccines table
-- looking at Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (Continent, Locaion, Date, Population, New_Vaccination,
RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(233),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- creating Veiw to store date for later visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *
from PercentPopulationVaccinated