CREATE DATABASE youtube_abuse_analysis;

USE youtube_abuse_analysis;

# Create table

CREATE TABLE comments (
    author VARCHAR(255),
    comment_text TEXT,
    like_count INT,
    published_at VARCHAR(50)
);

# Load the data file saved from the Python file

SET GLOBAL local_infile = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Youtube Abuse Analysis Comments.csv'
INTO TABLE comments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(author, comment_text, like_count, published_at);

SELECT count(*) FROM comments;

SELECT * FROM comments;

# Remove the empty comment_text records

DELETE FROM comments
WHERE comment_text IS NULL
OR TRIM(comment_text) = '';

# Convert published_at column to DATETIME in SQL from varchar

ALTER TABLE comments
MODIFY published_at DATETIME;

SELECT count(*) FROM comments;


# Engagement for the comments

SELECT MIN(like_count) AS min_likes, MAX(like_count) AS max_likes, AVG(like_count) AS avg_likes FROM comments;


# Segregating of Comments into two sections of TOXICITY and NEGATIVITY using VIEW

CREATE VIEW classified_comments AS
SELECT *,
    (
        (comment_text LIKE '%kill%') * 3 +
        (comment_text LIKE '%die%') * 3 +
        (comment_text LIKE '%murder%') * 3 +

        (comment_text LIKE '%idiot%') * 2 +
        (comment_text LIKE '%stupid%') * 2 +
        (comment_text LIKE '%moron%') * 2 +
        (comment_text LIKE '%useless%') * 2 +
        (comment_text LIKE '%fraud%') * 2 +
        (comment_text LIKE '%scam%') * 2 +
        (comment_text LIKE '%corrupt%') * 2 +
        (comment_text LIKE '%garbage%') * 2 +
        (comment_text LIKE '%disgusting%') * 2 +

        -- Level 1 (Mass Negativity)
        (comment_text LIKE '%worst%') * 1 +
        (comment_text LIKE '%flop%') * 1 +
        (comment_text LIKE '%boycott%') * 1 +
        (comment_text LIKE '%ban%') * 1 +
        (comment_text LIKE '%bad%') * 1 +
        (comment_text LIKE '%disaster%') * 1 +
        (comment_text LIKE '%hate%') * 1 +
        (comment_text LIKE '%dislike%') * 1 +
        (comment_text LIKE '%overrated%') * 1 +
        (comment_text LIKE '%waste%') * 1

    ) AS toxicity_score,

    CASE
        WHEN (
            (comment_text LIKE '%kill%') +
            (comment_text LIKE '%die%') +
            (comment_text LIKE '%murder%')
        ) > 0
        THEN 'Extreme Harm'

        WHEN (
            (comment_text LIKE '%idiot%') +
            (comment_text LIKE '%stupid%') +
            (comment_text LIKE '%moron%') +
            (comment_text LIKE '%useless%') +
            (comment_text LIKE '%fraud%') +
            (comment_text LIKE '%scam%') +
            (comment_text LIKE '%corrupt%') +
            (comment_text LIKE '%garbage%') +
            (comment_text LIKE '%disgusting%')
        ) > 0
        THEN 'Direct Abuse'

        WHEN (
            (comment_text LIKE '%worst%') +
            (comment_text LIKE '%flop%') +
            (comment_text LIKE '%boycott%') +
            (comment_text LIKE '%ban%') +
            (comment_text LIKE '%bad%') +
            (comment_text LIKE '%disaster%') +
            (comment_text LIKE '%hate%') +
            (comment_text LIKE '%dislike%') +
            (comment_text LIKE '%overrated%') +
            (comment_text LIKE '%waste%')
        ) > 0
        THEN 'Mass Negativity'

        ELSE 'Neutral'
    END AS severity_category
FROM comments;

SELECT * FROM classified_comments;

# Severity Distibution %

SELECT severity_category, COUNT(*) AS total_comments, ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM classified_comments), 2) AS percentage
FROM classified_comments
GROUP BY severity_category
ORDER BY total_comments DESC;

# Severity vs Engagement - Do more toxicity lead to more eengagement?

SELECT severity_category, COUNT(*) AS total_comments, AVG(like_count) AS avg_likes
FROM classified_comments
GROUP BY severity_category
ORDER BY avg_likes DESC;


# Top users by extreme harm

SELECT author, COUNT(*) AS extreme_comments FROM classified_comments
WHERE severity_category = 'Extreme Harm'
GROUP BY author
ORDER BY extreme_comments DESC
LIMIT 10;


# Top Users by direct abuse

SELECT author, COUNT(*) AS abuse_comments FROM classified_comments
WHERE severity_category = 'Direct Abuse'
GROUP BY author
ORDER BY abuse_comments DESC
LIMIT 10;


# User Risk Score

SELECT author, SUM(toxicity_score) AS total_risk_score, COUNT(*) AS total_comments, ROUND(AVG(toxicity_score), 2) AS avg_risk_per_comment
FROM classified_comments
GROUP BY author
ORDER BY total_risk_score DESC
LIMIT 10;


# Highest comments by date

SELECT DATE(published_at) AS comment_date, COUNT(*) AS total_comments FROM classified_comments
GROUP BY comment_date
ORDER BY comment_date;


# Highest extreme harm comments by date

SELECT DATE(published_at) AS comment_date, COUNT(*) AS extreme_count FROM classified_comments
WHERE severity_category = 'Extreme Harm'
GROUP BY comment_date
ORDER BY comment_date;


# Toxic percentage by date

SELECT DATE(published_at) AS comment_date, COUNT(*) AS total_comments, SUM(severity_category IN ('Direct Abuse', 'Extreme Harm')) AS toxic_comments,
ROUND(SUM(severity_category IN ('Direct Abuse', 'Extreme Harm')) / COUNT(*) * 100, 2) AS toxic_percentage
FROM classified_comments
GROUP BY comment_date
ORDER BY comment_date;

-- toxic_percentage = toxic_comments/(total_comments * 100)


# Average Likes by severity

SELECT severity_category, COUNT(*) AS total_comments, ROUND(AVG(like_count), 2) AS avg_likes
FROM classified_comments
GROUP BY severity_category
ORDER BY avg_likes DESC;


# Count of Individual toxic Keywords used in the comments

SELECT 
    SUM(comment_text LIKE '%kill%') AS kill_count,
    SUM(comment_text LIKE '%die%') AS die_count,
    SUM(comment_text LIKE '%idiot%') AS idiot_count,
    SUM(comment_text LIKE '%stupid%') AS stupid_count,
    SUM(comment_text LIKE '%boycott%') AS boycott_count,
    SUM(comment_text LIKE '%dislike%') AS dislike_count
FROM comments;


# Do toxic comments get more likes than neutral ones? Using Joins

SELECT cc.severity_category, COUNT(*) AS total_comments, ROUND(AVG(c.like_count), 2) AS avg_likes
FROM comments c
JOIN classified_comments cc
ON c.author = cc.author AND c.published_at = cc.published_at AND c.comment_text = cc.comment_text
GROUP BY cc.severity_category
ORDER BY avg_likes DESC;


# Who are the top 3 most liked Direct Abuse comments? Using Joins

SELECT c.author, c.comment_text, c.like_count FROM comments c
JOIN classified_comments cc
ON c.author = cc.author AND c.published_at = cc.published_at AND c.comment_text = cc.comment_text
WHERE cc.severity_category = 'Direct Abuse'
ORDER BY c.like_count DESC
LIMIT 3;


