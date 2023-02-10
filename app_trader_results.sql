SELECT *
FROM app_store_apps;

SELECT *
FROM play_store_apps;

--Price Per Download In Both App Stores--
SELECT name,
	price::money
FROM app_store_apps
UNION 
SELECT name,
	price::money
FROM play_store_apps
ORDER BY price DESC;

--Purchase Price--
WITH purchase_price AS (SELECT name,
					   app_store_apps.price::money AS app_store_price,
					   play_store_apps.price::money AS play_store_price
					   FROM app_store_apps
					   	INNER JOIN play_store_apps
					   	USING(name)
					   GROUP BY name, app_store_apps.price,play_store_apps.price)
					 
SELECT*,
	CASE WHEN (10000*app_store_price) <= 25000::money THEN 25000::money
	WHEN (10000*app_store_price) > 25000::money THEN (10000*app_store_price)::money
	END AS purchase_price
FROM purchase_price
ORDER BY purchase_price DESC;

--Longevity--
SELECT app_store_apps.name AS app_name,
		play_store_apps.name AS play_name,
		ROUND(((app_store_apps.rating+play_store_apps.rating)/2),2) AS 										avg_rating,
		ROUND((((app_store_apps.rating+play_store_apps.rating)/2)/.25)*6)+12 AS 									longevity_months
FROM app_store_apps
	INNER JOIN play_store_apps
	USING(name)
GROUP BY app_store_apps.name,
		play_store_apps.name,app_store_apps.rating,
		play_store_apps.rating
--Revenue--
WITH longevity AS(SELECT app_store_apps.name AS app_name,
						play_store_apps.name AS play_name,
						ROUND(((app_store_apps.rating+play_store_apps.rating)/2),2) AS 										avg_rating,
						ROUND((((app_store_apps.rating+play_store_apps.rating)/2)/.25)*6)+12 AS 									longevity_months
				FROM app_store_apps
					INNER JOIN play_store_apps
					USING(name)
				GROUP BY app_store_apps.name,
						play_store_apps.name,app_store_apps.rating,
						play_store_apps.rating)
SELECT *,
	(2500*longevity_months)::money AS revenue
FROM longevity
ORDER BY revenue DESC;

--EXPENSES--
WITH longevity AS(SELECT app_store_apps.name AS app_name,
						play_store_apps.name AS play_name,
						ROUND(((app_store_apps.rating+play_store_apps.rating)/2),2) AS 										avg_rating,
						ROUND((((app_store_apps.rating+play_store_apps.rating)/2)/.25)*6)+12 AS 									longevity_months
				FROM app_store_apps
					INNER JOIN play_store_apps
					USING(name)
				GROUP BY app_store_apps.name,
						play_store_apps.name,app_store_apps.rating,
						play_store_apps.rating)
SELECT *,
	(1000*longevity_months)::money AS expense
FROM longevity
ORDER BY expense DESC;

--Net Profit--
WITH purchase_price AS (SELECT app_store_apps.name AS app_name,
							play_store_apps.name AS play_name,																ROUND(((app_store_apps.rating+play_store_apps.rating)/2),2) 										AS avg_rating,
							ROUND((((app_store_apps.rating+play_store_apps.rating)/2)/.25)*6)+12 										AS longevity_months,
							CASE WHEN ((10000*app_store_apps.price) <= 25000) THEN 25000
								WHEN ((10000*app_store_apps.price) > 25000) THEN 			(10000*app_store_apps.price)
								END AS purchase_price
						FROM app_store_apps
							INNER JOIN play_store_apps
							USING(name)
						GROUP BY app_store_apps.name,
						play_store_apps.name,app_store_apps.rating,
						play_store_apps.rating,app_store_apps.price )
						
SELECT *,
	(((2500*longevity_months)-(1000*longevity_months))-purchase_price)::money AS net_profit
FROM purchase_price
ORDER BY net_profit DESC;
	

--Break Even--
WITH purchase_price AS (SELECT name,
					   app_store_apps.price::money AS app_store_price,
					   play_store_apps.price::money AS play_store_price
					   FROM app_store_apps
					   	INNER JOIN play_store_apps
					   	USING(name)
					   GROUP BY name, app_store_apps.price,play_store_apps.price)
SELECT *,
	CASE WHEN (10000*app_store_price) <= 25000 THEN 25000::money
	WHEN (10000*app_store_price) > 25000 THEN (10000*app_store_price)::money
	END AS purchase_price
FROM purchase_price
SELECT *,
	purchase_price/4000 AS break_even_month
FROM purchase_price;
