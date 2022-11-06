create database covid_19;
use covid_19;

select * from covid_stats_state_wise_delta;

-- Question 1: State-wise testing ratio
-- Testing ratio = total number of tests / total population

SELECT * FROM covid_stats_state_wise_totals;
SELECT * FROM covid_stats_state_wise_meta;
SELECT  c.state as State,c.state_code,A.tested as Statewise_total_number_of_tests, 
B.population as Statewise_population, ROUND((CAST(A.tested as FLOAT)/B.population),2) as Testing_ratio 
FROM covid_stats_state_wise_totals as A
INNER JOIN covid_stats_state_wise_meta as B ON
A.state = B.state
inner join state_name as C on C.state_code=b.state
ORDER BY Testing_ratio DESC;

-- Question 2: Compare delta7 confirmed cases with respect to vaccination
-- Insight one : Vaccination 1 v/s confirmed cases

SELECT c.state,c.state_code,A.confirmed,A.vaccinated1,A.vaccinated2,B.population,
Round((CAST(A.confirmed as FLOAT)/B.population *1000000),0) as  confirmed_case_population_per_million,
Round((CAST(A.vaccinated1 as FLOAT)/B.population *1000000),0) as vaccinated_1_population_per_million,
Round((CAST(A.vaccinated2 as FLOAT)/B.population *1000000),0) as  vaccinated_2_population_per_million
FROM covid_stats_state_wise_delta7 as A
INNER JOIN covid_stats_state_wise_meta as B
ON A.state = B.state
inner join state_name as c on c.state_code=b.state
ORDER BY ( vaccinated_1_population_per_million) desc;

-- (Q3) Most confirmed cases KPI [Statewise total data]
SELECT b.state,b.state,confirmed,deceased,recovered,tested,vaccinated1,vaccinated2 
FROM covid_stats_state_wise_totals as a
inner join state_name as b on a.state=b.state_code
ORDER BY confirmed DESC;

-- (Q4) Most confirmed cases KPI [Statewise Delta - one day analysis]
SELECT b.state,b.state_code,confirmed,deceased,recovered,tested,vaccinated1,vaccinated2 FROM covid_stats_state_wise_delta as a
inner join state_name as b on a.state=b.state_code
ORDER BY confirmed DESC;

-- Question 3: Categorize total number of confirmed, deceased, v1, v2,   
-- cases in a state by Months and come up with that one month 
-- which was worst for India in terms of the number of cases

-- FOR TOTAL MONTHLY CONFIRMED CASES


SELECT YEAR(dates) as Year ,month(dates) as Month,SUM(Daily_confirmed) as confirmed_cases,SUM(deceased),sum(vaccinated1),sum(vaccinated2) FROM
(SELECT *,(confirmed-data) as Daily_confirmed FROM 
(SELECT *, lag(confirmed,1) OVER(PARTITION BY state ORDER BY dates) AS data
FROM covid_stats_state_wise_timeseries) a ) b
GROUP BY month
ORDER BY confirmed_cases DESC;



-- TOP states wrt. confirmed,deceased

SELECT  b.state,confirmed,
population,ROUND((CAST(confirmed as FLOAT)/population)*100000,0) AS Confirmed_cases_per_lakh
FROM covid_stats_state_wise_totals AS A
INNER JOIN state_name AS B ON A.state=B.state_code
INNER JOIN covid_stats_state_wise_meta AS C ON A.state=C.state
WHERE a.state != 'total'
ORDER BY Confirmed_cases_per_lakh DESC limit 1;

-- top deceased state
SELECT b.state,deceased,
population,ROUND((CAST(deceased as FLOAT)/population)*100000,0) AS Deceased_cases_per_lakh 
FROM covid_stats_state_wise_totals AS A
INNER JOIN state_name AS B ON A.state=B.state_code
INNER JOIN covid_stats_state_wise_meta AS C ON A.state=C.state
WHERE a.state != 'total'
ORDER BY Deceased_cases_per_lakh DESC limit 1;

-- Delta 7 confirmed to vaccination comparison

SELECT  b.state,confirmed,vaccinated1 FROM covid_stats_state_wise_delta7 AS A
INNER JOIN state_name as B 
ON A.state = B.state_code
WHERE b.state != 'total'
ORDER BY confirmed DESC limit 5;

-- TOP 10 Stateswise data for tested, confirmed, recovered, deceased, vaccinated 1 and vaccinated 2

SELECT  a.state,vaccinated1,vaccinated2 FROM covid_stats_state_wise_totals AS A
INNER JOIN state_name AS B 
ON A.state = B.state_code
WHERE a.state != 'total'
ORDER BY vaccinated2 DESC limit 10;


SELECT  a.state,deceased FROM covid_stats_state_wise_totals AS A
INNER JOIN state_name AS B 
ON A.state = B.state_code
WHERE a.state != 'total'
ORDER BY vaccinated2 DESC limit 10;

SELECT  a.state,tested FROM covid_stats_state_wise_totals AS A
INNER JOIN state_name AS B 
ON A.state = B.state_code
WHERE a.state != 'total'
ORDER BY vaccinated2 DESC limit 10;
