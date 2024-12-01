# Analyzing Netflix Movies and TV Shows Data with SQL

![Netflix logo](https://github.com/Abdi-analyst/Netflix_SQL_Analysis/blob/main/Netflix_logo.png)


## Overview
The project involves a detailed examination of Netflix's content to extract valuable insights and address various business questions. By leveraging SQL queries, we aim to analyze the distribution of content types (movies vs. TV shows), identify common ratings, explore content based on release years, countries, and durations, and categorize content using specific criteria and keywords.

## Objectives
- Analyze distribution between movies and TV shows on Netflix.
- Identify prevalent ratings for movies and TV shows.
- Examine content based on release years, countries, and durations.
- Explore and categorize content using specific criteria and keywords.

## Dataset

The dataset used in this project is sourced from Kaggle:

- **Dataset Link:** [Movies and TV Shows Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql

CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(7),
    title        VARCHAR(104),
    director     VARCHAR(208),
    casts        VARCHAR(771),
    country      VARCHAR(123),
    date_added   DATE,
    release_year INT,
    rating       VARCHAR(8),
    duration     VARCHAR(10),
    listed_in    VARCHAR(79),
    description  VARCHAR(250)
);
```

## Business Problems and Solutions

### 1. Retrieve the total count of movies and TV shows in the dataset.

```sql
SELECT 
   types,
   COUNT(*) AS Total_type
FROM 
	netflix 
GROUP BY 
	types;
```

**Goal:** Analyze the distribution of content types on Netflix.

### 2. Find the most common rating given to movies and TV shows.

```sql
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
```

**Goal:** Find the most common rating for each type of content.
	
### 3. List all movies released in the year 2021.

```sql
SELECT 
	*
FROM 
	netflix 
WHERE 
	types  = 'Movie' 
   AND 
   release_year = 2021
```

**Goal:** Compile a list of all movies that were released in the year 2021.

### 4. Identify the top 5 countries with the highest number of content available on Netflix.

```sql
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
```

**Goal**: Determine the top 5 countries with the most extensive content libraries available on Netflix.

### 5. Determine the movie with the longest duration in the dataset.

```sql
SELECT 
	types,
	MAX(duration) AS Longest_movie
FROM 
	netflix 
WHERE 
	types = 'Movie'
```

**Goal:** Find the movie with the longest duration in the dataset.

### 6. Retrieve all content added to Netflix in the last 3 years.

```sql
SELECT 
	*
FROM 
	netflix
WHERE 
	date_added >= DATE('now', '-3 years');
```

**Goal:** List content added to Netflix in the past 3 years.

### 7. List all movies and TV shows directed by a specific director, such as Martin Scorsese.

```sql
SELECT 
	*
FROM 
	netflix  
WHERE 
	director LIKE '%Martin Scorsese%' COLLATE NOCASE
```

**Goal:** Compile a list of movies and TV shows directed by a specific director like Martin Scorsese.

### 8. Find all TV shows with more than 4 seasons.

```sql
SELECT 
	* 
FROM
	netflix 
WHERE 
	types = 'TV Show'
	AND 
	duration > '4 Seasons'
```

**Goal:** Identify all TV shows with over 4 seasons.

### 9. Count the number of content items in each genre category.

```sql
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
```

**Goal:** Determine the count of content items in each genre category.

### 10. Calculate the average number of content releases per year in the dataset.

```sql
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
```

**Goal:** Determine the average annual content release count within the dataset.

### 11. List all movies that are classified as documentaries.

```sql
SELECT 
	*
FROM 
	netflix 
WHERE 
	types = 'Movie'
	AND 
	listed_in LIKE '%Documentaries%' COLLATE NOCASE
```

**Goal:** Compile a list of movies classified as documentaries.

### 12. Identify all content without a specified director.

```sql
SELECT 
	*
FROM 
	netflix
WHERE 
	director IS NULL OR director = '';
```

**Goal:** Identify content without a specified director.

### 13. Find the total number of movies actor 'Leonadro DiCprio' has appeared in.

```sql
SELECT 
	*
FROM 	
	netflix 
WHERE 
	types = 'Movie'
	AND 
	casts LIKE '%Leonardo DiCaprio%' COLLATE NOCASE
```

**Goal:** Determine the total number of movies in which actor 'Leonardo DiCaprio' has appeared.

### 14. Determine the top 5 actors who have appeared in the most movies in the dataset.

```sql
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
```	

**Goal:** Identify the top 5 actors with the most appearances in movies within the dataset.

### 15. Categorize the content based on the presence of the keywords 'detective' and 'investigation' in the description field. 

```sql
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
```
**Goal:** Categorize content as 'Investigate Film' if it contains 'detective' or 'investigation' and 'General' otherwise. Count the number of items in each category.

## Summary

- The dataset encompasses a broad range of movies and TV shows with varied ratings and genres.
- Insights into common ratings offer a glimpse into the target audience for the content.
- Examination of top countries and average content releases per year.
- Categorizing content based on specific keywords aids in understanding the content landscape on Netflix.
- This analysis offers a holistic view of Netflix's content, supporting content strategy and decision-making.
