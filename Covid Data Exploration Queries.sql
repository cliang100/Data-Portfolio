Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
-- Likelihood to die from Covid by country

Select 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(cast(total_deaths as int) / cast(total_cases as int)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2


-- Total Cases vs Population
-- What percentage of the population contracted covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Sorting countries by highest infection rate (3.)

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Highest Death Count per Population
-- By country

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent != ''
Group by Location
order by TotalDeathCount desc


-- By continent (2.)

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent != ''
Group by continent
order by TotalDeathCount desc


-- Sorting Death percentages Globally (1.)

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent != ''
--Group By date
order by 1,2


-- Total Population vs Total Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) over 
	(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
order by 2,3


-- CTE

With PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) over 
	(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RPV_Percent
From PopsvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations bigint,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) over 
	(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RPV_Percent
From #PercentPopulationVaccinated


-- Views for data visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''



Select *
From PercentPopulationVaccinated

-- Create more views for each of the thingies