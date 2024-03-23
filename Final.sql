/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
Select *
From PortfolioProject..CovidDeath
Where continent is not null 
	and
	total_cases is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--Order by 3 ,4

SELECT location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeath
Order by 1 ,2

--Looking at total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your Country

SELECT location,date,total_cases,total_deaths,CAST(total_deaths AS float)/CAST(total_cases AS float)*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where continent is not null 
	and
	total_cases is not null
	and 
	total_deaths is not null
--Where location like'%state%'
--Order by DeathPercentage


--Looking at total Cases vs Population
--Shows what percentage of population got Covid 

SELECT location,date,population,total_cases,(total_cases/population)*100 as PersectPopulationInfected 
From PortfolioProject..CovidDeath
Where location ='Bangladesh'
Order by PersectPopulationInfected 

--Looking at the countries with highest Infection Rate Compared to Population

SELECT 
	location,
	population,
	MAX(total_cases) as HighestInfectionCount ,
	MAX((total_cases/population))*100 as  PersectPopulationInfected
From PortfolioProject..CovidDeath
Group by 
	location,
	population
Order by PersectPopulationInfected desc
	
-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Let's Breake Things Down By Continent 

--Showing the continet with highest death count per population.

Select continent,Max(cast(Total_deaths as int ))as TotalDeathCount
From PortfolioProject..CovidDeath
where continent is not  null
Group by continent
order by TotalDeathCount desc


--Global Number
Select date,SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeath
where continent is not  null
Group by date
order by 4 desc

--Joining 2 dataSets

Select *
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location =vac.location
		and
		dea.date =vac.date

--Looking  at Total Population Vs Vaccinations

Select dea.continent,dea.date,dea.population,  vac.new_vaccinations 
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location =vac.location
		and
		dea.date =vac.date
Where dea.continent is not null
order by 4 

--New Vaccinations Per Day
Select dea.continent,dea.location,dea.date,dea.population,  vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations))OVER(Partition by dea.location Order by dea.location,dea.date)
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location =vac.location
		and
		dea.date =vac.date
Where dea.continent is not null
	and dea.location = 'Bangladesh'
order by 4 

--Looking at total Population vs Vaccinations

Select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location =vac.location
		and
		dea.date =vac.date
Where dea.continent is not null
	  and 
	  vac.new_vaccinations is not null
order by 2,3

--USE CTE
With PopVsVac( continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(

Select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location =vac.location
		and
		dea.date =vac.date
Where dea.continent is not null
	  and 
	  vac.new_vaccinations is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population) *100
From PopVsVac

--TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 

)


insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location =vac.location
		and
		dea.date =vac.date
Where dea.continent is not null
	  and 
	  vac.new_vaccinations is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population) *100
From #PercentPopulationVaccinated

--Creating View To Store data for later visulizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location =vac.location
		and
		dea.date =vac.date
Where dea.continent is not null
	  and 
	  vac.new_vaccinations is not null