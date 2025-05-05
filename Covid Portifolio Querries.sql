--Project querries

--COVID DEATHS QUERRIES

select *
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from CovidPortfolioProject..CovidVaccinations
--order by 3,4


--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--looking at total cases vs total deaths
	--how many cases did they have per country and what is the moratlity rate
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as	 mortality_rate
from CovidPortfolioProject..CovidDeaths
where location like '%Brazil%'
and continent is not null
order by 1,2

--looking at total cases vs the population
	--Shows the % of the population that got covid
select location, date, total_cases, population,(total_cases / population)*100 as infection_rate  --For easy presentation: CAST(ROUND((total_cases / population)*100, 2) AS VARCHAR(6)) + ' %' AS infection_rate
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2


--Looking at countries with the highests infection rates compared to population
select location,population, MAX(total_cases) as highest_infection_count,MAX((total_cases / population)*100) as infection_rate  --For easy presentation: CAST(ROUND((total_cases / population)*100, 2) AS VARCHAR(6)) + ' %' AS infection_rate
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by infection_rate desc


--showing countries with the highest death count per population
select location, population, max(CAST(total_deaths as int)) as total_death_count, MAX((total_deaths / population)*100) as total_death_ratio
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by total_death_count desc


--lest break things down by continent

	--showing  continents with the highest death count
select location, max(CAST(total_deaths as int)) as total_death_count, MAX((total_deaths / population)*100) as total_death_ratio
from CovidPortfolioProject..CovidDeaths
where continent is null
group by location
order by total_death_count desc

select continent, max(CAST(total_deaths as int)) as total_death_count	
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc
	

--global number
select /*date,*/ SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(New_cases))*100 as death_percentage
from CovidPortfolioProject..CovidDeaths
--where location like '%Brazil%'
where continent is not null
--group by date
order by 1,2




--COVID VACCINATIONS QUERRIES
SELECT *
FROM CovidPortfolioProject..CovidVaccinations

--looking at total population
SELECT *
FROM CovidPortfolioProject..CovidDeaths as dea
JOIN CovidPortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--we cant reference in a select a custom field we just created
--we need to store it in a CTE
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over  (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated,
(rolling_people_vaccinated/dea.population)*100
FROM CovidPortfolioProject..CovidDeaths as dea
JOIN CovidPortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--CTE method
with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over  (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/dea.population)*100
FROM CovidPortfolioProject..CovidDeaths as dea
JOIN CovidPortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100 as percent_vaccinated from pop_vs_vac

--Temp Table method
drop table if exists #temp_percent_population_vaccinated 
Create table #temp_percent_population_vaccinated 
(continent nvarchar(50), 
location	nvarchar(50), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric)

insert into #temp_percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over  (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/dea.population)*100
FROM CovidPortfolioProject..CovidDeaths as dea
JOIN CovidPortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rolling_people_vaccinated/population)*100 as percent_vaccinated from #temp_percent_population_vaccinated


--Creating view to store data for later
create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over  (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/dea.population)*100
FROM CovidPortfolioProject..CovidDeaths as dea
JOIN CovidPortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated