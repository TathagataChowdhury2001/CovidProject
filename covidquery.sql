select * from COVID..CovidVaccinations$;
select * from COVID..CovidDeaths$;

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
from COVID..CovidDeaths$ ORDER BY 1,2 ;

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
from COVID..CovidDeaths$ where location like '%states%' ORDER BY 2;

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
from COVID..CovidDeaths$ where location like 'India' ORDER BY 2;

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS death_percentage, (total_cases/population)*100 AS incidence
from COVID..CovidDeaths$ where location like 'India' ORDER BY 2;


select location, population, max(cast(total_cases as int)) AS HighestInfectionCount, max((total_cases/population))*100 AS incidence
from COVID..CovidDeaths$ 
where continent IS NOT NULL
GROUP BY location,population
ORDER BY 3 DESC;


select location, max(cast(total_deaths as int)) AS Highest_Death_Count, max((total_deaths/population))*100 AS Highest_Death_Count_per_population
from COVID..CovidDeaths$ 
where continent IS NOT NULL
GROUP BY location
ORDER BY Highest_Death_Count DESC;

select location, max(cast(total_deaths as int)) AS Highest_Death_Count
from COVID..CovidDeaths$ 
where continent IS NULL
GROUP BY location
ORDER BY Highest_Death_Count DESC;



select continent, max(cast(total_deaths as int)) AS Highest_Death_Count
from COVID..CovidDeaths$ 
where continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Count DESC;

select SUM(new_cases) AS total_new_cases, SUM(cast(new_deaths as int)) AS Total_Death_Count, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentge
from COVID..CovidDeaths$ 
where continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location,dea.date) AS rollingpeoplevaccinated
from COVID..CovidDeaths$ dea
join COVID..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent IS NOT NULL
--GROUP BY date
ORDER BY 2,3;


WITH PopvsVac(continent,location, date, population,new_vaccinations, rollingpeoplevaccinated)
AS
(
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location,dea.date) AS rollingpeoplevaccinated
from COVID..CovidDeaths$ dea
join COVID..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent IS NOT NULL
)
select *, (rollingpeoplevaccinated/population) as rollingpercentge from PopvsVac;


DROP Table IF EXISTS #PercentPopulationVccinated
Create Table #PercentPopulationVccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric);
Insert Into #PercentPopulationVccinated
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location,dea.date) AS rollingpeoplevaccinated
from COVID..CovidDeaths$ dea
join COVID..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent IS NOT NULL;

select *, (rollingpeoplevaccinated/population) as rollingpercentge from #PercentPopulationVccinated;

DROP VIEW IF EXISTS PopulationVccinatedPercent
CREATE VIEW PopulationVccinatedPercent as 
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location,dea.date) AS rollingpeoplevaccinated
from COVID..CovidDeaths$ dea
join COVID..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent IS NOT NULL;