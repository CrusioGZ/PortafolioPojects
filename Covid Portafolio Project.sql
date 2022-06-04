Select *
From PortafolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortafolioProject..CovidVaccination
--order by 3,4


Select Location, Date, total_cases, new_cases, total_deaths, population
From PortafolioProject..CovidDeaths
where continent is not null
order by 1,2


--Total Cases vs Total Deaths

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortafolioProject..CovidDeaths
--Where location = 'Mexico'
order by 1,2

--Total Cases vs Population

Select Location, Date, total_cases, population, (total_cases/population)*100 as CasesPercetage
From PortafolioProject..CovidDeaths
--Where location = 'Mexico'
order by 1,2

--Highest Infection rate compare to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as CasePercentage
From PortafolioProject..CovidDeaths
Group by Location, population
order by CasePercentage desc

--Highest Death Count 

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortafolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Continent with the highest Death Count
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortafolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

-- Global Numbers
Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
From PortafolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as PeopleVaccinated
From PortafolioProject..CovidDeaths dea
join PortafolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2, 3

--USE CTE

With PopvsVac (continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as PeopleVaccinated
From PortafolioProject..CovidDeaths dea
join PortafolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)
Select *,(PeopleVaccinated/Population)*100
from PopvsVac

--Temp Table

Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as PeopleVaccinated
From PortafolioProject..CovidDeaths dea
join PortafolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null

Select *,(PeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
order by 2,3


-- View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as PeopleVaccinated
From PortafolioProject..CovidDeaths dea
join PortafolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated