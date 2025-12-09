# DATA-CLEANING-AND-EXPLORATION-USING-SQL
This project demonstrates end-to-end data cleaning and exploratory data analysis (EDA) using MySQL. The goal is to transform a raw layoffs dataset into a clean analytical dataset and extract meaningful insights about global layoffs across industries, companies, countries, and years

This project provides a full SQL-based workflow for cleaning, transforming, and analyzing a global company layoffs dataset.
The dataset includes company names, locations, industries, dates of layoffs, amounts laid off, funding levels, and other variables.

The goal of this project is to demonstrate practical SQL skills useful for real-world data work:
data cleaning, wrangling, standardization, and exploratory data analysis (EDA).

#  SQL Data Cleaning and Exploratory Data Analysis (EDA)
### Layoffs Dataset — SQL Project

#  Dataset Overview
- Explanation of columns and dataset context

#  Project Objectives
- List of goals for cleaning and analysis

# Tools & Technologies
- MySQL
- SQL techniques (window functions, CTEs, etc.)

# DATA CLEANING WORKFLOW

##  1. Create Staging Tables
- SQL code
- Short explanation

##  2. Identify Duplicate Records
- SQL code
- Explanation

## 3. Create Second Staging Table & Remove Duplicates
- SQL code
- Explanation

##  4. Standardize String Fields
### 4.1 Trim company names  
### 4.2 Standardize industry  
### 4.3 Clean country values  
- SQL code  
- Explanation  

##  5. Convert Date Format
- SQL code  
- Explanation  

## 6. Fix Missing Values
### 6.1 Identify missing values  
### 6.2 Fill missing using joins  
### 6.3 Remove records with no meaningful data  
- SQL code  
- Explanation  

## 7. Remove Helper Columns
- SQL code  
- Explanation  

# EXPLORATORY DATA ANALYSIS (EDA)

## 1. Maximum layoffs  
- SQL code  
- Explanation  

## 2. Companies with 100% layoffs  
- SQL code  
- Explanation  

## 3. Total layoffs by company  
- SQL code  
- Explanation  

## 4. Layoffs by industry  
- SQL code  
- Explanation  

## 5. Layoffs by country  
- SQL code  
- Explanation  

## 6. Layoffs by year  
- SQL code  
- Explanation  

## 7. Layoffs by funding stage  
- SQL code  
- Explanation  

## 8. Monthly layoff trend  
- SQL code  
- Explanation  

## 9. Rolling total layoffs  
- SQL code  
- Explanation  

## 10. Company layoffs yearly ranking  
- SQL code  
- Explanation  

# GENERAL INSIGHTS FROM THE DATASET
- Summary of major findings from analysis

# How to Use This Project
- Step-by-step setup for users

#  Author
- Adewumi Dolapo- Data Analyst


 Dataset Overview

The dataset contains global layoffs from various tech and non-tech companies.
Common fields include:

Column	Meaning
company	Name of the organization
location	City where layoff occurred
industry	Sector of the company
total_laid_off	Number of employees laid off
percentage_laid_off	Proportion of workforce laid off
date	Date the layoff occurred
stage	Funding or business stage (e.g., Post-IPO, Series A)
country	Country where layoff occurred
funds_raised_millions	Total amount of money raised

The dataset contains missing values, inconsistencies (e.g., “Crypto / Blockchain”), duplicates, uneven date formatting, and noise—making it a good case study for SQL data cleaning.

Project Objectives

Clean messy records and inconsistent fields

Remove duplicate entries

Standardize industry and country values

Format dates into MySQL DATE format

Remove meaningless rows

Perform extensive EDA to reveal patterns and insights

 Tools & Technologies

MySQL

SQL window functions

CTEs

Date and string functions

 DATA CLEANING WORKFLOW
 1. Create Staging Tables
CREATE TABLE layoffs_stagging LIKE layoffs;

INSERT INTO layoffs_stagging
SELECT * FROM layoffs;


 Explanation:
We create a staging table to work safely without modifying the raw data.

 2. Identify Duplicate Records
SELECT *, 
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
    percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_stagging;


 Explanation:
The ROW_NUMBER() window function assigns a number to each duplicate group so duplicates can be identified.

 3. Create a Second Staging Table and Remove Duplicates
CREATE TABLE layoffs_stagging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT,
  row_num INT
);

INSERT INTO layoffs_stagging2
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off,
    percentage_laid_off, `date`, stage, country, funds_raised_millions
)
FROM layoffs_stagging;

DELETE FROM layoffs_stagging2 WHERE row_num > 1;


 Explanation:
We store duplicates in a new table and delete all rows where row_num > 1 (actual duplicates).

4. Standardize String Fields
Trim company names
UPDATE layoffs_stagging2
SET company = TRIM(company);


 Explanation:
Removes unnecessary leading and trailing spaces.

Standardize industry values
UPDATE layoffs_stagging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


 Explanation:
Groups different variations like “Crypto / Blockchain” into a single label.

Clean country formatting
UPDATE layoffs_stagging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


Explanation:
Removes trailing periods and ensures country names follow one standard.

5. Convert Date Format
UPDATE layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE;


 Explanation:
Converts text dates to proper SQL DATE format for analysis.

 6. Fix Missing Values
Identify missing industries
SELECT * FROM layoffs_stagging2
WHERE industry IS NULL OR industry = '';


 Explanation:
Finds blank or missing values that require correction.

Fill missing industries using other rows from the same company
UPDATE layoffs_stagging2 t1
JOIN layoffs_stagging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;


Explanation:
Uses known values from the same company to fill missing ones.

Remove rows with no meaningful layoff data
DELETE FROM layoffs_stagging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


 Explanation:
Removes records that cannot contribute to analysis.

 7. Remove Helper Columns
ALTER TABLE layoffs_stagging2
DROP COLUMN row_num;


 Explanation:
Drops the duplicate-tracking column after cleanup is complete.

EXPLORATORY DATA ANALYSIS (EDA)
 1. Maximum layoffs recorded
SELECT MAX(total_laid_off) FROM layoffs_stagging2;


 Explanation:
Shows the largest single layoff count in the dataset.

 2. Companies that laid off 100% of their workforce
SELECT * FROM layoffs_stagging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


 Explanation:
Identifies companies that completely shut down or terminated all employees.

 3. Total layoffs by company
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_stagging2
GROUP BY company
ORDER BY total_laid_off DESC;


Explanation:
Shows the top companies with the highest total layoffs.

 4. Layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY industry
ORDER BY 2 DESC;


 Explanation:
Reveals which industries were hardest hit.

 5. Layoffs by country
SELECT country, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY country
ORDER BY 2 DESC;


 Explanation:
Displays countries with the highest layoff counts.

 6. Yearly layoff trend
SELECT YEAR(`date`) AS year, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY year
ORDER BY year DESC;


 Explanation:
Shows how layoffs trend from year to year—useful for economic pattern analysis.

 7. Layoffs by funding stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY stage
ORDER BY 2 DESC;


 Explanation:
Helps understand how a company’s stage affects layoffs (e.g., startups vs. large IPO companies).

8. Monthly layoff trend
SELECT SUBSTRING(`date`, 1, 7) AS month,
SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY month
ORDER BY month DESC;


Explanation:
Creates month-based trends for more granular analysis.

 9. Rolling total of layoffs
WITH rolling_total AS (
  SELECT SUBSTRING(`date`, 1, 7) AS month,
         SUM(total_laid_off) AS total_off
  FROM layoffs_stagging2
  GROUP BY month
)
SELECT month, total_off,
       SUM(total_off) OVER (ORDER BY month) AS rolling_total
FROM rolling_total;


 Explanation:
Shows cumulative layoffs over time—helpful for long-term trend visualization.

 10. Ranking companies by layoffs per year
WITH company_year AS (
  SELECT company,
         YEAR(`date`) AS years,
         SUM(total_laid_off) AS total_laid_off
  FROM layoffs_stagging2
  GROUP BY company, years
)
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL;


 Explanation:
Ranks companies by layoffs for each year — useful for comparing performance over time.

 GENERAL INSIGHTS FROM THE DATASET

The technology sector experienced the highest number of layoffs, especially during economic downturn periods.

The United States had the largest volume of layoffs globally.

Several companies had multiple layoff events spanning months or years, indicating ongoing restructuring.

Some companies completely shut down departments or entire organizations (100% layoffs).

Layoff spikes occurred during economic slowdowns, market crashes, and funding shortages.

Early-stage startups with limited funding often had higher layoff percentages.

Rolling totals show a significant cumulative increase during specific periods like pandemics or economic recessions.

 How to Use This Project

Clone/download repository

Import dataset into MySQL

Run the provided SQL script:

layoffs_data_cleaning_and_eda.sql


Explore and modify queries as needed

Author

Adewumi Dolapo
SQL | Data Cleaning | Data Analysis | EDA | MySQL
