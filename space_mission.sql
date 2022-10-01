
-- create a column to hold each country from the location
ALTER TABLE space_missions
ADD COLUMN country TEXT


UPDATE space_missions
SET country = REVERSE(LEFT(REVERSE("Location"),POSITION(',' IN REVERSE("Location" ))-1));


-- removing the price delimeter ',' and replacing it with ''

UPDATE space_missions
SET price =  REPLACE(price  , ',', '');

-- number of missions 
SELECT COUNT(*)
FROM space_missions;


-- total number of rocket
SELECT COUNT(DISTINCT rocket) AS total_rocket
FROM space_missions ;

-- rocket status in percent
SELECT *
FROM space_missions ;


-- count of rocket status by percent 
SELECT rocketstatus, (count(rocketstatus)/(SELECT count(rocketstatus) FROM space_missions)::NUMERIC)*100 as rocketStatuspct
FROM space_missions
WHERE rocketstatus ='Retired'
group by 1
        
 UNION ALL 
SELECT rocketstatus, (count(rocketstatus)/(SELECT count(rocketstatus) FROM space_missions)::NUMERIC)*100 as rocketStatuspct
FROM space_missions
WHERE rocketstatus ='Active'
group by 1
        
SELECT DISTINCT missionstatus
FROM space_missions sm 
       
-- missionstatus rate in percent 
SELECT missionstatus,(count(missionstatus)/(SELECT count(missionstatus) FROM space_missions sm)::NUMERIC) *100 AS missionStatusinpct
FROM space_missions sm 
WHERE missionstatus ='Success'
GROUP BY 1
UNION ALL
SELECT missionstatus,  (count(missionstatus)/(SELECT count(missionstatus) FROM space_missions sm)::NUMERIC) *100 AS missionStatusinpct
FROM space_missions sm 
WHERE missionstatus ='Failure'
GROUP BY 1
UNION ALL        
SELECT missionstatus , (count(missionstatus)/(SELECT count(missionstatus) FROM space_missions sm)::NUMERIC) *100 AS missionStatusinpct
FROM space_missions sm 
WHERE missionstatus ='Prelaunch Failure'
GROUP BY 1
UNION ALL        
SELECT missionstatus , (count(missionstatus)/(SELECT count(missionstatus) FROM space_missions sm)::NUMERIC) *100 AS missionStatusinpct
FROM space_missions sm 
WHERE missionstatus ='Partial Failure'
GROUP BY 1        


-- Space mission by year
SELECT date_part('year', "Date") AS YEAR, count(*) AS total_missionCount
FROM space_missions 
GROUP BY 1
ORDER BY 2 DESC;


-- country with the highest space mission
SELECT country , COUNT(*) AS mission_countPercountry
FROM space_missions 
WHERE LTRIM(country) IN('Israel', 'Brazil', 'France', 'Kazakhstan', 'France','South Korea',
'North Korea', 'Kenya', 'Russia','Iran', 'China', 'USA', ' Australia','Japan','India')
GROUP BY 1
ORDER BY 2 DESC;

-- space ship launched in water
SELECT country , COUNT(*) AS mission_countPercountry
FROM space_missions 
WHERE LTRIM(country) NOT  IN('Pacific Ocean', 'Yellow Sea', 'Barents Sea')
GROUP BY 1
ORDER BY 2 DESC;

-- percent of mission launched in SEa vs percent of mission launched on land
--SEA
SELECT  (COUNT(*)/(SELECT COUNT(*) FROM space_missions sm)::NUMERIC )*100 AS missionsInpct
FROM space_missions 
WHERE LTRIM(country)  IN('Pacific Ocean', 'Yellow Sea', 'Barents Sea')
UNION ALL
-- LAND
SELECT  (COUNT(*)/(SELECT COUNT(*) FROM space_missions sm)::NUMERIC )*100 AS missionsInpct
FROM space_missions 
WHERE LTRIM(country)  NOT IN('Pacific Ocean', 'Yellow Sea', 'Barents Sea');


-- First space  mission by country
SELECT date_trunc('month', "Date")::Date AS MONTH, mission, country
FROM space_missions 
ORDER BY 1
LIMIT 1;


-- countries mission status in percent using windows function
SELECT country, missionstatus,missionstatuscount,ROUND((missionstatuscount/sum(total_mission) OVER (PARTITION BY country))*100,2) AS missionStatspct
FROM (SELECT country , missionStatus, missionStatusCount, sum(missionStatusCount) AS total_mission
		FROM (SELECT LTRIM(country) AS country , missionstatus, count(missionstatus) AS missionStatusCount
				FROM space_missions 
				WHERE LTRIM(country)  IN('Israel', 'Brazil', 'France', 'Kazakhstan', 'France','South Korea',
				'North Korea', 'Kenya', 'Russia','Iran', 'China', 'USA', ' Australia','Japan','India')
				GROUP BY 1,2) t1
		GROUP BY 1,2,3) t2;
		
		
-- 
		
-- mission count
SELECT 	 mission, missionstatus ,date_trunc('month', "Date")::DATE AS month  ,
ROW_NUMBER()  OVER(PARTITION BY missionstatus ORDER BY date_trunc('month', "Date")) AS mission_count
FROM space_missions sm ;

-- repetitive mission by mission status
SELECT mission, missionstatus, sum(total_missioncount) OVER (PARTITION BY mission, missionstatus) AS missionstatus
FROM (SELECT 	 mission, missionstatus , count(mission) AS total_missioncount
	FROM space_missions sm 
	GROUP BY 1,2)t1;

-- average price of a  space rocket in a company
SELECT company , AVG(CAST(COALESCE (
						NULLIF(price, ''),'0') AS NUMERIC) )AS price 
FROM space_missions
GROUP BY 1

-- total price of all space rocket
SELECT SUM(CAST(COALESCE (
						NULLIF(price, ''),'0') AS NUMERIC) )AS price 
FROM space_missions



-- comapany count
SELECT count(DISTINCT company) AS company_count
FROM space_missions sm 



-- average time for lanuch in years
SELECT EXTRACT('YEAR' FROM "Date") AS YEAR, ROUND(AVG(EXTRACT('minute' FROM "Time")),2) AS timeInMinute
FROM space_missions sm 
GROUP BY 1

-- company by  mission 
SELECT company, count(*)
FROM space_missions sm2 
GROUP BY 1
ORDER BY 2 DESC ;

-- top 10 companies to spend the most amount on space mission
SELECT company, SUM(CAST(COALESCE (
				NULLIF(price, ''),'0') AS NUMERIC) )AS price 
FROM space_missions
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


-- top 10 company to launch spce mission
SELECT company , count(*)
FROM space_missions sm 
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 10
