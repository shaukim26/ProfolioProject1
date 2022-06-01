SELECT *
FROM ProflioProject..CovidDeaths
Where continent is not null 
order by 3,4 

--SELECT *
--FROM ProflioProject..Covidvaxinations
--order by 3,4

--Select Data that we are going to be using 

SELECT Location, Date, Total_cases, new_cases, total_deaths, population 
FROM ProflioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths In the world

SELECT Location, Date, Total_cases, total_deaths,(total_deaths/Total_cases)*100 as DeathPercentage
FROM ProflioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths in the US
-- Shows likelyhood of dying if you contact covid in your country 

SELECT Location, Date, Total_cases, total_deaths,(total_deaths/Total_cases)*100 as DeathPercentage
FROM ProflioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population 
--Shows what percentage of population got covid 

SELECT Location, Date, population, Total_cases, (total_deaths/population )*100 as DeathPercentage
FROM ProflioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population 

SELECT Location, Population, MAX(Total_cases) as HighestInfectionCount,  MAX(Total_cases/population)*100 as PercentPopulationInfected
FROM ProflioProject..CovidDeaths
Group by location, Population 
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

SELECT Location,MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM ProflioProject..CovidDeaths
Where continent is not null 
Group by location
order by TotalDeathCount desc

--Breaking things down by Contient 


--Showing the Continets with the highest Death count 

SELECT Continent,MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM ProflioProject..CovidDeaths
Where continent is not null 
Group by Continent 
order by TotalDeathCount desc

--Global Numbers 

SELECT Date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as Totaldeaths,  SUM(Cast(new_deaths as int))/SUM
(New_cases)* 100 as DeathPercentage
FROM ProflioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by date 
order by 1,2




--Total Global numbers 

SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as Totaldeaths,  SUM(Cast(new_deaths as int))/SUM
(New_cases)* 100 as DeathPercentage
FROM ProflioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
--Group by date 
order by 1,2

--Looking at Total Population vs Vaccinations 
Select*
From ProflioProject..CovidDeaths dea
Join ProflioProject..Covidvaxinations vax
on dea.location = dea.location
and dea.date = vax.date 

Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(bigint, vax.new_vaccinations )) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProflioProject..CovidDeaths dea
Join ProflioProject..Covidvaxinations vax
	on dea.location = vax.location
	and dea.date = vax.date 
	Where dea.continent is not null 
order by  2, 3

--Use CTE

With PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(Bigint, vax.new_vaccinations )) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProflioProject..CovidDeaths dea
Join ProflioProject..Covidvaxinations vax
	on dea.location = vax.location
	and dea.date = vax.date 
	Where dea.continent is not null
--order by  2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Temp Table 
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
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(Bigint, vax.new_vaccinations )) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProflioProject..CovidDeaths dea
Join ProflioProject..Covidvaxinations vax
	on dea.location = vax.location
	and dea.date = vax.date 
	Where dea.continent is not null
--order by  2, 3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(Bigint, vax.new_vaccinations )) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProflioProject..CovidDeaths dea
Join ProflioProject..Covidvaxinations vax
	on dea.location = vax.location
	and dea.date = vax.date 
	Where dea.continent is not null
--order by  2, 3
