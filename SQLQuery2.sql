--SELECT * 
--FROM[dbo].[CovidVaccinations]

--Select the data that I'll be using
SELECT [location],[date],[total_cases],[new_cases],[total_deaths],[population]
FROM[dbo].[CovidDeaths]
ORDER BY [location],date

--Looking at total cases vs total deaths in Diff countries
--Shows the likelihood of dying if you contract covid in your country
SELECT [location],[date],[total_cases],[total_deaths],ROUND(([total_deaths]/[total_cases]*100),2) AS '%_Deaths'
FROM[dbo].[CovidDeaths]
WHERE [location]LIKE '%Kenya%'
ORDER BY [location],date

--Looking at the percentage of the population infected
SELECT [location],[date],[total_cases],[population],ROUND(([total_cases]/population *100),2) AS 'Infection_rate'
FROM[dbo].[CovidDeaths]
WHERE [location]LIKE '%Kenya%'
ORDER BY [location],date
