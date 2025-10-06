#  Global covid 19 Data analysis project

## Project Overview

**Project Title**: Covid 19 Data analysis project
**Database**: `Portfolio project`

This is a SQL-based exploration of vaccinations, infections and deaths across the globe from covid.

## Objectives

1. **Retrieve the dataset that I'll be using**: Extract the data from the global server.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **DataAnalysis**: Use SQL to answer specific research questions for inferential statistics.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `Portfolio project`.
- **Table Creation**: A table named `CovidDeaths`  and `CovidVaccinations`  is created to store the death and vaccination data. 


### 2. Data Exploration & Cleaning

- **Record Check**: Look at all the records in the datasets.
- **Relevancy check**: Select the exact data columns that I'll be using.
- **Country Count**: Identify all unique countries included in the study.

```sql
SELECT * 
FROM[dbo].[CovidVaccinations]

SELECT  *
FROM CovidDeaths

SELECT [location],[date],[total_cases],[new_cases],[total_deaths],[population]
FROM[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
ORDER BY [location],date

SELECT COUNT(DISTINCT [location]) AS No_of_countries
FROM CovidDeaths

```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific study questions:

1. **What is the global fatality rate?**:
```sql

SELECT SUM([total_cases]) AS total_cases,SUM(CAST([total_deaths] AS INT)) AS total_deaths, SUM(CAST([total_deaths] AS INT))/SUM([total_cases]) * 100 AS Global_Death_Rate
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL

```

2. **Looking at total cases vs total deaths in Diff countries(Shows likelihood of dying if you contract covid in your country)**:
```sql

SELECT SUM([total_cases]) AS total_cases,SUM(CAST([total_deaths] AS INT)) AS total_deaths, SUM(CAST([total_deaths] AS INT))/SUM([total_cases]) * 100 AS Death_Rate
FROM [dbo].[CovidDeaths]
WHERE [location]='Kenya'--You can input your own country

```

3. **What is the percentage of the population infected by country?**:
```sql

SELECT [location],[date],[total_cases],[population],ROUND(([total_cases]/population *100),2) AS 'Infection_rate'
FROM[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
ORDER BY [location],date


```

4. **Which countries have the highest infection rates?**:
```sql
SELECT [location],MAX([total_cases]) AS 'HighestInfectionCount' ,[population],MAX(ROUND(([total_cases]/population *100),2)) AS 'Infection_rate'
FROM[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [location],population
ORDER BY Infection_rate DESC
```

5. **Which countries have the highest number of infections by day?**:
```sql
SELECT  [location],[date],MAX([total_cases]) AS 'HighestInfectionCount' ,[population],MAX(ROUND(([total_cases]/population *100),2)) AS 'Infection_rate'
FROM[dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [location],[population],[date]
ORDER BY Infection_rate DESC
```

6. **Which countries had the most deaths**:
```sql
SELECT [location],MAX(CAST([total_deaths] AS INT)) AS HighestDeathCount 
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL 
GROUP BY [location]
ORDER BY HighestDeathCount DESC
```

7. **Which continents had the most fatalities**:
```sql
SELECT continent,MAX(CAST([total_deaths] AS INT)) AS HighestDeathCount 
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL 
GROUP BY continent
ORDER BY HighestDeathCount DESC
```

8. **What percentage of the population has been vaccinated?**:
```sql
 SELECT dea.continent,dea.location,
 dea.date,dea.population,vac.new_vaccinations
 FROM [dbo].[CovidDeaths] dea
 JOIN[dbo].[CovidVaccinations] vac
 ON dea.location=vac.location
 AND dea.date=vac.date
 WHERE DEA.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
 ORDER BY 2,3
```

9. **Check out % population of individual countries that have been vaccinated**:
```sql
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
```

10. **What countries have the highest vaccination rates?**:
```sql
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
```

11. **Roll out vaccination numbers by location**
```sql
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
```

12. **Finding out the global numbers of fatalities as of the most recent date**
```sql
SELECT [date],SUM([total_cases]) AS TotalCases,
SUM(CAST([total_deaths] AS INT)) AS TotalDeaths,
SUM(CAST([total_deaths] AS INT))/SUM([total_cases]) * 100 AS GlobalDeathRate
FROM [dbo].[CovidDeaths]
WHERE [continent] IS NOT NULL
GROUP BY [date]
ORDER BY [date] DESC
```

## Findings

- **Death rate**: Reveals the likelihood of succumbing to the disease in individual countries.
- **Vaccination rate**: Identifies the percentag of the population that has been enrolled in the vaccination regimen by country & continents.
- **Infection rate**: Reveals the danger zones; where the disease is most prevalent.

## Reports

- **Continental death counts**: A detailed report summarizing total sdeaths grouped by continents.
- **Country specific infection rates**: Shows the report of daily number of new infections by country.
- **Global numbers overview**: A summary of the total infections, deaths, and vaccinations across the globe.

## Conclusion

This project serves as a means to understand the global impact of the covid 19 pandemic and it's trend across different countries worldwide.

