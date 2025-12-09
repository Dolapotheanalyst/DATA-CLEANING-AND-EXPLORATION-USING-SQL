# DATA-CLEANING-AND-EXPLORATION-USING-SQL
This project demonstrates end-to-end data cleaning and exploratory data analysis (EDA) using MySQL. The goal is to transform a raw layoffs dataset into a clean analytical dataset and extract meaningful insights about global layoffs across industries, companies, countries, and years

This project provides a full SQL-based workflow for cleaning, transforming, and analyzing a global company layoffs dataset.
The dataset includes company names, locations, industries, dates of layoffs, amounts laid off, funding levels, and other variables.

The goal of this project is to demonstrate practical SQL skills useful for real-world data work:
data cleaning, wrangling, standardization, and exploratory data analysis (EDA).


# SQL Data Cleaning and Exploratory Data Analysis (EDA)
### Layoffs Dataset — SQL Project

---

##  Dataset Overview

The dataset contains global layoffs from various tech and non-tech companies.  
Common fields include:

| Column | Meaning |
|--------|---------|
| **company** | Name of the organization |
| **location** | City where layoff occurred |
| **industry** | Sector of the company |
| **total_laid_off** | Number of employees laid off |
| **percentage_laid_off** | Proportion of workforce laid off |
| **date** | Date the layoff occurred |
| **stage** | Funding or business stage (e.g., Post-IPO, Series A) |
| **country** | Country where layoff occurred |
| **funds_raised_millions** | Total amount of money raised |

The dataset contains missing values, inconsistencies (e.g., “Crypto / Blockchain”), duplicates, uneven date formatting, and noise—making it a good case study for SQL data cleaning.

---

##  Project Objectives

- Clean messy records and inconsistent fields  
- Remove duplicate entries  
- Standardize industry and country values  
- Format dates into MySQL DATE format  
- Remove meaningless rows  
- Perform extensive EDA to reveal patterns and insights  

---

##  Tools & Technologies

- **MySQL**  
- **SQL window functions**  
- **CTEs**  
- **Date and string functions**

---

#  DATA CLEANING WORKFLOW

---

## **1. Create Staging Tables**

```sql
CREATE TABLE layoffs_stagging LIKE layoffs;

INSERT INTO layoffs_stagging
SELECT * FROM layoffs;
```

**Explanation:**  
We create a staging table to work safely without modifying the raw data.

---

## **2. Identify Duplicate Records**

```sql
SELECT *, 
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
    percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_stagging;
```

**Explanation:**  
The `ROW_NUMBER()` window function assigns a number to each duplicate group so duplicates can be identified.

---

## **3. Create a Second Staging Table and Remove Duplicates**

```sql
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
```

**Explanation:**  
Duplicates are stored in a new table and deleted where `row_num > 1`.

---

## **4. Standardize String Fields**

### **Trim company names**

```sql
UPDATE layoffs_stagging2
SET company = TRIM(company);
```

**Explanation:**  
Removes unnecessary leading and trailing spaces.

---

### **Standardize industry values**

```sql
UPDATE layoffs_stagging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
```

**Explanation:**  
Groups variations like “Crypto / Blockchain” under a single clean label.

---

### **Clean country formatting**

```sql
UPDATE layoffs_stagging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
```

**Explanation:**  
Removes trailing punctuation to ensure consistent formatting.

---

## **5. Convert Date Format**

```sql
UPDATE layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE;
```

**Explanation:**  
Converts text-based dates into SQL DATE format for accurate analysis.

---

## **6. Fix Missing Values**

### **Identify missing industries**

```sql
SELECT * FROM layoffs_stagging2
WHERE industry IS NULL OR industry = '';
```

**Explanation:**  
Finds blank or missing values that require correction.

---

### **Fill missing industries using other rows from the same company**

```sql
UPDATE layoffs_stagging2 t1
JOIN layoffs_stagging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
```

**Explanation:**  
Uses known values from the same company to fill missing ones.

---

### **Remove rows with no meaningful layoff data**

```sql
DELETE FROM layoffs_stagging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```

**Explanation:**  
Removes records that cannot contribute to analysis.

---

## **7. Remove Helper Columns**

```sql
ALTER TABLE layoffs_stagging2
DROP COLUMN row_num;
```

**Explanation:**  
Drops the duplicate-tracking column after cleanup.

---

#  EXPLORATORY DATA ANALYSIS (EDA)

---

## **1. Maximum layoffs recorded**

```sql
SELECT MAX(total_laid_off) FROM layoffs_stagging2;
```

**Explanation:**  
Shows the largest single layoff count.

---

## **2. Companies that laid off 100% of their workforce**

```sql
SELECT * FROM layoffs_stagging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
```

**Explanation:**  
Shows companies that completely shut down or removed all staff.

---

## **3. Total layoffs by company**

```sql
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_stagging2
GROUP BY company
ORDER BY total_laid_off DESC;
```

**Explanation:**  
Shows companies with the highest total layoffs.

---

## **4. Layoffs by industry**

```sql
SELECT industry, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY industry
ORDER BY 2 DESC;
```

**Explanation:**  
Identifies the industries most affected by layoffs.

---

## **5. Layoffs by country**

```sql
SELECT country, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY country
ORDER BY 2 DESC;
```

**Explanation:**  
Shows which countries had the highest layoff counts.

---

## **6. Yearly layoff trend**

```sql
SELECT YEAR(`date`) AS year, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY year
ORDER BY year DESC;
```

**Explanation:**  
Helps understand layoffs over time.

---

## **7. Layoffs by funding stage**

```sql
SELECT stage, SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY stage
ORDER BY 2 DESC;
```

**Explanation:**  
Shows how funding stage relates to layoff severity.

---

## **8. Monthly layoff trend**

```sql
SELECT SUBSTRING(`date`, 1, 7) AS month,
SUM(total_laid_off)
FROM layoffs_stagging2
GROUP BY month
ORDER BY month DESC;
```

**Explanation:**  
Provides monthly breakdowns for trend analysis.

---

## **9. Rolling total of layoffs**

```sql
WITH rolling_total AS (
  SELECT SUBSTRING(`date`, 1, 7) AS month,
         SUM(total_laid_off) AS total_off
  FROM layoffs_stagging2
  GROUP BY month
)
SELECT month, total_off,
       SUM(total_off) OVER (ORDER BY month) AS rolling_total
FROM rolling_total;
```

**Explanation:**  
Shows accumulating layoffs over time.

---

## **10. Ranking companies by layoffs per year**

```sql
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
```

**Explanation:**  
Ranks companies by total layoffs yearly.

---

#  GENERAL INSIGHTS FROM THE DATASET

- The technology sector experienced the highest number of layoffs.  
- The United States recorded the largest volume of layoffs.  
- Many companies had repeated layoffs over long periods.  
- Some organizations completely shut down (100% layoffs).  
- Layoff spikes often align with economic slowdowns and funding shortages.  
- Startups with limited capital showed higher proportional layoffs.  
- Rolling totals show sharp increases during crises such as pandemics.  

---

#  How to Use This Project

1. Clone or download the repository  
2. Import the dataset into MySQL  
3. Run:

```
layoffs_data_cleaning_and_eda.sql
```

4. Explore or modify queries as needed  

---

#  Author

**Adewumi Dolapo**  
SQL | Data Cleaning | Data Analysis | EDA | MySQL
