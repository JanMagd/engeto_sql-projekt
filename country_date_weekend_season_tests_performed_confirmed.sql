# ZISTUJEM PARAMETRE - country, date, weekend, season, tests_performed, confirmed
# 1. z lookup_table priradim ISO pre krajiny z covid19_basic_differences 
# 2. prepojim tests_performed a covid19_basic_differences cez ISO 
WITH lt AS (
	SELECT 
		country,
		iso3
	FROM lookup_table lt 
),
# pripravujem si tabulku covid19_basic_differences a spajam s lookup_table podla ISO 
cbd1 AS (
	SELECT 
		cbd.country, 
		CAST (cbd.date AS date) AS date_cbd, 
		cbd.confirmed,
		lt.iso3
	FROM covid19_basic_differences cbd 
	LEFT JOIN lt ON cbd.country=lt.country
),
# pripravujem si tabulku z ovid19_tests
test AS (
	SELECT 
		country, 
		CAST (date AS date) AS date_test, 
		ISO, 
		tests_performed
	FROM covid19_tests
)
# konsolidujem finalnu tabulku
SELECT 
	cbd1.country,
	cbd1.date_cbd AS date,
# podmienky pre overenie vikend/rocne obdobie	
	CASE WHEN weekday(cbd1.date_cbd) in (5,6) THEN 1 ELSE 0 END AS weekend,
	CASE WHEN cbd1.date_cbd>'2020-01-01' AND cbd1.date_cbd<'2020-03-20'THEN 0 
			WHEN cbd1.date_cbd>'2020-03-19' AND cbd1.date_cbd<'2020-06-20' THEN 1 
			WHEN cbd1.date_cbd>'2020-06-19' AND cbd1.date_cbd<'2020-09-22' THEN 2
			WHEN cbd1.date_cbd>'2020-09-21' AND cbd1.date_cbd<'2020-12-21' THEN 3	
			WHEN cbd1.date_cbd>'2020-12-20' AND cbd1.date_cbd<'2021-03-20' THEN 0
			WHEN cbd1.date_cbd>'2021-03-19' AND cbd1.date_cbd<'2021-05-24' THEN 2
		ELSE NULL
		END AS 'season',
	test.tests_performed,
	cbd1.confirmed,
	cbd1.iso3
-- 	test.ISO
-- 	test.country,
-- 	test.date_test
FROM cbd1 
LEFT JOIN test ON cbd1.iso3=test.ISO AND cbd1.date_cbd=test.date_test
# funguje iba ak specifikujem krajinu, napr. Afghanistan. Je niekde logicka chyba prosim?
WHERE cbd1.country = 'Afghanistan'
;



# kontrolujem, ci prva cast zhora pracuje ako ma - vyzera to Ok
WITH lt AS (
	SELECT 
		country,
		iso3
	FROM lookup_table lt 
),
cbd1 AS (
	SELECT 
		CAST (cbd.date AS date) AS date_cbd,
		cbd.country, 
		cbd.confirmed,
		lt.iso3
	FROM covid19_basic_differences cbd 
	LEFT JOIN lt ON cbd.country=lt.country	
)
SELECT
	cbd1.country,
	cbd1.date_cbd AS date,
	cbd1.confirmed,
	cbd1.iso3
FROM cbd1
ORDER BY country;	

-- ////////////////////////////////////////////// 
SELECT 
*
from covid19_basic_differences cbd ;


SELECT 
*
FROM covid19_tests ct 


SELECT 
*
FROM lookup_table lt 

