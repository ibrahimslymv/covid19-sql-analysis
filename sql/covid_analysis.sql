
--CORONAVIRUS DATA 2020-01-01 TO 2021-04-30

--2020-01-01, 2021-04-30 arasındaki tarixdə baş verən COVİD-19 məlumatları
select * from CovidDeathsnew;


SELECT location, date, total_cases, new_cases, total_deaths, population
from CovidDeathsnew;

--TOTAL DEATHS AND TOTAL CASES FOR EACH COUNTRY

select location,
    max(total_cases)as total_case_number,
    max(total_deaths) as total_deaths_number
from 
    CovidDeathsnew
WHERE 
    continent is not null
group by
    location 
order by 
    location; 

      
-- TOTAL CASES VS TOTAL DEATH WITH PERCENTAGE

SELECT 
    location, 
    MAX(total_cases) AS total_case_number,
    MAX(total_deaths) AS total_deaths_number, 
    ROUND((MAX(CAST(total_deaths AS FLOAT)) / MAX(CAST(total_cases AS FLOAT)) * 100), 3) AS death_percentage
FROM 
    CovidDeathsnew 
WHERE 
    continent is not null
GROUP BY 
    location 
ORDER BY 
    death_percentage desc;

 
-- TOTAL CASES VS POPULATION

SELECT 
    location, 
    MAX(total_cases) AS total_case_number,
    max(population) AS Population, 
    ROUND((MAX(CAST(total_cases AS FLOAT)) / max(population) * 100), 3) AS sickness_percentage
FROM 
    CovidDeathsnew 
WHERE 
    continent is not null
GROUP BY 
    location 
ORDER BY 
    sickness_percentage desc;




--MIXING TOTAL CASES , TOTAL DEATHS AND POPULATION



SELECT 
    location,
    max(population) AS Population,
    MAX(total_cases) AS total_case_number,
    MAX(total_deaths) AS total_deaths_number,  
    ROUND((MAX(CAST(total_cases AS FLOAT)) / max(population) * 100), 3) AS sickness_percentage,
    ROUND((MAX(CAST(total_deaths AS FLOAT)) / MAX(CAST(total_cases AS FLOAT)) * 100), 3) AS death_percentage
FROM 
    CovidDeathsnew 
WHERE 
    continent is not null
GROUP BY 
    location 
ORDER BY 
    Population desc;



--INFORMATION ABOUT AZERBAIJAN


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM 
    CovidDeathsnew
WHERE 
    LOCATION LIKE '%AZER%';




--INFORMATION WITH THE HELP OF CONTINENTS



SELECT 
    continent,
    max(population) AS Population,
    MAX(total_cases) AS total_case_number,
    MAX(total_deaths) AS total_deaths_number,  
    ROUND((MAX(CAST(total_cases AS FLOAT)) / max(population) * 100), 3) AS sickness_percentage,
    ROUND((MAX(CAST(total_deaths AS FLOAT)) / MAX(CAST(total_cases AS FLOAT)) * 100), 3) AS death_percentage
FROM 
    CovidDeathsnew 
WHERE 
    continent is not null
GROUP BY 
    continent 
ORDER BY 
    Population desc;




--GLOBAL NUMBERS



SELECT 
    DATE, 
    SUM(Population) as available_population,
    SUM(total_cases) AS total_case_sum,
    SUM(total_deaths) AS total_death_sum,
    SUM(cast(total_cases as float))/SUM(cast(Population as float))*100 AS ilness_percentage
FROM 
    CovidDeathsnew 
WHERE 
    continent is not null
GROUP BY 
    date
ORDER BY 
    1 asc;





Select * From CovidDeathsnew death
join
Covidvaccinations vac
On death.date = vac.date
and death.location = vac. location;
 



 ---TOTAL POPULATION


Select SUM(MAX_POPULATION)
From 
    (SELECT MAX(POPULATION) AS MAX_POPULATION,LOCATION
    From 
    CovidDeathsnew  death
    WHERE 
    continent is not null
    GROUP BY 
    location) AS sum_population_table





 --TOTAL POPULATION VS TOTAL VACCINATIONS



    
Select  death.continent,death.location,death.population,death.date,vac.new_vaccinations from CovidDeathsnew death
join
Covidvaccinations vac
On death.date = vac.date
and death.location = vac. location
where death.continent is not null
order by 4;


-- ANALYZING TOTAL POPULATION, VACCINATED PEOPLE AND VACINNATION PERCENTAGE WITH THE HELP OF CTE


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, 
  death.Date) as RollingPeopleVaccinated
From CovidDeathsnew death
Join CovidVaccinations vac
    On death.location = vac.location
    and death.date = vac.date
where death.continent is not null
)
Select *,(RollingPeopleVaccinated*1.0/Population)*100  AS VaccinationPercentage
From PopvsVac
Order by  3 desc;




--ANALYZING TOTAL POPULATION, VACCINATED PEOPLE AND VACINNATION PERCENTAGE WITH THE HELP OF TEMP TABLE

DROP TABLE  IF EXISTS #COVID_COMPARE 
CREATE TABLE #COVID_COMPARE
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #COVID_COMPARE
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, 
  death.Date) as RollingPeopleVaccinated
From CovidDeathsnew death
Join CovidVaccinations vac
    On death.location = vac.location
    and death.date = vac.date
where death.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100  AS VaccinationPercentage 
from #COVID_COMPARE;



-- CREATING VIEW FOR VISUALIZATIONS


DROP VIEW IF EXISTS PEOPLE_VACCINATED_VISUALIZE;
GO

CREATE VIEW PEOPLE_VACCINATED_VISUALIZE AS
SELECT 
    death.continent, 
    death.location, 
    death.date, 
    death.population, 
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
FROM CovidDeathsnew death
JOIN CovidVaccinations vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent is not null;
GO


SELECT * FROM PEOPLE_VACCINATED_VISUALIZE;
