/*
Data Cleaning Project - World Layoffs
--------------------------------------------------------------------------------
Description: 
    This script performs data cleaning on the 'layoffs' dataset.
    Key steps include:
    1. Removing Duplicates
    2. Standardizing Data (Spelling, trimming, format corrections)
    3. Null Value and Blank Value Handling
    4. Removing Unnecessary Columns/Rows
*/

-- =============================================================================
-- Step 0: Create Staging Table
-- =============================================================================
-- We create a staging table to preserve the raw data and perform operations safely.

SELECT * FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;


-- =============================================================================
-- Step 1: Remove Duplicates
-- =============================================================================

-- Checking for duplicates using ROW_NUMBER window function
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Note: In MySQL, we cannot directly update/delete from a table using a CTE on the same table.
-- Solution: Create a second staging table (layoffs_staging2) with the 'row_num' column added.

CREATE TABLE `layoffs_staging2` (
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

-- Insert data into the new table with row numbers
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Verify duplicates (row_num > 1)
SELECT * FROM layoffs_staging2
WHERE row_num > 1;

-- Delete duplicates
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Check to ensure duplicates are gone
SELECT * FROM layoffs_staging2
WHERE row_num > 1;


-- =============================================================================
-- Step 2: Standardizing Data
-- =============================================================================

-- A. Trim Company Names -------------------------------------------------------
UPDATE layoffs_staging2
SET company = TRIM(company);


-- B. Standardize Industry Names -----------------------------------------------
-- Identified variations like 'Crypto', 'Crypto Currency', etc.
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- C. Standardize Country Names ------------------------------------------------
-- Identified issue: 'United States.' with a trailing period.
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- D. Format Date Column -------------------------------------------------------
-- Convert string date to actual DATE format
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change column data type to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- =============================================================================
-- Step 3: Null and Blank Values Handling
-- =============================================================================

-- A. Industry Column ----------------------------------------------------------
-- Convert empty strings to NULL to facilitate matching
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate NULL industry values using data from the same company (Self Join)
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


-- =============================================================================
-- Step 4: Remove Unnecessary Columns and Rows
-- =============================================================================

-- A. Remove rows with no useful layoff data -----------------------------------
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- B. Remove the helper column 'row_num' ---------------------------------------
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- =============================================================================
-- Final Check
-- =============================================================================
SELECT * FROM layoffs_staging2;