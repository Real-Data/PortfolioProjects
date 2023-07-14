--See if import worked
select total_vaccinations, date, location
from covid_vaccinations cv 
where total_vaccinations is not null
order by 1 asc

select location, continent, total_deaths 
from covid_deaths cd 
where location ilike '%scot%'



-- Look at death percentages in the Netherlands

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentages
from covid_deaths
where location like '%etherlands%'
order by 1, 2;

-- Looking at total cases vs population
-- Shows what percentage of population got covid
select location, date, total_cases,population, (total_cases/population)*100 as infection_percentages
from covid_deaths
where location like '%etherlands%'
order by 1 , 2;


-- Looking at country with highest infection rate compared to population
select location, max(total_cases) as higehst_infection_count, population, max((total_cases/population))*100 as infection_percentages
from covid_deaths
group by population , location
order by infection_percentages desc;

-- Showing countries with highest death count per population
select location, max(total_deaths) as highest_death_count
from covid_deaths
where continent is not null and total_deaths is not null
group by location
order by highest_death_count desc;


-- Showing continents with highest death count per population
select location, max(total_deaths) as highest_death_count
from covid_deaths
where continent is null  
group by  location
order by highest_death_count desc;

-- Global numbers before the vaccination
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/ sum(new_cases) * 100 as death_percentage
from covid_deaths
where new_cases > 0 and total_deaths > 0 and continent is not null and date < '2021-01-01'
 
--group by date 
order by 1,2;

--change varchar to int data type by first remove an empty char
--https://stackoverflow.com/questions/13170570/change-type-of-varchar-field-to-integer-cannot-be-cast-automatically-to-type-i
--UPDATE the_table SET col_name = replace(col_name, 'some_string', '');

--looking at total populations vs vaccinations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,
cd.date) as rolling_people_vaccinated
from covid_deaths cd 
join covid_vaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

--USE CTE to show rolling_people_vaccinated. You can't calculate on a column you just created by making a cte you can.

with pop_vs_vac (continent, location, date, population, rolling_people_vaccinated, new_vaccinations)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,
cd.date) as rolling_people_vaccinated
from covid_deaths cd 
join covid_vaccinations cv 
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
order by 2,3
)

select *, (rolling_people_vaccinated/population) * 100
from pop_vs_vac

--TEMP TABLE

create temporary table percentpopulationvaccinated
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into percentpopulationvaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from covid_deaths cd
join covid_vaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date

select *, (rolling_people_vaccinated/population) * 100
from percentpopulationvaccinated

