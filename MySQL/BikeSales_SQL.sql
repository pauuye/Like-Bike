-- Like Bike Store

SELECT *
FROM sales;

SELECT *
FROM sales1;

use bikestore;

-- Determining if there is a duplicate input/data by using Window Function ROW_Number and CTE
WITH dupli as (
	SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
	Customer_Gender, Country, State, Product_Category, Sub_Category, 
	Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue) as n_row
FROM sales)
SELECT 
	*
FROM dupli
WHERE n_row > 1;

-- Creating another table similar to the raw data file 'sales' and inserting another column for the Row_Number. 
-- For deleting the duplicates and preserving the raw data file.
CREATE TABLE `sales1` (
  `Date` date,
  `Day` int DEFAULT NULL,
  `Month` text,
  `Year` int DEFAULT NULL,
  `Customer_Age` int DEFAULT NULL,
  `Age_Group` text,
  `Customer_Gender` text,
  `Country` text,
  `State` text,
  `Product_Category` text,
  `Sub_Category` text,
  `Product` text,
  `Order_Quantity` int DEFAULT NULL,
  `Unit_Cost` int DEFAULT NULL,
  `Unit_Price` int DEFAULT NULL,
  `Profit` int DEFAULT NULL,
  `Cost` int DEFAULT NULL,
  `Revenue` int DEFAULT NULL,
  `n_row` INT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting the data from 'sales' to 'sales1' + ROW_Number

INSERT INTO sales1
SELECT 
	*, 
	ROW_NUMBER() OVER(PARTITION BY `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
	Customer_Gender, Country, State, Product_Category, Sub_Category, 
	Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue) as n_row
FROM sales;

-- Double checking if the insertion is accurate
-- Then deleting the duplicates.
-- Drop the column 'n_row' after the deletion process
SELECT *
FROM sales1
WHERE n_row >1;

DELETE
FROM sales1
WHERE n_row > 1;

-- DELETED THE RECORDS WITH THE YEAR 2014-2016 AS THE RECORDS OF THIS YEARS ARE INCOMPLETE ONLY 6 MONTHS
DELETE
FROM sales1
WHERE YEAR(`Date`) = 2014
OR YEAR(`Date`) = 2015
OR YEAR(`Date`) = 2016;

-- Exploratory Data Analysis

DESCRIBE sales1;

-- Determining the number of customer per age group
SELECT 
	Age_Group, 
	COUNT(*) as age_Count
FROM sales1
GROUP by Age_Group
ORDER BY age_count DESC;

-- Determining the top 3 Country that generates the highest average revenue by Year

WITH avg_rev_D as(
	SELECT 
		`Year`, 
		Country, ROUND(AVG(Revenue),2) as avg_rev
	FROM sales1
	WHERE Order_Quantity IS NOT NULL
	GROUP BY `Year`, Country
)
	SELECT 
		`Year`, 
		Country, 
		avg_rev
	FROM (
		SELECT
			`Year`, 
			Country, 
			avg_rev,
			DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY avg_rev DESC) as c_rank
		FROM avg_rev_D
    ) t
    WHERE c_rank <= 3;

-- Profitable Categories
-- Bicycle category is the flagship product of the store. 77.35% of the total profit from the sold bikes. 
WITH t_profits AS (
	SELECT 
		 Product_Category as Category, 
		 SUM(Profit) as TotalProfit
	FROM sales1
	GROUP BY Product_Category
)
	SELECT
		Category,
        TotalProfit,
        CONCAT(ROUND(TotalProfit/SUM(TotalProfit) OVER() * 100, 2), '%') as Distribution_Percent
	FROM t_profits
    ORDER BY TotalProfit DESC;
    
-- Top 10 Sub_Categories products by Average Revenue
SELECT 
	Sub_Category, 
    ROUND(AVG(Revenue),2) as Avg_rev
FROM sales1
GROUP BY Sub_Category
ORDER BY Avg_rev DESC
LIMIT 10;

-- Most Profitable Products and Sub-Products(top5) by Year
-- Profitable Products by Year(2011-2013)
-- 2011-2012 The stores only product in sale is Bicycles, they expand their business and introduced Accessories and Clothings
WITH t_prof1 as (
	SELECT 
		`Year`, 
		Product_Category, 
        SUM(Profit) as total_profit
	FROM sales1
	GROUP BY `Year`, Product_Category
)
SELECT
	`Year`,
	Product_Category, 
    total_profit,
    CONCAT(ROUND(total_profit/total_profit_years * 100, 2), '%') as ProfitDistribution
FROM (
	SELECT 
		`Year`,
		Product_Category, 
		total_profit,
		DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY total_profit DESC) as t_profit_rank,
		SUM(total_profit) OVER(PARTITION BY `Year`) as total_profit_years
	FROM t_prof1
) t;



-- Top 10 Profitable Sub-Products  by Year(2011-2013)
-- Road Bikes, Mountain Bikes are the two best seller type of Bikes in the store 
WITH t_prof2 as (
	SELECT 
		`Year`, 
		Sub_Category, 
		SUM(Profit) as sum_profit
	FROM sales1
GROUP BY `Year`, Sub_Category
),
ranked as (
	SELECT 
		`Year`,
		Sub_Category, 
		sum_profit,
		DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY sum_profit DESC) as t_profit1_rank
	FROM t_prof2
)
SELECT 
	`Year`, 
    Sub_Category, 
    sum_profit, 
    t_profit1_rank
FROM ranked
WHERE t_profit1_rank <= 10
ORDER BY `Year`, t_profit1_rank ASC;


-- Monthly Revenue RT
WITH monthly AS(
	SELECT 
		`Year`, 
		MONTH(`Date`) AS month_num, -- For the months to be successive (January .... December) If only `Months` it will order by alphabetical
		`Month`, 
		SUM(Revenue) AS monthly_revenue
		FROM sales1
	GROUP BY `Year`, month_num, `Month`
)
SELECT
	`Year`,
    `Month`,
    monthly_revenue,
    RevenueRT,
    CONCAT(ROUND(RevenueRT / TotalRev * 100, 2), '%') as RunningPercentage
FROM (
	SELECT 
		`Year`,
		`Month`,
		monthly_revenue,
		SUM(monthly_revenue) OVER (PARTITION BY `Year` ORDER BY month_num) AS RevenueRT,
		SUM(monthly_revenue) OVER(PARTITION BY `Year`) as TotalRev
	FROM monthly
	ORDER BY `Year`, month_num
) t;

-- Average Order Quantity per Country
SELECT 
    Country,
    ROUND(AVG(Order_Quantity), 1) AS avg_order_qty
FROM sales1
GROUP BY Country
ORDER BY 2 DESC;


-- Average Order Quantity per Sub_Category
SELECT 
    Sub_Category, 
    ROUND(AVG(Order_Quantity), 1) AS avg_order
FROM sales1
GROUP BY Sub_Category
ORDER BY 2 DESC;

-- Group Age average order
SELECT 
    Age_Group, 
    ROUND(AVG(Order_Quantity), 1) AS AVG_order
FROM sales1
GROUP BY Age_Group
ORDER BY 2 DESC;











