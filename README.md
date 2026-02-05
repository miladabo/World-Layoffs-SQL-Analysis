# Global Layoffs Analysis: Data Cleaning & EDA (SQL)

## Overview
This project executes an end-to-end data analysis workflow using MySQL, transitioning from raw data cleaning to advanced exploratory analysis. The dataset tracks global layoffs from 2020 to 2023. The goal was to solve data granularity issues and derive strategic insights into industry shifts and company resilience.

## 1. Data Cleaning & Standardization
Ensured data integrity through a rigorous preparation phase:
- **De-duplication**: Removed redundant records using CTEs and `ROW_NUMBER()`.
- **Standardization**: Unified industry labels (e.g., Crypto) and corrected geographic inconsistencies.
- **Time-Series Prep**: Converted string dates to SQL `DATE` format.
- **Null Handling**: Populated missing industry data via self-joins.

## 2. Methodology: Peak Workforce Estimation
A key challenge in this dataset was **Granularity**, where companies reported layoffs across multiple regional offices or dates.
- **Strategic Approach**: Instead of simply averaging or summing workforce counts (which leads to inflation), I implemented a **Peak Workforce Estimation** logic using `MAX(total_laid_off / percentage_laid_off)`.
- **Result**: This ensured accurate "Impact Ratios." For example, **Uber's** cumulative impact was corrected to a realistic **28.5%**, aligning with global reports rather than distorted regional sums.

## 3. Key Findings & Insights

### A. The "Industry Shift" (2020 vs. 2023)
The analysis reveals a distinct shift in the economic crisis trajectory:
- **2020 (The Travel Collapse)**: The crisis began in the physical movement sector due to COVID-19 lockdowns. The top layoffs were dominated by **Uber**, **Booking.com**, and **Airbnb**.
- **2023 (The Big Tech Correction)**: By 2023, the trend flipped entirely to digital giants. The leaderboard was dominated by **Google**, **Microsoft**, and **Ericsson**, reflecting a post-pandemic market correction.

### B. Scale vs. Impact
- **Amazon** recorded the highest absolute layoff volume (**18,000**), but this represented only **~4.5%** of its estimated workforce.
- In contrast, companies like **Twitter** and **Uber** faced much higher relative structural changes (Impact Ratios > 28%).

### C. Financial Resilience
- **Netflix** demonstrated that high capital reserves correlate with stability. Despite holding the highest funding in the dataset (**$121.9 Billion**), it recorded only **505** layoffs.
- **Yearly Peak**: The highest global layoff volume occurred in **2022**, reaching **160,661** recorded job cuts.

## 4. Technical Stack
- **Database**: MySQL.
- **Techniques**: Window Functions (`DENSE_RANK`, `SUM OVER`), CTEs, Feature Engineering, and Data Validation.
