-- EDA: World Layoffs Data Analysis
-- Objective: Analyze global layoff trends (2020-2023) and calculate workforce impact metrics using advanced SQL.

-- 1. Initial Data Inspection
SELECT * FROM layoffs_staging2;

-- Identifying global extremes (Max Layoffs & Max Percentage)
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- 2. Feature Engineering: Workforce Estimation
-- Logic: Reverse-engineering the total workforce size per entry to contextualize raw layoff numbers.
SELECT 
    company, 
    total_laid_off, 
    percentage_laid_off, 
    ceil((total_laid_off / percentage_laid_off)) AS estimated_employee_count
FROM layoffs_staging2
ORDER BY total_laid_off DESC;

-- 3. Company Impact Analysis (Key Metric)
-- Methodology: Utilizing MAX() to estimate Peak Workforce. 
-- This handles data granularity issues (companies with multiple regional entries) to prevent double-counting.
SELECT 
    company,
    SUM(total_laid_off) AS total_people_laid_off,
    CEIL(MAX(total_laid_off / percentage_laid_off)) AS estimated_peak_workforce,
    ROUND(SUM(total_laid_off) / MAX(total_laid_off / percentage_laid_off), 3) AS impact_ratio
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL 
  AND percentage_laid_off IS NOT NULL
GROUP BY company
ORDER BY total_people_laid_off DESC;

-- 4. Financial Stability Analysis
-- Logic: Comparing capital raised (MAX) against layoff volume. MAX is used to represent the company's total funding accurately.
SELECT 
    company,
    SUM(total_laid_off) AS total_people_laid_off,
    MAX(funds_raised_millions) AS total_funds_millions
FROM layoffs_staging2
GROUP BY company
ORDER BY total_funds_millions DESC;

-- 5. Location Analysis
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- 6. Time Series Analysis (Yearly Trends)
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- 7. Rolling Total Calculation (Momentum Analysis)
-- Tracking the cumulative progression of layoffs month-over-month.
WITH Rolling_Total AS (
    SELECT 
        SUBSTR(`date`, 1, 7) AS `month`, 
        SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTR(`date`, 1, 7) IS NOT NULL
    GROUP BY `month`
    ORDER BY 1 ASC
)
SELECT 
    `month`, 
    total_off, 
    SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;

-- 8. Industry Shift Analysis: Top 5 Companies Per Year
-- Identifying which sectors were hit hardest in each year (Travel vs. Big Tech).
WITH Company_Year AS (
    SELECT industry, company, YEAR(`date`) AS `year`, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY industry, company, YEAR(`date`)
), 
Company_Ranking AS (
    SELECT *, 
    DENSE_RANK() OVER (PARTITION BY `year` ORDER BY total_laid_off DESC) AS ranking
    FROM Company_Year
    WHERE `year` IS NOT NULL
)
SELECT *
FROM Company_Ranking
WHERE ranking <= 5;