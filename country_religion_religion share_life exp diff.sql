# COUNTRY, RELIGION, RELIGION SHARE, LIFE_EXP_DIFF
# z tabulky life_expectancy zistujem rozdiel medzi life exp 2015 a 1965
WITH lifeexp AS (
	SELECT 
		a.country, 
		a.life_exp_1965, 
		b.life_exp_2015,
		b.life_exp_2015 - a.life_exp_1965 AS life_exp_diff
	FROM (
    	SELECT 
    		le.country, 
    		le.life_expectancy as life_exp_1965
   		FROM life_expectancy le 
   		WHERE year = 1965
    ) a 
	JOIN (
   		SELECT 
    		le.country, 
    		le.life_expectancy as life_exp_2015
    	FROM life_expectancy le 
    	WHERE year = 2015
    ) b
	ON a.country = b.country
),
# z tabulky religions vypocitavam percentualne podiely prislusnikov jednotlivych nabozenstiev z celk. populacie 
rel AS (
	SELECT 
		r.country, 
		r.religion, 
		round(r.population / r2.total_population_2020 * 100, 2) as religion_share_2020
	FROM religions r 
	JOIN (
        SELECT 
        	r.country , 
        	r.year,  
        	sum(r.population) as total_population_2020
        FROM religions r 
        WHERE r.year = 2020 and r.country != 'All Countries'
        GROUP BY r.country
    ) r2
    ON r.country = r2.country
    AND r.year = r2.year
    AND r.population > 0
 ),
# z tabulky countries zistujem, ktore je prevladajuce nabozenstvo 
ctr AS (
 	SELECT 
 		country,
 		religion
 	FROM countries
 )
# konsolidujem finalnu tabulku
SELECT 
	ctr.country, 
	ctr.religion, 
	rel.religion_share_2020,
	lifeexp.life_exp_diff
FROM rel 
JOIN ctr 
	ON ctr.country=rel.country 
	AND ctr.religion=rel.religion
JOIN lifeexp 
	ON ctr.country=lifeexp.country
;