WITH acq_calc AS (SELECT DISTINCT name, --creating a CTE to give us the acquisition cost, which I mislabeled as acq_price. Oh well.
				 		(CASE WHEN app_s.price::money::numeric * 10000 > 25000 THEN app_s.price::money::numeric * 10000
				 		 ELSE 25000 END)::money AS at_acq_price
				  FROM app_store_apps AS app_s
				  FULL JOIN play_store_apps AS play_s
						USING (name)
				  WHERE app_s.name IN (SELECT name -- where functions pulls names only that are in both app stores. not interested in any others.
					 				   FROM app_store_apps
				 					   INTERSECT
					 				   SELECT name
				  					   FROM play_store_apps))
SELECT DISTINCT app_s.name,
				acq_calc.at_acq_price,
				app_s.rating AS app_store_rating,
				play_s.rating AS play_store_rating,
				--app_s.primary_genre,
				--play_s.category,
				ROUND((app_s.rating + play_s.rating) / 2, 2) AS avg_rating, --an app's ratings vary from store to store so we decided to use the average
				FLOOR(((((app_s.rating + play_s.rating) / 2))/.25)::integer * 6 + 12) AS shelf_life_in_months, --its not perfect since I can't figure out how to round to the nearest .5 in SQL but it works for the most part
				CEILING((at_acq_price/1500.00::money)::decimal)::integer AS breakeven_point, --based on the acq cost, how long will it take to make money?
				FLOOR(((ROUND((app_s.rating + play_s.rating) / 2, 2)* 2) + 1) * 12)::money * 1500 AS expected_lt_gross, --based on the shelf life, how much will the app make lifetime?
				(FLOOR(((ROUND((app_s.rating + play_s.rating) / 2, 2)* 2) + 1) * 12)::money * 1500) - acq_calc.at_acq_price AS expected_lt_profit -- based on the lt_gross and the initial cost, what's the expected lifetime profit?
				--NTILE(10) OVER (ORDER BY (FLOOR(((ROUND((app_s.rating + play_s.rating) / 2, 2)* 2) + 1) * 12)::money * 50000) - acq_calc.at_acq_price DESC) AS profit_quartile			
FROM app_store_apps AS app_s
	FULL JOIN play_store_apps AS play_s
		ON app_s.name = play_s.name
	INNER JOIN acq_calc
		ON app_s.name = acq_calc.name
WHERE app_s.name IN
			(SELECT name
			 FROM app_store_apps
			 INTERSECT
			 SELECT name
			 FROM play_store_apps)
ORDER BY expected_lt_profit DESC;

SELECT DISTINCT app_s.name,
				app_s.price::money AS app_store_price,
				play_s.price::money AS play_store_price,
				((app_s.rating + play_s.rating)/2) AS avg_rating
FROM app_store_apps AS app_s
	INNER JOIN play_store_apps AS play_s
	USING(name)
WHERE app_s.name IN
			(SELECT name
			 FROM app_store_apps
			 INTERSECT
			 SELECT name
			 FROM play_store_apps)
ORDER BY avg_rating DESC;
	 
SELECT name, 
	   rating,
	   NTILE(4) OVER (ORDER BY app_store_apps.rating) AS quartile
FROM app_store_apps
ORDER BY quartile DESC;

SELECT ROUND(CORR(rating, size_bytes::decimal)::decimal,2) AS p_score
FROM app_store_apps;

SELECT REPLACE(size,'k','')
FROM play_store_apps
WHERE size ILIKE '%K';

SELECT name, price::money
FROM app_store_apps
INTERSECT
SELECT name, price::money
FROM play_store_apps;

WITH genre_dived AS (SELECT genres,
		   					COUNT(genres) AS num_of_apps,
	 				 		ROUND(AVG(rating),2) AS avg_rating
					 FROM play_store_apps
					 GROUP BY genres
					 HAVING ROUND(AVG(rating),2) IS NOT NULL
					 ORDER BY avg_rating DESC)
SELECT genre_dived.genres,
	   genre_dived.num_of_apps,
	   genre_dived.avg_rating,
	   NTILE(4) OVER (ORDER BY genre_dived.avg_rating) AS quartile
FROM genre_dived
WHERE num_of_apps > 10
ORDER BY quartile DESC, avg_rating DESC;

WITH presorted_apps AS (SELECT price::money,
					   		   (CASE WHEN price > 0 AND price <= 2 THEN 'low-cost'
					   				 WHEN price = 0 THEN 'free'
					   				 WHEN price > 2 AND price <= 5 THEN 'medium-cost'
					   			     ELSE 'high-cost' END) AS type
						FROM app_store_apps)
SELECT type, COUNT(type), AVG(rating)
FROM app_store_apps AS app_s
	INNER JOIN presorted_apps
		ON app_s.price::money = presorted_apps.price
GROUP BY type;

SELECT category, AVG(rating)
FROM play_store_apps
GROUP BY category;

SELECT content_rating, COUNT(content_rating),ROUND(AVG(rating),2)
FROM play_store_apps
GROUP BY content_rating;