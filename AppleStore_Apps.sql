-- combining applestore_description(1-4)

SELECT * INTO AppleStore_description_combined FROM appleStore_description1 asd 
UNION ALL
SELECT * FROM appleStore_description2 asd2 
UNION ALL
SELECT * FROM appleStore_description3 asd3 
UNION ALL
SELECT * FROM appleStore_description4 asd4
 
--EXPLORATORY DATA ANALYSIS

--Check the number of unique apps in both tables


SELECT COUNT(DISTINCT id) as UniqueAppIDs
FROM AppleStore as2 

SELECT COUNT(DISTINCT id) as UniqueAppIDs
FROM AppleStore_description_combined asdc 

-- Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
From AppleStore as2 
WHERE track_name is null OR user_rating IS NULL OR prime_genre IS NULL 

SELECT COUNT(*) AS MissingValues
From AppleStore_description_combined asdc  
WHERE app_desc IS NULL 

-- Find the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore as2 
GROUP BY prime_genre 
ORDER BY NumApps DESC

-- Overview of apps' ratings

SELECT min(user_rating) as MinRating, max(user_rating) as MaxRating, avg(user_rating) as AvgRating
FROM AppleStore as2 

-- DATA ANALYSIS

-- Determine whether paid apps have higher ratings than free apps

SELECT CASE
WHEN price > 0 THEN 'Paid'
ELSE 'Free'
END as app_type, avg(user_rating) as avg_rating
FROM AppleStore as2 
GROUP BY (CASE
WHEN price > 0 THEN 'Paid'
ELSE 'Free'
END)

-- Check if apps with more supported languages have highter ratings

SELECT CASE
WHEN lang_num < 10 THEN '<10 languages'
WHEN lang_num > 10 AND lang_num < 30 THEN '10-30 languages'
ELSE '>30 languages'
END as language_bucket, avg(user_rating) as avg_rating
FROM AppleStore as2 
GROUP BY (
CASE
WHEN lang_num < 10 THEN '<10 languages'
WHEN lang_num > 10 AND lang_num < 30 THEN '10-30 languages'
ELSE '>30 languages'
END)
ORDER BY avg_rating DESC

-- Check genres with low ratings

SELECT top 10 prime_genre, avg(user_rating) as avg_rating
FROM AppleStore as2 
GROUP BY prime_genre 
ORDER BY avg_rating ASC

-- Check if there is correlation between the length of the app description and the user rating

SELECT CASE
	WHEN len(asdc.app_desc) <500 THEN 'Short'
	WHEN len(asdc.app_desc) >500 AND len(asdc.app_desc) <1000 THEN 'Medium'
	ELSE 'Long'
END as desc_length_bucket,
avg(as2.user_rating) as avg_rating

FROM AppleStore as2 
JOIN AppleStore_description_combined asdc 
ON as2.id = asdc.id
GROUP BY (
CASE
	WHEN len(asdc.app_desc) <500 THEN 'Short'
	WHEN len(asdc.app_desc) >500 AND len(asdc.app_desc) <1000 THEN 'Medium'
	ELSE 'Long'
END)
ORDER BY avg_rating DESC

-- Check the top rated apps for each genre

SELECT 
prime_genre,
track_name,
user_rating
FROM (
SELECT
prime_genre,
track_name,
user_rating,
RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) as app_rank
FROM AppleStore as2 
) as A
WHERE A.app_rank = 1

/*
 * KEY FINDINGS:
 * 1. Paid apps have better ratings
 * 2. Apps supporting between 10 and 30 languages have better ratings
 * 3. Finance and book apps have low ratings
 * 4. Apps with longer description have better ratings
 * 5. A new app should aim for an average rating above 3.5
 * 6. Games and entertainment have high competition
 */


