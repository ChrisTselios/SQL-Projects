USE [Project Portfolio];

SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float

ALTER TABLE CovidDeaths
ALTER COLUMN population bigint

ALTER TABLE CovidDeaths
ALTER COLUMN new_cases float

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths float

-- COUNTRY SCALE ANALYSIS

-- Main columns of interest
SELECT Location, date, total_cases, new_cases, total_deaths,new_deaths,icu_patients, hosp_patients, population
FROM CovidDeaths
WHERE continent IS NOT NULL
;


-- Percentage of icu patients vs total ammount of patients ( icu + hospital )
SELECT Location, date, total_cases, icu_patients, hosp_patients, 
                   icu_patients/(NULLIF(CAST(hosp_patients AS FLOAT),0)+NULLIF(CAST(icu_patients AS FLOAT),0))*100 AS Perc_icu_patients
FROM CovidDeaths
WHERE continent IS NOT NULL -- AND Location = 'italy'
ORDER BY 1,2;

-- Top 5 countries with the most average icu patients due to COVID
SELECT TOP 5 Location, AVG(CONVERT(FLOAT,icu_patients))AS average_icu_patients
FROM CovidDeaths
WHERE continent IS NOT NULL -- AND Location = 'italy'
GROUP BY location
ORDER BY 2 DESC;


-- Percentage of population that got COVID
SELECT Location, date, total_cases, population, (total_cases/population)*100 as Infected_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL -- AND Location = 'Greece'
order by 1,2;

-- Countries sorted by the percentage of infected compared to the population
SELECT Location, population, MAX(total_cases) as Highest_Inf_Count, MAX((total_cases/population))*100 as Infected_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL -- AND Location = 'Greece'
GROUP BY Location, population
order by 4 DESC;


-- Countries sorted by the highest death count
SELECT Location, MAX(total_deaths) as Highest_death_Count
FROM CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY Location
order by 2 DESC;


-- Likelihood of death for confirmed COVID cases in each country
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL -- AND Location = 'Greece'
order by 1,2 ;



-- CONTINENT SCALE ANALYSIS

-- Total death count for each continent
SELECT continent, MAX(total_deaths) as Max_Death_count
FROM CovidDeaths
WHERE continent IS NOT NULL -- AND Location = 'Greece'
GROUP BY continent
ORDER BY 2 DESC;



-- GLOBAL SCALE ANALYSIS
 
-- Death percentage from confirmed cases each day 
SELECT date, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, ISNULL(SUM(new_deaths) / NULLIF(SUM(new_cases),0)*100,0) AS Death_perc
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total death percentage from confirmed cases each day
SELECT SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, ISNULL(SUM(new_deaths) / NULLIF(SUM(new_cases),0)*100,0) AS Death_perc
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



-- Total population vs vaccinations
DROP VIEW NewPeopleVaccinations;
-- VIEW 1
CREATE VIEW NewPeopleVaccinations AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.people_vaccinated, 
CONVERT(FLOAT,cv.people_vaccinated)-LAG(CONVERT(FLOAT,cv.people_vaccinated)) OVER(PARTITION BY cd.Location ORDER BY CAST(cd.location AS VARCHAR(50)) , cd.date) AS new_people_vaccinated
FROM CovidDeaths as cd
  JOIN CovidVaccinations as cv
    ON cv.location = cd.location 
    AND cv.date = cd.date 
WHERE cd.continent IS NOT NULL --AND cd.location LIKE '%greece%'
;

-- CTE 1
WITH Rolling_vacc (continent, location,date,population, people_vaccinated,new_people_vaccinated,Rolling_vaccinations)
AS (
SELECT  continent,location,date, population,people_vaccinated,new_people_vaccinated,
SUM(new_people_vaccinated) OVER(PARTITION BY location ORDER BY CAST(location AS VARCHAR(50)),date) AS Rolling_vaccinations
FROM NewPeopleVaccinations
WHERE continent IS NOT NULL -- AND location LIKE '%greece%'
)


SELECT continent,location, population, MAX(Rolling_vaccinations) AS total_people_vacc,(MAX(CAST(people_vaccinated AS FLOAT))/population)*100 AS perc_vaccinated
FROM Rolling_vacc
WHERE continent IS NOT NULL --AND location LIKE '%greece%'
GROUP BY  continent,location, population
ORDER BY 1,2 ;
















