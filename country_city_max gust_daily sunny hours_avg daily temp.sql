# ZISTUJEM COUNTRY, CITY, MAX_GUST, DAILY_SUNNY_HOURS, AVG_DAILY_TEMP
WITH 
w1 AS (
	SELECT 
		date,
		wind,
		city,
# vytahujem prve 2 znaky z gust a precastuje na int
		CAST (SUBSTRING(gust,1,2) AS INT) AS WIND_INT
	FROM weather 
),
# konsolidujem si tabulku pre MAX_GUST
w1_fin AS (
	SELECT 
		city,
		date,
		wind,
# zistujem MAX_GUST za den a mesto
		MAX (WIND_INT) AS MAX_GUST
	FROM w1
	GROUP BY date, city
	HAVING city IS NOT NULL
),
w2 AS (
	SELECT 
		city, 
		time, 
		date,
		rain,
# ak zrazky nulove, priradzujem 3, tj. 3 'slnecne' hodiny
	CASE WHEN rain='0.0 mm' THEN 3 ELSE 0 END AS 'DAILY_HOURS' 
	FROM weather
	WHERE CITY IS NOT NULL
),
# konsolidujem si tabulku pre DAILY_SUNNY_HOURS
w2_fin AS (
	SELECT 
		w2.city,
		w2.date,
		# spocitavam  'slnecne' hodiny na urovni mesta a datumu
		SUM (w2.DAILY_HOURS) AS DAILY_SUNNY_HOURS 
	FROM w2
	GROUP BY w2.city, w2.date
	ORDER BY w2.date
),
w3 AS (
	SELECT 
		city,
		time,
		# castujem time na 'time'
		CAST (time AS TIME) AS 'time1',
		date,
		temp
	FROM weather
),
w3_int AS (
	SELECT
		w3.city,
		w3.date,
		w3.time,
		w3.time1,
		w3.temp,
		AVG (w3.TEMP) OVER (PARTITION BY city, date) AS AVG_DAILY_TEMP
	FROM w3
	# definujem iba pre rozsah kde je mesto nenulove (inak nema zmysel?) a definujem casovy rozsah pre den
	WHERE CITY IS NOT NULL AND w3.time1>'06:00:00' AND w3.time1<'21:00:00'
	ORDER BY date
),
# konsolidujem si tabulku pre AVG_DAILY_TEMP 
w3_fin AS (
	SELECT 
		w3_int.city,
		w3_int.date,
		w3_int.AVG_DAILY_TEMP
	FROM w3_int
	GROUP BY date,city
),
# vyberam si krajinu a hlavne mesto
c_capital AS (
	SELECT 
		capital_city,
		country
	FROM countries c 
)
# finalna tabulka a joiny
SELECT 
		c_capital.country,
		w1_fin.city,
		w1_fin.date,
		w1_fin.MAX_GUST,
		w2_fin.DAILY_SUNNY_HOURS,
		w3_fin.AVG_DAILY_TEMP
FROM w1_fin 
	JOIN w2_fin 
		ON w1_fin.city = w2_fin.city
		AND w1_fin.date = w2_fin.date
	JOIN w3_fin
		ON w1_fin.city = w3_fin.city
		AND w1_fin.date = w3_fin.date
	JOIN c_capital 
		ON c_capital.capital_city = w1_fin.city
;



