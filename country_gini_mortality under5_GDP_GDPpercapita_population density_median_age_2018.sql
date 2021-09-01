# ZISTUJEM country, gini, mortality_under5, 2020GDP, 2019GDP, 2020_GDP per capita, 2019_GDP per capita, population density, median_age_2018 
WITH ec1 AS (
SELECT
	country,
# preskupujem parametre za rok 2019 a 2020
	GDP AS '2020_GDP',
	LEAD(GDP) OVER(PARTITION BY country ORDER BY country) AS '2019_GDP',
	population AS '2020_population',
	LEAD(population) OVER(PARTITION BY country ORDER BY country) AS '2019_population',
	gini AS '2020_GINI',
	LEAD(gini) OVER(PARTITION BY country ORDER BY country) AS '2019_GINI',
	mortaliy_under5 AS '2020_mortaliy_under5',
	LEAD(mortaliy_under5) OVER(PARTITION BY country ORDER BY country) AS '2019_mortaliy_under5',
	year
FROM economies
WHERE year in ('2020', '2019')
),
# population_density a median_age_2018 vyberam z tabulky countries 
c AS (
SELECT 	
	country,
	population_density,
	median_age_2018
FROM countries
)
# konsolidujem finalnu tabulku 
SELECT 
ec1.country,
ec1.2020_GINI,
ec1.2019_GINI,
ec1.2020_mortaliy_under5,
ec1.2019_mortaliy_under5,
ec1.2020_GDP,
ec1.2019_GDP,
round(ec1.2020_GDP/2020_population, 2) AS '2020_GDP per capita',
round(ec1.2019_GDP/2019_population, 2) AS '2019_GDP per capita',
c.population_density,
c.median_age_2018
FROM ec1
JOIN c ON ec1.country=c.country
WHERE ec1.year=2020 
-- OR ec1.year=2019;