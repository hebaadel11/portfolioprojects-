select * 
from [dbo].[CovidDeaths$]
where continent is not null
order by 3,4

--select * 
--from [dbo].[CovidVaccinations$]
--order by 3,4

-- select the data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from [portifolio DB]..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as deathpersentage 
from [portifolio DB]..CovidDeaths$
where location like '%state%'
order by 1,2

-- looking at totalcases vs population 
-- shows what percentage of popylation got covid 

select location, date, total_cases, population, (total_cases/ population)*100 as deathpersentage 
from [portifolio DB]..CovidDeaths$
where location like '%state%'
order by 1,2

-- loking at countries with highest infection rate compared to population

select location, population, max (total_cases) as 'highestinfectioncount', max((total_cases/ population))*100 as deathpersentageinfected
from [portifolio DB]..CovidDeaths$
group by population , location
--where location like '%state%'
order by deathpersentageinfected desc

-- showing countries with highest death count per population
-- let's break things down by continent 

select location, max (cast( total_deaths as int )) as 'totaldeathcount'
from [portifolio DB]..CovidDeaths$
group by location
--where location like '%state%'
order by totaldeathcount desc

select location, max (cast( total_deaths as int )) as 'totaldeathcountt'
from [portifolio DB]..CovidDeaths$
where continent is not null
group by location
--where location like '%state%'
order by totaldeathcountt desc


-- showing continent with the highest death per population 

select continent, max (cast( total_deaths as int )) as 'totaldeathcountt'
from [portifolio DB]..CovidDeaths$
where continent is not null
group by continent
--where location like '%state%'
order by totaldeathcountt desc

-- global numbers 

select   sum (new_cases) as 'total cases', sum (cast(new_deaths as int )) as 'total death',
sum (cast(new_deaths as int ))/sum (new_cases)*100 as deathpercentageee
--total_cases, total_deaths, (total_deaths/ total_cases)*100 as deathpersentagee 
from [portifolio DB]..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--joins
-- looking at total popualtion vs vaccination

select * 
from  [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location 
and dea.date = vac.date 

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int )) over ( partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccination
from  [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3 

-- use CTE

with popvsvac  (continent, location, date , population,RollingPeopleVaccination,new_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int )) over ( partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccination
from  [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 
)
 select * , RollingPeopleVaccination/ population
from popvsvac 


--TEMP TABLE 

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(225),
lovation nvarchar(225),
date datetime,
population numeric, 
new_vaccination numeric,
RollingPeopleVaccination numeric)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int )) over ( partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccination
from  [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location 
and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3 

 select * , RollingPeopleVaccination/ population
from #percentpopulationvaccinated

-- creating vier to store data later visualization 


create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int )) over ( partition by dea.location order by dea.location,dea.date) 
 as RollingPeopleVaccination
from  [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 
select *
from percentpopulationvaccinated 











