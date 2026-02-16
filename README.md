# YouTube Comments Abuse Analysis

## Overview 
This project analyzes YouTube comment data to identify abuse patterns, toxicity levels, and user behavior trends using Python, MySQL, and Power BI. The study categorizes comments into severity levels based on predefined keyword scoring logic and evaluates how negative engagement spreads across users. Through structured data processing and analytical queries, the project provides insights relevant to Trust & Safety analytics and content moderation strategies.

## Objectives
- Classify comments into severity categories based on abuse intensity
- Quantify toxic, mass negativity, and extreme harm comment distribution
- Identify high-risk users based on cumulative toxicity scoring
- Analyze engagement metrics across severity levels
- Visualize abuse trends to support moderation decision-making

## Database Structure
The youtube_abuse_analysis database follows a structured analytical model:

- **comments** table stores raw comment data including author, comment_text, like_count, and published_at
- A severity scoring logic assigns numeric toxicity levels based on keyword detection
- A derived severity_category classification categorizes comments into Neutral, Mass Negativity, Extreme Harm, and Direct Abuse
- Aggregations and analytical queries are performed to generate user-level and category-level insights

## Key Insights
- 9,460 total comments analyzed with structured severity classification
- 4,184 comments categorized as Mass Negativity and 181 identified as Toxic
- Extreme Harm comments represent approximately 1.21% of total data
- High-risk users identified through cumulative toxicity scoring patterns


## Tools Used
Python (Data Cleaning & Processing), MySQL (Severity Modeling & Analysis), Power BI (Dashboard & Visualization)
