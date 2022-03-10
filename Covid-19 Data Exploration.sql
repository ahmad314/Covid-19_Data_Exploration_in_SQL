
-- Covid 19 Data Exploration SQL Project [from 25th Feb, 2020 to 2nd Feb, 2022]

-- Cross checking the avialable data

Select *
From Portfolio_Project.dbo.Covid_Deaths
Order by 3,4


-- Further narrowing down the data for the current project

Select location, date, population, total_cases, new_cases, total_deaths, new_deaths
From Portfolio_Project.dbo.Covid_Deaths
Where continent is not null
Order by 1,2


-- Covid 19 mortality rate in Pakistan

Select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From Portfolio_Project.dbo.Covid_Deaths
Where location like '%pak%'
and continent is not null
Order by 1,2


-- Percentage of Pakistan's population infected with Covid 19

Select location, date, population, total_cases, (total_cases/population)*100 as Infected_population_percentage
From Portfolio_Project.dbo.Covid_Deaths
Where location like '%pak%'
and continent is not null
Order by 1,2


-- Population percentage of each country which got infected

Select location, population, MAX(cast(total_cases as int)) as Total_cases, MAX((total_cases/population))*100 as Infected_population_percentage
From Portfolio_Project.dbo.Covid_Deaths
Where continent is not null
Group by location, population
Order by Infected_population_percentage DESC


-- Countries with the highest death count

Select location, population, MAX(cast(total_deaths as int)) as Total_deaths 
From Portfolio_Project.dbo.Covid_Deaths
Where continent is not null
Group by location, population
Order by Total_deaths DESC


-- Continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as Total_deaths 
From Portfolio_Project.dbo.Covid_Deaths
Where continent is not null
Group by continent
Order by Total_deaths DESC


-- Global numbers against each day

Select date, SUM(new_cases) as Cases, SUM(CAST(new_deaths as int)) as Deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From Portfolio_Project.dbo.Covid_Deaths
Where continent is not null
Group by date
Order by 1


-- Overall global numbers till 2nd Feb, 2022

Select SUM(new_cases) as Cases, SUM(CAST(new_deaths as int)) as Deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From Portfolio_Project.dbo.Covid_Deaths
Where continent is not null


-- Country wise new and total vaccinaions for each day

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
From Portfolio_Project.dbo.Covid_Deaths as dea
Join Portfolio_Project.dbo.Covid_Vaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE to get percentage of people vaccinated

With percentvaccinate (continent, location, date, population, new_vaccinations, total_vaccinations) as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
From Portfolio_Project.dbo.Covid_Deaths as dea
Join Portfolio_Project.dbo.Covid_Vaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (total_vaccinations/population)*100 as population_percentage_vaccinated
From percentvaccinate


-- Now using temp table to the above same task

Drop table if exists percentvaccinated
Create table percentvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
total_vaccinations bigint
)
Insert into percentvaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
From Portfolio_Project.dbo.Covid_Deaths as dea
Join Portfolio_Project.dbo.Covid_Vaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Select *, (total_vaccinations/population)*100 as population_percentage_vaccinated
From percentvaccinated
Order by location, date


-- Creating view to store data for visualization

Create View max_death_countries AS
Select location, population, MAX(cast(total_deaths as int)) as Total_deaths
From Portfolio_Project.dbo.Covid_Deaths
Where continent is not null
Group by location, population