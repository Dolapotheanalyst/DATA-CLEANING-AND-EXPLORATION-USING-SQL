show tables;
-- DATA CLEANING PROCESSES

-- REMOVE DUPLICATES
-- STANDARDIZATION
-- DEALING WITH NULL OR MISSING VALUES
-- REMOVING UNNECESSARY ROWS/COLUMS


CREATE TABLE layoffs_stagging
LIKE layoffs;

SELECT * FROM layoffs_stagging;

insert into layoffs_stagging
select * from layoffs;
SELECT * FROM layoffs_stagging;

-- 1.  REMOVING DUPLICATES

select *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_Laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_stagging;
with duplicate_cte as ( select *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_Laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_stagging)
select * from duplicate_cte where row_num > 1;

CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_stagging2;
insert into layoffs_stagging2
select *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_Laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_stagging;
select * from layoffs_stagging2
where row_num > 1;

-- STANDARDIZATION

Delete from layoffs_stagging2
where row_num > 1;
select * from layoffs_stagging2;
-- TRIMMING
select distinct company from layoffs_stagging2;
select company, Trim(company) from layoffs_stagging2;
UPDATE layoffs_stagging2
set company =  Trim(company);
-- CHECKING DATA 
select distinct industry from layoffs_stagging2;
select * from layoffs_stagging2 where industry like 'Crypto%';
UPDATE layoffs_stagging2
set industry = "Crypto"
where industry like "Crypto%";
select country from layoffs_stagging2 where country like "united states_";
UPDATE layoffs_stagging2
set country = TRIM(Trailing "." from country)
where country like "United states%";

UPDATE layoffs_stagging2
set `date` = str_to_date(`date`, "%m/%d/%Y");
select * from layoffs_stagging2;

ALTER TABLE layoffs_stagging2
Modify column `date` Date;


-- DEALING WITH NULL VALUES
select * from layoffs_stagging2 where total_laid_off is null and percentage_laid_off is null;

select * from layoffs_stagging2 where industry is null or industry= "";
select * from layoffs_stagging2 t1 join layoffs_stagging2 t2
	on t1.company = t2.company 
where t1.industry is null or t1.industry = ""
and t2.industry is not null;
select t1.industry,t2.industry from layoffs_stagging2 t1 join layoffs_stagging2 t2
	on t1.company = t2.company 
where t1.industry is null or t1.industry = ""
and t2.industry is not null;

UPDATE layoffs_stagging2 
set industry = null
where industry = "";

UPDATE layoffs_stagging2 t1
join layoffs_stagging2 t2
	on t1.company = t2.company
set t1.industry = t2.company
where t1.industry is null and t2.industry is not null;

-- REMOVING UNNECESSARY COLUMNS/ROWS
select * from layoffs_stagging2 where total_laid_off is null and percentage_laid_off is null;
DELETE  from layoffs_stagging2 where total_laid_off is null and percentage_laid_off is null;
ALTER TABLE layoffs_stagging2
DROP COLUMN row_num;
select * from layoffs_stagging2;


-- EXPLORATORY DATA ANALYTICS
select * from layoffs_stagging2;
select max(total_laid_off) from layoffs_stagging2;

select max(total_laid_off),max(percentage_laid_off) from layoffs_stagging2;

select * from layoffs_stagging2 
where percentage_laid_off = 1 order by total_laid_off desc;

select * from layoffs_staring2 
where percentage_laid_off = 1 order by funds_raised_millions desc;

select distinct company, sum(total_laid_off)
 from layoffs_stagging2
 group by company order by 2 desc;
 select min(`date`), max(`date`), (company), sum(total_laid_off)
 from layoffs_stagging2
 group by company order by min(`date`), max(`date`) desc;
 
 select distinct industry, sum(total_laid_off)
 from layoffs_stagging2
 group by industry order by 2 desc;
 
 select * from layoffs_stagging2;
 select distinct country, sum(total_laid_off)
 from layoffs_stagging2
 group by country order by 2 desc;
 
 select year(`date`), sum(total_laid_off)
 from layoffs_stagging2
 group by year(`date`) order by 1 desc;
 
  select distinct stage, sum(total_laid_off)
 from layoffs_stagging2
 group by stage order by 2 desc;
 
 select company, sum(percentage_laid_off)
 from layoffs_stagging2
 group by company order by 2 desc;
 
 select company, avg(percentage_laid_off)
 from layoffs_stagging2
 group by company order by 2 desc;
 
 select * from layoffs_stagging2;
 
 select Substring(`date`,1,7) as `month`, sum(total_laid_off) from layoffs_stagging2
 group by `month` order by 1 desc;
 
 select Substring(`date`,1,7) as `month`, sum(total_laid_off) from layoffs_stagging2
 where  Substring(`date`,1,7) is not null
 group by `month` order by 2 desc;
 
 with rolling_total as ( select Substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off from layoffs_stagging2
 where  Substring(`date`,1,7) is not null
 group by `month` order by 2 desc)
 select `month`, total_off,  sum(total_off) over(order by `month`) as "Rolling_total"
 from rolling_total;
 
 select company, sum(total_laid_off)
 from layoffs_stagging2
 group by company order by 2 desc;
 
  select company, year(`date`), sum(total_laid_off)
 from layoffs_stagging2
 group by company, year(`date`) order by company asc;
 
  select company, year(`date`), sum(total_laid_off)
 from layoffs_stagging2
 group by company, year(`date`) order by 3 desc;
 
 with company_year (Company, Years, Total_laid_off) as ( select company, year(`date`), sum(total_laid_off) 
 from layoffs_stagging2
 group by company, year(`date`))
 select *, dense_rank() over(partition by Years order by Total_laid_off desc) as ranking
 from company_year where Years is not null; 
 
 
 
 
 
 






