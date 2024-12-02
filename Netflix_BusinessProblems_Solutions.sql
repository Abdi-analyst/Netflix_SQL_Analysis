-- 15 Business proplems and solution.
--1. Retrieve the total count of movies and TV shows in the dataset.

SELECT 
   types,
   COUNT(*) AS Total_type
FROM 
	netflix 
GROUP BY 
	types;

--2. Find the most common rating given to movies and TV shows.

WITH Ratings AS (
	SELECT 
		types,
		rating, 
		count(rating),
		RANK() OVER(PARTITION BY types ORDER BY COUNT(*) DESC) AS ranking
	FROM 
		netflix 
	GROUP BY 
		types, rating
	)	
	
SELECT 
	types,
	rating
FROM 
	Ratings
WHERE 
	ranking = 1
		
--3. List all movies released in the year 2021.

SELECT 
	*
FROM 
	netflix 
WHERE 
	types  = 'Movie' 
   AND 
   release_year = 2021

--4. Identify the top 5 countries with the highest number of content available on Netflix.
  
WITH country_data AS (
    SELECT
        TRIM(SUBSTR(country, 1, INSTR(country, ',') - 1)) AS country
    FROM
        netflix
    WHERE
        country LIKE '%,%' 
    
    UNION ALL
    
    SELECT
        TRIM(country) AS country
    FROM
        netflix
    WHERE
        country NOT LIKE '%,%'
        AND country IS NOT NULL
        AND country <> ''
)
SELECT
    country,
    COUNT(*) AS content_count
FROM
    country_data
GROUP BY
    country
ORDER BY
    content_count DESC
LIMIT 5;
   
--5. Determine the movie with the longest duration in the dataset.
   
SELECT 
	types,
	MAX(duration) AS Longest_movie
FROM 
	netflix 
WHERE 
	types = 'Movie'
   
--6. Retrieve all content added to Netflix in the last 3 years.

SELECT 
	*
FROM 
	netflix
WHERE 
	date_added >= DATE('now', '-3 years');

--7. List all movies and TV shows directed by a specific director, such as Martin Scorsese.

SELECT 
	*
FROM 
	netflix  
WHERE 
	director LIKE '%Martin Scorsese%' COLLATE NOCASE

--8. Find all TV shows with more than 4 seasons.
	
SELECT 
	* 
FROM
	netflix 
WHERE 
	types = 'TV Show'
	AND 
	duration > '4 Seasons'
	
--9. Count the number of content items in each genre category.
	
WITH each_genre AS (
	SELECT
		TRIM(SUBSTRING(listed_in, 1, INSTR(listed_in, ',') - 1)) AS genre
	FROM 
		netflix 
	WHERE 
		listed_in LIKE '%,%'
	
	UNION ALL
	
	SELECT 
		TRIM(listed_in) AS genre
	FROM
		netflix 
	WHERE 
		listed_in NOT LIKE '%,%'
	)

SELECT 
	genre,
	COUNT(*) AS count
FROM 
	each_genre
GROUP BY 
	genre
ORDER BY 
	count DESC
	
--10. Calculate the average number of content releases per year in the dataset.

WITH YearlyReleaseCounts AS (
	SELECT
   	release_year,
      COUNT(*) AS num_releases
   FROM 
   	netflix
   GROUP BY 
   	release_year
),
TotalYears AS (
    SELECT COUNT(DISTINCT release_year) AS total_years
    FROM netflix
)

SELECT 
	SUM(num_releases) / (SELECT total_years FROM TotalYears) AS avg_releases_per_year
FROM 
	YearlyReleaseCounts;
	
--11. List all movies that are classified as documentaries.

SELECT 
	*
FROM 
	netflix 
WHERE 
	types = 'Movie'
	AND 
	listed_in LIKE '%Documentaries%' COLLATE NOCASE

--12. Identify all content without a specified director.

SELECT 
	*
FROM 
	netflix
WHERE 
	director IS NULL OR director = '';
	
--13. Find the total number of movies actor 'Leonadro DiCprio' has appeared in.

SELECT 
	*
FROM 	
	netflix 
WHERE 
	types = 'Movie'
	AND 
	casts LIKE '%Leonardo DiCaprio%' COLLATE NOCASE

--14. Determine the top 5 actors who have appeared in the most movies in the dataset.

WITH SplitActors AS (
    SELECT 
        TRIM(SUBSTR(casts, 1, INSTR(casts, ',') - 1)) AS actor
    FROM 
        netflix
    WHERE 
        casts LIKE '%,%'
    
    UNION ALL 
    
    SELECT 
        TRIM(casts) AS actor
    FROM 
        netflix 
    WHERE 
        casts NOT LIKE '%,%'
        AND 
        casts IS NOT NULL 
        AND
        casts <> ''
)

SELECT 
    actor,
    COUNT(*) AS total_appearances
FROM 
    SplitActors
WHERE 
    actor IS NOT NULL AND actor <> ''
GROUP BY 
    actor
ORDER BY 
    total_appearances DESC
LIMIT 5;
	

/* Question 15:
Categorize the content based on the presence of the keywords 'detective' and 'investigation' in the description field 
Label content containing either of these keywords as 'Investigative Film' and all other content as 'General'
Determine the count of items falling into each category.*/

WITH MoviesData AS (
   SELECT 
        *,
        CASE 
            WHEN 
                description LIKE '%detective%' COLLATE NOCASE
                OR
                description LIKE '%investigation%' COLLATE NOCASE
                THEN 
                'Investigative Film'
            ELSE 
                'General'
        END AS movie_category
    FROM 
        netflix
    )    
SELECT
    movie_category,
    COUNT(*) AS total_movies_in_category
FROM 
    MoviesData
GROUP BY 
    movie_category
