USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/


-- Segment 1:



-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT 
	T.TAB_NAM,
	T.ROW_CNT,
    C.COL_CNT 
FROM (
SELECT TABLE_NAME AS TAB_NAM, TABLE_ROWS AS ROW_CNT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'IMDB'
)AS T

INNER JOIN(
SELECT TABLE_NAME AS TBL_NME, COUNT(COLUMN_NAME) AS COL_CNT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'IMDB'
GROUP BY TABLE_NAME
) AS C

ON T.TAB_NAM = C.TBL_NME;


-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT 
	SUM(id IS NULL) AS ID_NULL,
    SUM(title IS NULL) AS TITLE_NULL,
    SUM(year IS NULL) AS YEAR_NULL,
    SUM(date_published IS NULL) AS DATE_PUB_NULL,
    SUM(duration IS NULL) AS DURATION_NULL,
    SUM(country IS NULL) AS COUNTRY_NULL,
    SUM(worlwide_gross_income IS NULL) AS WG_INCOME_NULL,
    SUM(languages IS NULL) AS LANG_NULL,
    SUM(production_company IS NULL) AS PROD_COMP_NULL
FROM 
	movie; 


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


SELECT 
	YEAR AS Year, 
	COUNT(id) AS number_of_movies
FROM 
	movie
GROUP BY 
	YEAR
ORDER BY 
	YEAR;

SELECT 
	MONTH(date_published) as month_num, 
    COUNT(id) AS number_of_movies
FROM 
	movie
GROUP BY 
	MONTH(date_published)
ORDER BY 
	number_of_movies desc;





/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for 201.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
	year, 
    country,COUNT(id) as number_of_movies
FROM 
	movie
WHERE 
	country IN ('USA','INDIA') AND year = 2019
GROUP BY 
	country; 

/*
SELECT country, COUNT(id) as number_of_movies
FROM movie
WHERE (country LIKE '%india%' OR country LIKE '%USA%') AND year = 2019
GROUP BY country; 
*/


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT 
	DISTINCT(genre)
FROM 
	genre;



/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:


SELECT 
	year, 
    genre, COUNT(movie_id) AS number_of_movies,
	DENSE_RANK() OVER(ORDER by COUNT(movie_id) DESC) AS highest_movie_rank
FROM 
	genre AS gn
	INNER JOIN movie AS mv
	ON gn.movie_id = mv.id
WHERE 
	year = 2019
GROUP BY 
	genre
ORDER BY 
	COUNT(movie_id) DESC; 

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:


SELECT COUNT(count_of_movies) AS total_movies
FROM (
SELECT movie_id, COUNT(movie_id) AS count_of_movies
FROM genre AS gn
GROUP BY movie_id
HAVING count_of_movies= 1
) AS total_movies;



/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)



/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH GenreAverage AS (
    SELECT
        gn.genre,
        ROUND(AVG(mv.duration), 2) AS avg_duration
    FROM
        movie AS mv
    INNER JOIN
        genre AS gn
    ON
        gn.movie_id = mv.id
    GROUP BY
        gn.genre
)
SELECT *
FROM
    GenreAverage
ORDER BY
    avg_duration DESC;



/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
WITH thriller_rank AS
(
SELECT 
	genre, 
    COUNT(movie_id) AS movie_count,
	RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
FROM genre
GROUP BY genre
)

SELECT *
FROM 
	thriller_rank
WHERE 
	genre = 'Thriller';


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT MIN(avg_rating) AS min_avg_rating, 
	   MAX(avg_rating) AS max_avg_rating,
	   MIN(total_votes) AS min_total_votes,
       MAX(total_votes) AS max_total_votes,
       MIN(median_rating) AS min_median_rating,
       MAX(median_rating) AS max_median_rating
FROM ratings;

    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH top_ten_movies AS
(
SELECT 
	title, 
    avg_rating,
	DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM 
	movie AS mv
INNER JOIN 
	ratings AS rtg
ON 
	mv.id = rtg.movie_id
)

SELECT *
FROM 
	top_ten_movies
LIMIT 10; 


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

WITH median_ratings AS
(
SELECT median_rating, COUNT(id) AS movie_count
FROM movie AS mv
INNER JOIN ratings as rt
ON rt.movie_id = mv.id
GROUP BY median_rating
)

SELECT *
FROM median_ratings 
ORDER BY median_rating;


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:


WITH hit_movies AS
(
SELECT production_company, COUNT(mv.id) AS movie_count
FROM movie AS mv
INNER JOIN ratings AS rt
ON rt.movie_id = mv.id
WHERE avg_rating>8 AND production_company IS NOT NULL
GROUP BY production_company
)
SELECT *,
	   DENSE_RANK() OVER (ORDER BY movie_count DESC) AS prod_company_rank
FROM hit_movies;


-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both   ----WRONG

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


SELECT 
	gn.genre, COUNT(mv.id) as movie_count
FROM movie AS mv
INNER JOIN genre AS gn
ON mv.id = gn.movie_id
WHERE mv.id IN (
	SELECT movie_id
    FROM ratings
    WHERE total_votes>1000
    )
    AND MONTH(date_published) = 3
    AND year = 2017
    AND country = "USA"
-- WHERE country = 'USA' AND month(date_published) = 3
GROUP by gn.genre;


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


WITH title_rating AS 
(
SELECT id, title,avg_rating
FROM movie AS mv
INNER JOIN ratings AS rt
ON rt.movie_id = mv.id
WHERE title LIKE 'The%' AND avg_rating>8
)
SELECT title,avg_rating,genre
FROM title_rating AS tr
INNER JOIN genre AS gn
ON tr.id = gn.movie_id
ORDER BY avg_rating DESC;

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:


SELECT 
	median_rating, 
    COUNT(id) AS  number_of_movies
FROM movie AS mv
	INNER JOIN ratings AS rt
	ON mv.id = rt.movie_id
WHERE (rt.median_rating=8 AND mv.date_published BETWEEN '2018-04-01' AND '2019-04-01')
GROUP BY median_rating;

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT languages, 
    SUM(total_votes) AS total_votes
FROM 
	movie AS mv
	INNER JOIN ratings rt
    ON mv.id = rt.movie_id
WHERE (mv.languages LIKE "%German%" OR mv.languages LIKE "%Italian%")
GROUP BY languages
ORDER BY total_votes DESC;

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

      
SELECT 
		SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls, 
		SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
		SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
		SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM 
	names;



/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:





WITH top_genre AS
(
	SELECT g.genre, COUNT(g.movie_id) AS movie_count
	FROM genre AS g
	INNER JOIN ratings AS r
	ON g.movie_id = r.movie_id
	WHERE avg_rating > 8
    GROUP BY genre
    ORDER BY movie_count DESC
    LIMIT 3
),

top_director AS
(
SELECT n.name AS director_name,
		COUNT(g.movie_id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY COUNT(g.movie_id) DESC) AS director_row_rank
FROM names AS n 
INNER JOIN director_mapping AS dm 
ON n.id = dm.name_id 
INNER JOIN genre AS g 
ON dm.movie_id = g.movie_id 
INNER JOIN ratings AS r 
ON r.movie_id = g.movie_id,
top_genre
WHERE g.genre in (top_genre.genre) AND avg_rating>8
GROUP BY director_name
ORDER BY movie_count DESC
)

SELECT *
FROM top_director
WHERE director_row_rank <= 3
LIMIT 3;

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
	name AS actor_name,
    COUNT(rm.movie_id) AS movie_count
FROM 
	names AS nm
INNER JOIN 
	role_mapping AS rm
ON 
	rm.name_id = nm.id
INNER JOIN 
	ratings AS rt
ON 
	rt.movie_id = rm.movie_id
WHERE 
	rt.median_rating>=8 AND rm.category = 'actor'
GROUP BY
	nm.name
ORDER BY  
	movie_count DESC
LIMIT 2;




/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
	production_company,
    SUM(total_votes) AS vote_count,
    DENSE_RANK () OVER ( ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
    
FROM 
	movie as mv
INNER JOIN 
	ratings as rt
ON
	rt.movie_id = mv.id
GROUP BY 
	production_company
LIMIT 3;



/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

    
SELECT nm.name AS actor_name,
       SUM(r.total_votes) AS total_votes,
       COUNT(m.id) AS movie_count,
       ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) AS actor_avg_rating,
       RANK() OVER (ORDER BY SUM(r.avg_rating) DESC) AS actor_rank
FROM movie AS m
INNER JOIN (
    SELECT movie_id, avg_rating, total_votes
    FROM ratings
) AS r ON m.id = r.movie_id
INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
INNER JOIN names AS nm ON rm.name_id = nm.id
WHERE rm.category = 'actor' AND m.country = 'india'
GROUP BY nm.name
HAVING COUNT(m.id) >= 5
ORDER BY actor_avg_rating DESC
LIMIT 1;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT nm.name AS actor_name,
       SUM(r.total_votes) AS total_votes,
       COUNT(m.id) AS movie_count,
       ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) AS actor_avg_rating,
       RANK() OVER (ORDER BY SUM(r.avg_rating) DESC) AS actor_rank
FROM movie AS m
INNER JOIN (
    SELECT movie_id, avg_rating, total_votes
    FROM ratings
) AS r ON m.id = r.movie_id
INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
INNER JOIN names AS nm ON rm.name_id = nm.id
WHERE rm.category = 'actress' AND m.country = 'india'
GROUP BY nm.name
HAVING COUNT(m.id) >= 5
ORDER BY actor_avg_rating DESC
LIMIT 5;


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

WITH Title_Avg_Rating AS 
(
SELECT 
	mv.title AS title,
    rt.avg_rating	
FROM 
	genre AS gn
INNER JOIN ratings as rt
ON gn.movie_id = rt.movie_id
INNER JOIN movie as mv
ON rt.movie_id = mv.id
WHERE
	gn.genre = 'Thriller'
ORDER BY 
	avg_rating DESC
)

SELECT *,
CASE
	WHEN avg_rating > 8 THEN 'Superhit Movies'
    WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit Movies'
    WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch Movies'
    WHEN avg_rating < 5 THEN 'Flop Movies'
END AS rating
FROM Title_Avg_Rating;



/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:



SELECT
    genre,
    ROUND(AVG(duration),2) AS avg_duration,
    SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
    AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM genre AS gn
INNER JOIN movie AS mv
ON mv.id = gn.movie_id
GROUP BY
    genre
ORDER BY
    genre;


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH Top_Three_Genre AS
(
    SELECT 
        gn.genre,
        COUNT(gn.movie_id) AS movie_count
    FROM genre AS gn
    INNER JOIN movie AS mv
    ON gn.movie_id = mv.id
    GROUP BY 
        gn.genre
    ORDER BY
        COUNT(gn.movie_id) DESC
    LIMIT 3
)
,
ranked_movie AS
(
SELECT
    gn.genre,
    mv.Year,
    mv.title AS movie_name,
    mv.worlwide_gross_income AS worldwide_gross_income,
    DENSE_RANK() OVER(PARTITION BY mv.Year ORDER BY mv.worlwide_gross_income DESC) AS movie_rank
FROM
    movie AS mv
INNER JOIN genre AS gn
ON gn.movie_id = mv.id
WHERE
    gn.genre IN (SELECT genre FROM Top_Three_Genre)
ORDER BY
    mv.worlwide_gross_income DESC
)

select *
FROM ranked_movie
WHERE
	movie_rank <=5;





-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


SELECT production_company,
		COUNT(m.id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM movie AS m 
INNER JOIN ratings AS r 
ON m.id=r.movie_id
WHERE median_rating>=8 AND production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY production_company
LIMIT 2;



-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_actress AS
(
SELECT 
	name AS actress_name,
    rt.total_votes,
    COUNT(mv.id) AS movie_count,
	rt.avg_rating AS actress_avg_rating,
    DENSE_RANK() OVER(ORDER BY rt.avg_rating DESC) AS actress_rank
FROM movie AS mv
INNER JOIN role_mapping AS rm
ON rm.movie_id = mv.id
INNER JOIN genre AS gn 
ON gn.movie_id = rm.movie_id
INNER JOIN names as nm
ON nm.id = rm.name_id
INNER JOIN ratings AS rt
ON rt.movie_id = rm.movie_id
WHERE category = 'actress' AND gn.genre = 'Drama' AND rt.avg_rating>8
GROUP BY nm.name,rt.avg_rating,rt.total_votes
)
SELECT *
FROM top_actress
WHERE actress_rank<=3;



/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:


WITH MovieDates AS (
    SELECT
        director_mapping.name_id,
        names.name,
        director_mapping.movie_id,
        movie.date_published,
        LEAD(movie.date_published, 1) OVER(PARTITION BY director_mapping.name_id ORDER BY movie.date_published, director_mapping.movie_id) AS next_movie_date,
        DATEDIFF(LEAD(movie.date_published, 1) OVER(PARTITION BY director_mapping.name_id ORDER BY movie.date_published, director_mapping.movie_id), movie.date_published) AS diff
    FROM
        director_mapping
    INNER JOIN
        names ON director_mapping.name_id = names.id
    INNER JOIN
        movie ON director_mapping.movie_id = movie.id
),

AverageInterDays AS (
    SELECT
        name_id,
        AVG(diff) AS avg_inter_movie_days
    FROM
        MovieDates
    GROUP BY
        name_id
),

DirectorStats AS (
    SELECT
        director_mapping.name_id AS director_id,
        names.name AS director_name,
        COUNT(director_mapping.movie_id) AS number_of_movies,
        ROUND(AVG(ratings.avg_rating), 2) AS avg_rating,
        SUM(ratings.total_votes) AS total_votes,
        MIN(ratings.avg_rating) AS min_rating,
        MAX(ratings.avg_rating) AS max_rating,
        SUM(movie.duration) AS total_duration,
        ROW_NUMBER() OVER(ORDER BY COUNT(director_mapping.movie_id) DESC) AS director_row_rank
    FROM
        names
    INNER JOIN
        director_mapping ON names.id = director_mapping.name_id
    INNER JOIN
        ratings ON director_mapping.movie_id = ratings.movie_id
    INNER JOIN
        movie ON movie.id = ratings.movie_id
    INNER JOIN
        AverageInterDays ON AverageInterDays.name_id = director_mapping.name_id
    GROUP BY
        director_mapping.name_id, names.name
)
SELECT *
FROM DirectorStats
LIMIT 9;







