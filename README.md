# Cohort Analysis & User Retention Project

## Project Overview
Analysis of user retention from January to June 2025 using SQL and Google Sheets. Users were segmented by registration channel (organic vs. promo signups) to evaluate marketing efficiency.

## Technical Workflow
* **SQL (PostgreSQL):** Cleaned raw text dates (`SPLIT_PART`, `TRIM`), filtered anomalies, and aggregated metrics into a structured data mart using CTEs.
* **Google Sheets:** Built pivot tables, applied slicers for promo flags, calculated the **Retention Rate Matrix (%)**, and highlighted trends via conditional formatting.

## Visualizations
<img width="915" height="295" alt="image" src="https://github.com/user-attachments/assets/f789941a-36c4-4428-9cf9-68c30a0f6255" />


## Key Insights
* **Organic vs. Promo:** Organic users (`promo_signup_flag = 0`) demonstrate significantly higher and more stable retention rates than promo-driven users.
* **Benchmarks:** In the January organic cohort, ~33% of users remain active after several months, while promo-driven cohorts show a faster and unstable drop-off.
* **Top Cohorts:** The highest customer loyalty is concentrated in the January and April cohorts.
