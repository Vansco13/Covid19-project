
--SELECT * 
--FROM[dbo].[CovidVaccinations]

--Select the data that I'll be using
SELECT [location],[date],[total_cases],[new_cases],[total_deaths],[population]
FROM[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
ORDER BY [location],date

--Checks the global fatality rate
SELECT SUM([total_cases]) AS total_cases,SUM(CAST([total_deaths] AS INT)) AS total_deaths, SUM(CAST([total_deaths] AS INT))/SUM([total_cases]) * 100 AS Global_Death_Rate
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL

--Looking at total cases vs total deaths in Diff countries
--Shows the likelihood of dying if you contract covid in your country
SELECT SUM([total_cases]) AS total_cases,SUM(CAST([total_deaths] AS INT)) AS total_deaths, SUM(CAST([total_deaths] AS INT))/SUM([total_cases]) * 100 AS Death_Rate
FROM [dbo].[CovidDeaths]
WHERE [location]='Kenya'



--Looking at the percentage of the population infected
SELECT [location],[date],[total_cases],[population],ROUND(([total_cases]/population *100),2) AS 'Infection_rate'
FROM[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
ORDER BY [location],date

--What countries have the highest infection rates
SELECT [location],MAX([total_cases]) AS 'HighestInfectionCount' ,[population],MAX(ROUND(([total_cases]/population *100),2)) AS 'Infection_rate'
FROM[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [location],population
ORDER BY Infection_rate DESC

--What countries have the highest infection rates by day
SELECT  [location],[date],MAX([total_cases]) AS 'HighestInfectionCount' ,[population],MAX(ROUND(([total_cases]/population *100),2)) AS 'Infection_rate'
FROM[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [location],[population],[date]
ORDER BY Infection_rate DESC

--Which countries had the most deaths
SELECT [location],MAX(CAST([total_deaths] AS INT)) AS HighestDeathCount 
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL 
GROUP BY [location]
ORDER BY HighestDeathCount DESC

--Which continents had the most fatalities
SELECT continent,MAX(CAST([total_deaths] AS INT)) AS HighestDeathCount 
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL 
GROUP BY continent
ORDER BY HighestDeathCount DESC

--FINDING OUT THE GLOBAL NUMBERS OF FATALITIES AS OF THE MOST RECENT DATE
SELECT [date],SUM([total_cases]) AS TotalCases,
SUM(CAST([total_deaths] AS INT)) AS TotalDeaths,
SUM(CAST([total_deaths] AS INT))/SUM([total_cases]) * 100 AS GlobalDeathRate
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [date]
ORDER BY [date] DESC


 --Combining the deaths dataset with the vaccinations dataset
 SELECT * 
 FROM [dbo].[CovidDeaths]
 JOIN[dbo].[CovidVaccinations]
 ON[dbo].[CovidDeaths].location=[dbo].[CovidVaccinations].location
 AND [dbo].[CovidDeaths].date=[dbo].[CovidVaccinations].date

 --Let's look at the total population in the world that has been vaccinated
 SELECT dea.continent,dea.location,
 dea.date,dea.population,vac.new_vaccinations
 FROM [dbo].[CovidDeaths] dea
 JOIN[dbo].[CovidVaccinations] vac
 ON dea.location=vac.location
 AND dea.date=vac.date
 WHERE DEA.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
 ORDER BY 2,3

 --Using window function to roll out vaccination numbers by location
  SELECT dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT)) OVER ( PARTITION BY dea.location ORDER BY  dea.date ) AS RunningTotal
 FROM [dbo].[CovidDeaths] dea
 JOIN[dbo].[CovidVaccinations] vac
 ON dea.location=vac.location
 AND dea.date=vac.date
 WHERE DEA.continent IS NOT NULL AND  vac.new_vaccinations IS NOT NULL
 ORDER BY 2,3

--Check out the % of the country vaccinated
--Use CTE
WITH VaccinationTotals (continent, 
location, date,population,new_vaccinations,RunningTotal)
AS
(
 SELECT dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT)) OVER ( PARTITION BY dea.location ORDER BY  dea.date ) AS RunningTotal
 FROM [dbo].[CovidDeaths] dea
 JOIN[dbo].[CovidVaccinations] vac
 ON dea.location=vac.location
 AND dea.date=vac.date
 WHERE DEA.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

)
SELECT*,
(RunningTotal/population)*100 AS VaccinationRate
FROM VaccinationTotals
ORDER BY 2,3
 
 --What countries have the highest vaccination rates
WITH VaccinationTotals (continent,
location, date,population,new_vaccinations,RunningTotal)
AS
(
 SELECT dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT)) OVER ( PARTITION BY dea.location ORDER BY  dea.date ) AS RunningTotal
 FROM [dbo].[CovidDeaths] dea
 JOIN[dbo].[CovidVaccinations] vac
 ON dea.location=vac.location
 AND dea.date=vac.date
 WHERE DEA.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

)
SELECT*,
(RunningTotal/population)*100 AS VaccinationRate
FROM VaccinationTotals
ORDER BY 2,3

