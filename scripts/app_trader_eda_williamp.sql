					--Establishing titles that exist in both tables with an above average rating--

--Focusing on apps present in both tables. 

SELECT DISTINCT name
  FROM app_store_apps
	   INNER JOIN play_store_apps 
	   USING(name)
 GROUP BY name;   --There are 328 apps present in both tables, joined on names. 

--Finding average rating of all apps that exist in both stores. Overall average rating between both stores is 4.21.

SELECT (SUM(app_store_apps.rating) / COUNT(*) + SUM(play_store_apps.rating) / COUNT(*)) / 2 AS overall_avg
  FROM app_store_apps
	   INNER JOIN play_store_apps
	   USING(name);  

--Finding apps with long life expectancies, where 0 rating is a 1 year lifespan and an additional 6 months for each .25 star. Long life expectancy is said to be anything with an above average rating, where rating correlates to life expectancy as stated above. 

SELECT DISTINCT name, 
	   ROUND((app_store_apps.rating + play_store_apps.rating) / 2, 2) AS avg_rating      --Averaged rating for each title.
  FROM app_store_apps 
	   INNER JOIN play_store_apps
       USING(name)
 WHERE (app_store_apps.rating + play_store_apps.rating) / 2 >   -- is the average for each title
	   (SELECT ((SUM(app_store_apps.rating) / COUNT(*)) + (SUM(play_store_apps.rating) / COUNT(*))) / 2 AS overall_avg
          FROM app_store_apps
	   		   INNER JOIN play_store_apps
	   	 	   USING(name))        -- is the combined average for the entire set. 	   
 ORDER BY avg_rating DESC;  --191 apps that exist in both stores with an above average rating.
 
--Finding distinct genres in the combined datasets, with an above average rating. 

SELECT COUNT(DISTINCT genres) AS play_store_genres,
	   COUNT(DISTINCT primary_genre) AS app_store_genres,
	   COUNT(DISTINCT category) AS play_store_category
  FROM app_store_apps 
	   INNER JOIN play_store_apps
       USING(name)
 WHERE (app_store_apps.rating + play_store_apps.rating) / 2 >  
	   (SELECT ((SUM(app_store_apps.rating) / COUNT(*)) + (SUM(play_store_apps.rating) / COUNT(*))) / 2 AS overall_avg
          FROM app_store_apps
	   		   INNER JOIN play_store_apps
	   	 	   USING(name)); -- There are 45 distinct genres in the play_store_apps.genres category, but only 16 in the 				app_store_apps.primary_genre category. Category, another descriptive column only contains 19 distinct generalizations. One can assume the genres in play_store_apps.genres are more specific, allowing more opportunity to cater the selection of apps.  


								--Finding the average rating by genre.-- 


WITH select_titles AS (SELECT *,
	   						  ROUND((app_store_apps.rating + play_store_apps.rating) / 2, 2) AS avg_rating     
  						 FROM app_store_apps 
	   			  		      INNER JOIN play_store_apps
       						  USING(name)
 						WHERE (app_store_apps.rating + play_store_apps.rating) / 2 >   
	  						  (SELECT ((SUM(app_store_apps.rating) / COUNT(*)) + (SUM(play_store_apps.rating) / COUNT(*))) / 2 AS 	                                	 overall_avg
          					     FROM app_store_apps
	   		   				  		  INNER JOIN play_store_apps
	   	 	   						  USING(name))        	   
 					 ORDER BY avg_rating DESC) --cte 'select_titles' contains all information about titles from both tables, with an above average rating of the combined scores. 
					 
SELECT genres,
	   ROUND(AVG(avg_rating), 2) AS genre_avg_rating
  FROM select_titles
 GROUP BY genres
 ORDER BY genre_avg_rating DESC;  -- Ranking of all genres by average rating, where rating correlates to the life expectance of the app.
 
 --Content Rating
  --play_store_apps
WITH select_titles AS (SELECT name,
					   	      play_store_apps.content_rating AS play_store_content,				
	   						  ROUND((app_store_apps.rating + play_store_apps.rating) / 2, 2) AS avg_rating     
  						 FROM app_store_apps 
	   			  		      INNER JOIN play_store_apps
       						  USING(name)
 						WHERE (app_store_apps.rating + play_store_apps.rating) / 2 >   
	  						  (SELECT ((SUM(app_store_apps.rating) / COUNT(*)) + (SUM(play_store_apps.rating) / COUNT(*))) / 2 AS                               		 overall_avg
          					     FROM app_store_apps
	   		   				  		  INNER JOIN play_store_apps
	   	 	   						  USING(name))        	   
 					 ORDER BY avg_rating DESC)
					 
SELECT COUNT(name) AS no_of_titles,
	   play_store_content,
	   ROUND(AVG(avg_rating), 2) AS avg_rating
  FROM select_titles
 GROUP BY play_store_content;


  --app_store_apps
WITH select_titles AS (SELECT name,
					   		  app_store_apps.content_rating AS app_store_content,					
	   						  ROUND((app_store_apps.rating + play_store_apps.rating) / 2, 2) AS avg_rating     
  						 FROM app_store_apps 
	   			  		      INNER JOIN play_store_apps
       						  USING(name)
 						WHERE (app_store_apps.rating + play_store_apps.rating) / 2 >   
	  						  (SELECT ((SUM(app_store_apps.rating) / COUNT(*)) + (SUM(play_store_apps.rating) / COUNT(*))) / 2 AS                                       		 overall_avg
          					     FROM app_store_apps
	   		   				  		  INNER JOIN play_store_apps
	   	 	   						  USING(name))        	   
 					 ORDER BY avg_rating DESC)
					 
SELECT COUNT(name) AS no_of_titles,
	   app_store_content,
	   ROUND(AVG(avg_rating), 2) AS avg_rating
  FROM select_titles
 GROUP BY app_store_content;
 
 
--Cost/Revenue/Profit

WITH select_titles_cost AS (SELECT name,
					    	       play_store_apps.price::money AS play_store_price,
					   		       app_store_apps.price::money AS app_store_price,
							       (CASE WHEN play_store_apps.price::money <= 2.50::money THEN 25000::money ELSE                                                                       play_store_apps.price::money * 10000 END) AS play_store_cost,--purchase cost
	   						  	   (CASE WHEN app_store_apps.price::money <= 2.50::money THEN 25000::money ELSE                                                                         app_store_apps.price::money * 10000 END) AS app_store_cost, --purchase cost
	  						   	   ROUND((12 + (((app_store_apps.rating + play_store_apps.rating) / 2/.25)*6)), 2) AS                                                             life_expectancy_months, --life expectancy
	   						       ROUND((app_store_apps.rating + play_store_apps.rating) / 2, 2) AS avg_rating     
  						 FROM app_store_apps 
	   			  		      INNER JOIN play_store_apps
       						  USING(name)
 						WHERE (app_store_apps.rating + play_store_apps.rating) / 2 >   
	  						  (SELECT ((SUM(app_store_apps.rating) / COUNT(*)) + (SUM(play_store_apps.rating) / COUNT(*))) / 2 AS 		                                       overall_avg
          					     FROM app_store_apps
	   		   				  		  INNER JOIN play_store_apps
	   	 	   						  USING(name))        	   
 					    ORDER BY avg_rating DESC)
					 
SELECT *,
	   (CASE WHEN play_store_cost > app_store_cost THEN play_store_cost ELSE app_store_cost END) +
	   (1000*life_expectancy_months)::money AS app_trader_cost,  --Greatest cost to purchase and market app
	   ((life_expectancy_months*5000)/2)::money AS at_lifetime_revenue --Revenue over the lifetime of app, where apptrader takes 1/2 of                                                                          an expected 5000/month from in-app purchases and advertisement.
  FROM select_titles_cost;
  
--Continuing to build on above query  

WITH cost_revenue AS (WITH select_titles_cost AS (SELECT name,
					    	                             play_store_apps.price::money AS play_store_price,
					   		                             app_store_apps.price::money AS app_store_price,
							                             (CASE WHEN play_store_apps.price::money <= 2.50::money THEN 25000::money ELSE                                                                                 			 play_store_apps.price::money * 10000 END) AS play_store_cost,--purchase cost
	   						  	 					     (CASE WHEN app_store_apps.price::money <= 2.50::money THEN 25000::money ELSE                                                                                             app_store_apps.price::money * 10000 END) AS app_store_cost, --purchase cost
	  						   	              			 ROUND((12 + (((app_store_apps.rating + play_store_apps.rating) / 2 / .25) * 6)), 2) AS                                                                            life_expectancy_months, --life expectancy
	   						                  			 ROUND((app_store_apps.rating + play_store_apps.rating) / 2, 2) AS avg_rating     
  												    FROM app_store_apps 
	   			  		     						     INNER JOIN play_store_apps
       						 							 USING(name)
 												   WHERE (app_store_apps.rating + play_store_apps.rating) / 2 >   
	  						  					         (SELECT ((SUM(app_store_apps.rating) / COUNT(*)) + (SUM(play_store_apps.rating) / COUNT(*))) / 2 AS 		                                                          overall_avg
          					     						    FROM app_store_apps
	   		   				  		 						     INNER JOIN play_store_apps
	   	 	   						  							 USING(name))        	   
 					    										 ORDER BY avg_rating DESC)
					 
						SELECT *,
	  						   (CASE WHEN play_store_cost > app_store_cost THEN play_store_cost ELSE app_store_cost END) +
	   						   			  (1000*life_expectancy_months)::money AS at_total_cost,  --Greatest cost to purchase and market app
	   						   ((life_expectancy_months*5000)/2)::money AS at_lifetime_revenue --Revenue over the lifetime of app, where apptrader takes 1/2                                                                                           of an expected 5000/month from in-app purchases and advertisement.

					      FROM select_titles_cost)
  
SELECT DISTINCT name,
	   avg_rating,
	   life_expectancy_months,
	   (life_expectancy_months * 1000)::money AS advertising_cost,
	   at_total_cost,
	   at_lifetime_revenue,
	   at_lifetime_revenue - at_total_cost AS gross_profit,
	   ROUND(((at_lifetime_revenue - at_total_cost)/at_lifetime_revenue)::numeric*100,2) AS profit_margin,
	   ((CASE WHEN play_store_cost > app_store_cost THEN play_store_cost ELSE app_store_cost END) / (2500 - 1000))::numeric AS breakeven
  FROM cost_revenue
 ORDER BY gross_profit DESC;
 



