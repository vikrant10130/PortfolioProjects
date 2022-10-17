select *
from PortfolioProject..dbproject$
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..dbproject$
order by 1,2

--total cases vs total deaths
select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..dbproject$
Where location like '%states%'
order by 1,2

--looking at total cases vs population
select Location, date, total_cases, population,(total_cases/population)*100 AS DeathPercentage
from PortfolioProject..dbproject$
Where location like '%states%'
order by 1,2

-- countries with highest infection rate
select Location, max( total_cases) AS HighestInfectionRate,population,MAX((total_cases/population))*100 AS PercentagePeopleInfected
from PortfolioProject..dbproject$
--Where location like '%states%'
Group by location, population
order by PercentagePeopleInfected desc

--BREAK THINGS DOWN BY CONTINENT
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..dbproject$
--Where location like '%states%'
Where continent is NOT NULL
Group by continent
order by TotalDeathCount desc


--showing coumtries with highest death count per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..dbproject$
--Where location like '%states%'
Where continent is NOT NULL
Group by location
order by TotalDeathCount desc

--showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..dbproject$
--Where location like '%states%'
Where continent is NOT NULL
Group by continent
order by TotalDeathCount desc

--Global numbers

select  date, SUM(new_cases), SUM(cast(new_deaths as int)), Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..dbproject$
--Where location like '%states%'
where continent is NOT NULL
Group by date
order by 1,2

--total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS bigint)) over (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccited
from PortfolioProject..dbproject$ dea
join
 PortfolioProject..dbproject1$ vac ON
dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL
order by 2,3


-- USE CTE
With PopvsVac(Continet, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS bigint)) over (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccited
from PortfolioProject..dbproject$ dea
join
 PortfolioProject..dbproject1$ vac ON
dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL

)

Select* 
from PopvsVac

--temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS bigint)) over (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccited
from PortfolioProject..dbproject$ dea
join
 PortfolioProject..dbproject1$ vac ON
dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL

Select* , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view to store date for visual visualization

Create view PercentPopulationVaccinated
 as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS bigint)) over (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccited
from PortfolioProject..dbproject$ dea
join
 PortfolioProject..dbproject1$ vac ON
dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL









