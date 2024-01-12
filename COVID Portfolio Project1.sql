select *
from [Portfolio Project]..CovidDeaths
where continent is not null 
order by 3,4


--select *
--from [Portfolio Project]..CovidVaccinations
--order by 3,4

select Location, date,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths
order by 1,2

-- looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date,total_cases,total_deaths,round((total_deaths/total_cases)*100,2)as Deathpercentage
from [Portfolio Project]..CovidDeaths
where location like ('%states%')
and continent is not null 
order by 1,2

-- looking at Total Case vs Population

select Location, date,population,total_cases, round((total_cases/population),5)*100 as TotalPopulation
from [Portfolio Project]..CovidDeaths
--where location like ('%states%')
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population
select Location,population,Max(total_cases)as HighestInfectioncount,Max((total_cases/population))*100 as PercentPopulationInfected 
from [Portfolio Project]..CovidDeaths
--where location like ('%states%')
group by location,population
order by PercentPopulationInfected desc

--Showing Countries with Highest DeathCount per Population
select Location,MAX(cast(total_deaths as int)) as TotalDeathCount, Max(Total_deaths/population)*100 as DeathCountPercentage
from [Portfolio Project]..CovidDeaths
--where location like ('%states%')
where continent is not null 
group by location,population
order by TotalDeathCount desc

-- Let's break things down by continent

-- showing continents with the highest death count per population
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like ('%states%')
where continent is not null 
group by continent 
order by TotalDeathCount desc

select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like ('%states%')
where continent is null 
group by location 
order by TotalDeathCount desc

-- Global Numbers

select sum(new_cases) as totalnewcase,sum(cast(new_deaths as int))as totalnewdeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like ('%states%')
where continent is not null 
--group by date
order by totalnewcase desc

-- looking at Total Populatin vs Vaccinations

with PopvsVac(Continent, location,Date,Population, New_vaccinations,Rollingvaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
       Sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date) as Rollingvaccinated
	  -- (Rollingvaccinated/population)*100 
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
--order by 2,3
)

select *, (Rollingvaccinated/Population)*100
from PopvsVac

-- TEMP Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinates numeric,
Rollingvaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
       Sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date) as Rollingvaccinated
	  -- (Rollingvaccinated/population)*100 
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
--order by 2,3

select * from #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated 
as 
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
       Sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date) as Rollingvaccinated
	  -- (Rollingvaccinated/population)*100 
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
--order by 2,3

select * 
from PercentPopulationVaccinated