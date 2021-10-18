	select * from CovidDeaths
	where continent is not null
	order by 3,4

	--select * from CovidVaccinations
	--order by 3,4
	--Select data that we are going to be using

	Select CD.location,CD.date,CD.total_cases,CD.new_cases,CD.total_deaths,CD.population
	from ProtfolioProject.dbo.CovidDeaths CD --Order by 1,2

	--Looking at Total cases vs Total Deaths
	--Show likelyhood of dying if you contract covid in your country
	Select CD.location,CD.date,CD.total_cases,CD.total_deaths,
	(CD.total_deaths/CD.total_cases)*100 as DeathPercentage
	from ProtfolioProject.dbo.CovidDeaths CD where location like '%states%' Order by 1,2

	--Looking at Total case vs Population
	--Show what percentage of population got covid
	Select CD.location,CD.date,CD.total_cases,CD.population,
	(CD.total_cases/CD.population)*100 as Percentpopulationinfected
	from ProtfolioProject.dbo.CovidDeaths CD 
	--where location like '%states%' 
	Order by 1,2

	--Looking at countries with the Highest infected rate compared to population

	Select CD.location,CD.population,Max(CD.total_cases) as Hightestinfectedcount,
	Max((CD.total_cases/CD.population))*100 as Percentpopulationinfected
	from ProtfolioProject.dbo.CovidDeaths CD 
	--where location like '%states%'
	Group by CD.location,CD.population
	Order by Percentpopulationinfected desc

	--Showing Countries with the Highest Death Count per Population

	Select CD.location,Max(cast(CD.total_deaths as int)) as Total_Death_Count
	from ProtfolioProject.dbo.CovidDeaths CD 
	--where location like '%states%'
	where continent is not null
	Group by CD.location
	Order by Total_Death_Count desc

	--LET'S BREAK THINGS DOWN BY CONTINENT
	Select CD.location,Max(cast(CD.total_deaths as int)) as Total_Death_Count
	from ProtfolioProject.dbo.CovidDeaths CD 
	--where location like '%states%'
	where continent is null
	Group by CD.location
	Order by Total_Death_Count desc

	--SHOWING CONTINTENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

	Select CD.continent,Max(cast(CD.total_deaths as int)) as Total_Death_Count
	from ProtfolioProject.dbo.CovidDeaths CD 
	--where location like '%states%'
	where continent is not null
	Group by CD.location
	Order by Total_Death_Count desc

	--GLOBAL NUMBERS

	Select CD.date,SUM(CD.new_cases) as Total_Cases, Sum(Cast(CD.new_deaths as int))
	as Total_Deaths,Sum(Cast(CD.new_deaths as int))/sum(CD.new_cases)*100 as DeathPercentage
	from ProtfolioProject.dbo.CovidDeaths CD
	 --where location like '%states%' 
	where continent is not null
	Group by CD.date 
	Order by 1,2
	--************
    Select SUM(CD.new_cases) as Total_Cases, Sum(Cast(CD.new_deaths as int))
	as Total_Deaths,Sum(Cast(CD.new_deaths as int))/sum(CD.new_cases)*100 as DeathPercentage
	from ProtfolioProject.dbo.CovidDeaths CD
	 --where location like '%states%' 
	where continent is not null
	--Group by CD.date 
	Order by 1,2
	

	--Lets Join The Two Table
	--looking at Total population Vs Vaccinations
	Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
	,Sum(Cast(CV.new_vaccinations AS bigint)) over(partition by CD.location 
	Order by CD.location,CD.date) as PeopleVaccinated
	--,(PeopleVaccinated/CD.population)*100
	from ProtfolioProject.dbo.CovidDeaths CD
	Join ProtfolioProject.dbo.CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
	where CD.continent is not null
	Order by 2,3

	--USE CTE

	with PopulationVsVaccination(continent,location,date,population,new_vaccinations,PeopleVaccinated)
	as
	(
	Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
	,Sum(Cast(CV.new_vaccinations AS bigint)) over(partition by CD.location 
	Order by CD.location,CD.date) as PeopleVaccinated
	--,(PeopleVaccinated/CD.population)*100
	from ProtfolioProject.dbo.CovidDeaths CD
	Join ProtfolioProject.dbo.CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
	where CD.continent is not null
	--Order by 2,3
	)
	Select *,(PeopleVaccinated/population)*100 from PopulationVsVaccination

	--TEMP TABLE
	Drop table if Exists #PrecentPeopleVaccinated
	Create Table #PrecentPeopleVaccinated
	(continent nvarchar(255),
	location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	PeopleVaccinated numeric
	)
	INSERT INTO #PrecentPeopleVaccinated
	Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
	,Sum(Cast(CV.new_vaccinations AS bigint)) over(partition by CD.location 
	Order by CD.location,CD.date) as PeopleVaccinated
	--,(PeopleVaccinated/CD.population)*100
	from ProtfolioProject.dbo.CovidDeaths CD
	Join ProtfolioProject.dbo.CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
	--where CD.continent is not null
	--Order by 2,3
	Select *,(PeopleVaccinated/population)*100 from #PrecentPeopleVaccinated


	--Creating View to store data for later Visaulizations

	Create view PrecentPeopleVaccinated as
	Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
	,Sum(Cast(CV.new_vaccinations AS bigint)) over(partition by CD.location 
	Order by CD.location,CD.date) as PeopleVaccinated
	--,(PeopleVaccinated/CD.population)*100
	from ProtfolioProject.dbo.CovidDeaths CD
	Join ProtfolioProject.dbo.CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
	where CD.continent is not null
	--Order by 2,3

	Select * from PrecentPeopleVaccinated
