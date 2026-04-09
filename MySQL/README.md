# Like Bike Sales SQL Data Cleaning & Analysis

## Overview
This SQL script performs data cleaning, transformation, and exploratory data analysis (EDA) on a bike sales dataset.

## Key Steps

### 1. Duplicate Handling
- Identified duplicates using ROW_NUMBER() with a window function
- Created a new table `sales1` to preserve raw data
- Deleted duplicate records where `n_row > 1`

### 2. Data Cleaning
- Removed incomplete records from years 2014–2016 (only 6 months of data available)
- Ensured dataset consistency for analysis

### 3. Feature Engineering
- Recalculated key metrics:
  - Revenue
  - Cost
  - Profit

### 4. Exploratory Data Analysis

#### Customer Insights
- Customer distribution by age group
- Average order quantity by:
  - Country
  - Sub-category
  - Age group

#### Revenue Analysis
- Top 3 countries by average revenue per year
- Monthly revenue with running totals

#### Product Performance
- Profit distribution by category
- Top sub-categories by average revenue
- Most profitable categories and sub-categories by year

## Key Insights
- Bicycles dominate profit contribution (~77%)
- Road Bikes and Mountain Bikes are top-performing sub-categories
- Expansion into accessories and clothing started after early years

## Tools Used
- MySQL
- Window Functions
- CTEs (Common Table Expressions)
