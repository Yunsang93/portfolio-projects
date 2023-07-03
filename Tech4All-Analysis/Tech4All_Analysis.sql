-- Tech4All, Inc. is a global SaaS company offering solutions to customers globally. With a broad product portfolio spanning 12 different 
-- offerings, Tech4All enables customers to solve for business use cases and achieve operatonal efficiency and process optimization. In this 
-- project, I analyze a sample dataset of a dataset containing sales data for Tech4All to identify trends in sales, top performing products 
-- and regions, and customers. Based on these insights, I provide recommendations on where Tech4All can focus future efforts to optimize 
-- revenue growth and grow its business. 

-- Note: All data in this dataset is fictionalized.

-- Information about the data:
-- There are two tables of interest in this dataset: the orders and the customer_info tables. The orders table contains data about each order for 
-- Tech4All across each customer. The customer_info table contains information about each unique customer of Tech4All.

-- Let's first look at the orders table and take a look at the columns.
SELECT * FROM `mypersonalportfolio-1.SaaS_Sales.orders` LIMIT 1000;

-- Now, let's look at the customer_info table.
SELECT * FROM `mypersonalportfolio-1.SaaS_Sales.customer_info` LIMIT 1000;

-- It'll be good to join the customer_info table and the orders table as more information about the customers, such as the customer name 
-- and industry they operate in, would be nice to see for each order that the customer purchased.

-- There's a couple of key questions here that I want to understand. I'd really like to understand what the top customers are by sales. 
-- Understanding which products sell the most by sales is of interest here as well. 
-- Finally, understanding any geographical, industry, or segment performance differences here would really be insightful.

-- Let's join the customer_info and orders tables.
SELECT  o.*, 
        c.Customer,
        c.Industry 
FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
ON o.Customer_ID = c.ID;

-- There's three things I'd like to do with this combined table before diving into analysis: 1) Breaking out the date components from the 
-- Order_Date column into separate columns, 2) Checking and managing for any Null values in the columns. 3) Small change I'd like to make 
-- for Region is converting "APJ" to "APAC". 

-- Date columns
SELECT  o.ID, 
        o.Order_Date,
        EXTRACT(year FROM o.Order_Date) AS Year,
        EXTRACT(month FROM o.Order_Date) AS Month,
        EXTRACT(day FROM o.Order_Date) AS Day,
        o.Customer_Id, 
        o.Contact_Name,
        c.Customer,
        o.City,
        o.Region,
        o.Subregion,
        c.Industry,
        o.Segment,
        o.Product,
        o.Sales,
        o.Quantity,
        o.Discount,
        o.Profit 
FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
ON o.Customer_ID = c.ID;

-- Checking for null values
SELECT  SUM(CASE WHEN o.Id IS NULL THEN 1 ELSE 0 END) AS count_null_id,
        SUM(CASE WHEN o.Order_Date IS NULL THEN 1 ELSE 0 END) AS count_null_orderdate,
        SUM(CASE WHEN o.Customer_id IS NULL THEN 1 ELSE 0 END) AS count_null_customerid,
        SUM(CASE WHEN o.Contact_Name IS NULL THEN 1 ELSE 0 END) AS count_null_contactname,
        SUM(CASE WHEN o.Country IS NULL THEN 1 ELSE 0 END) AS count_null_country,
        SUM(CASE WHEN o.City IS NULL THEN 1 ELSE 0 END) AS count_null_city,
        SUM(CASE WHEN o.Region IS NULL THEN 1 ELSE 0 END) AS count_null_region,
        SUM(CASE WHEN o.Segment IS NULL THEN 1 ELSE 0 END) AS count_null_segment,
        SUM(CASE WHEN o.Product IS NULL THEN 1 ELSE 0 END) AS count_null_product,
        SUM(CASE WHEN o.License IS NULL THEN 1 ELSE 0 END) AS count_null_license,
        SUM(CASE WHEN o.Sales IS NULL THEN 1 ELSE 0 END) AS count_null_sales,
        SUM(CASE WHEN o.Quantity IS NULL THEN 1 ELSE 0 END) AS count_null_quantity
FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
ON o.Customer_ID = c.ID

-- Okay, let's start looking at the data and analyzing it. First, I want to understand the yearly trends of the dataset. 
--How has total sales grown over the years?
SELECT  EXTRACT(year FROM o.Order_Date) AS Year,
        ROUND(SUM(o.Sales), 2) AS total_sales,
FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
ON o.Customer_ID = c.ID
GROUP BY 1
ORDER BY 1;

-- Let's expand this a little bit and see what the percentage change was from the previous year.
WITH yearly_sales AS (
  SELECT    EXTRACT(year FROM o.Order_Date) AS Year,
            ROUND(SUM(o.Sales), 2) AS total_sales,
  FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
  JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
  ON o.Customer_ID = c.ID
  GROUP BY 1
  ORDER BY 1
)
SELECT  Year,
        total_sales,
        COALESCE(ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY Year)) / LAG(total_sales) OVER (ORDER BY Year)) * 100, 2), 0) 
        AS percentage_change
FROM yearly_sales
ORDER BY 1;

-- Tech4All's revenues declined in 2021 by 2.83% but grew in 2022 by 29.32%. Technology spending declined across many industries during the 
-- peak of COVID (late 2020 - early 2021) so this makes sense on paper, but I want to drill down into 2021 and 2022 and see what exactly 
-- contributed to these large percentage fluctuations.

-- Let's drill down into the regional breakdown first, with the same percentage change analysis from the yearly view in the previous query.
WITH regional_yearly_sales AS (
  SELECT    EXTRACT(year FROM o.Order_Date) AS Year,
            CASE 
            WHEN o.Region = 'APJ' THEN 'APAC'
            ELSE o.Region
            END AS Region,
            ROUND(SUM(o.Sales), 2) AS total_sales,
  FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
  JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
  ON o.Customer_ID = c.ID
  GROUP BY 1, 2
  ORDER BY 1, 3 DESC)
SELECT  Year,
        Region,
        total_sales,
        COALESCE(ROUND((total_sales - LAG(total_sales) OVER (PARTITION BY Region ORDER BY Year)) / LAG(total_sales) OVER (PARTITION BY Region 
        ORDER BY Year) * 100, 2), 0) AS regional_percentage_change
FROM regional_yearly_sales
ORDER BY 1, 3 DESC;

-- While AMER total sales grew in 2021 compared to 2020, APAC and EMEA total sales declined by 5.78 and 6.45% respectively. The performance of 
-- the APAC and EMEA regions in 2021 were big contributors to the overall 2.83% decline in sales in 2021 for Tech4All, Inc. In 2022, APAC and 
-- EMEA sales rebounded to strong performances. AMER continued to show stronger growth moving into 2022 and 2023.

-- Let's now drill down into the market segment breakdown and see the percentage change from previous years.
WITH segment_yearly_sales AS (
    SELECT  EXTRACT(year FROM o.Order_Date) AS Year,
            o.Segment,
            ROUND(SUM(o.Sales), 2) AS total_sales,
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  Year,
        Segment,
        total_sales,
        COALESCE(ROUND((total_sales - LAG(total_sales) OVER (PARTITION BY Segment ORDER BY Year)) / LAG(total_sales) OVER 
        (PARTITION BY Segment ORDER BY Year) * 100, 2), 0) AS segment_percentage_change
FROM segment_yearly_sales
ORDER BY 1, 3 DESC;

-- Enterprise Sales was a big contributor to the drop in sales in 2021 as this segment dropped by 16.14% from 2020 to 2021. SMB segments 
-- has shown consistent growth through the past 3 years. The Strategic segment showed significant growth in 2022 with a 60.72% increase in 
-- sales. In 2023, the Enterprise segment is growing significantly and is a segment to continue to monitor moving forward.

-- Finally, let's look at the industry breakdown by total yearly sales.
WITH industry_yearly_sales AS (
    SELECT  EXTRACT(year FROM o.Order_Date) AS Year,
            CASE
            WHEN c.Industry = 'Misc' THEN 'Miscellaneous'
            ELSE c.Industry END AS Industry,
            ROUND(SUM(o.Sales), 2) AS total_sales,
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  Year,
        Industry,
        total_sales,
        COALESCE(ROUND((total_sales - LAG(total_sales) OVER (PARTITION BY Industry ORDER BY Year)) / LAG(total_sales) OVER 
        (PARTITION BY Industry ORDER BY Year) * 100, 2), 0) AS industry_percentage_change
FROM industry_yearly_sales
ORDER BY 1, 3 DESC;

-- From 2020 to 2021, the Miscellaneous Industry showed the highest growth while Tech showed the largest decline in sales. Sales increased for 
-- many industries in 2022 with Manufacturing contributing the highest. In 2023, Tech is having the strongest year in sales followed by 
-- Healthcare, with a 81.82% and 44.67% increase in sales from 2022 respectively.

-- It would be good to also take a look at which quarters regions typically performed the strongest in terms of total sales. Let's take a look at how each region performed each quarter over the past 4 years.
-- AMER
WITH regional_quarterly_sales AS (
    SELECT    DATE_TRUNC(o.Order_Date, Quarter) AS Quarter,
              CASE
              WHEN o.Region = 'APJ' THEN 'APAC'
              ELSE o.Region END AS Region,
              ROUND(SUM(o.Sales), 2) AS total_sales,
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  Quarter,
        Region,
        total_sales,
        RANK() OVER (PARTITION BY EXTRACT(Year FROM Quarter) ORDER BY total_sales DESC) AS quarterly_rank
FROM regional_quarterly_sales
WHERE Region = 'AMER'
ORDER BY 1, 3 DESC;
-- Notably, Q4 was AMER's strongest quarter each year. 

-- APAC
WITH regional_quarterly_sales AS (
    SELECT    DATE_TRUNC(o.Order_Date, Quarter) AS Quarter,
              CASE 
              WHEN o.Region = 'APJ' THEN 'APAC'
              ELSE o.Region END AS Region,
              ROUND(SUM(o.Sales), 2) AS total_sales,
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  Quarter,
        Region,
        total_sales,
        RANK() OVER (PARTITION BY EXTRACT(Year FROM Quarter) ORDER BY total_sales DESC) AS quarterly_rank
FROM regional_quarterly_sales
WHERE Region = 'APAC'
ORDER BY 1, 3 DESC;

-- EMEA
WITH regional_quarterly_sales AS (
    SELECT    DATE_TRUNC(o.Order_Date, Quarter) AS Quarter,
              CASE 
              WHEN o.Region = 'APJ' THEN 'APAC'
              ELSE o.Region END AS Region,
              ROUND(SUM(o.Sales), 2) AS total_sales,
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  Quarter,
        Region,
        total_sales,
        RANK() OVER (PARTITION BY EXTRACT(Year FROM Quarter) ORDER BY total_sales DESC) AS quarterly_rank
FROM regional_quarterly_sales
WHERE Region = 'EMEA'
ORDER BY 1, 3 DESC;

-- This trend was consistent for all regions. Q4 was the strongest performing quarter - this should be a quarter that we should continue to emphasize as this quarter generates the company the highest total sales. 
--This is also consistent across all of our different market segments, with the exception of 2020 in the Enterprise Segment, where Q1 was actually the highest.
-- SMB
WITH segment_quarterly_sales AS (
    SELECT    DATE_TRUNC(o.Order_Date, Quarter) AS Quarter,
              o.Segment,
              ROUND(SUM(o.Sales), 2) AS total_sales,
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  Quarter,
        Segment,
        total_sales,
        RANK() OVER (PARTITION BY EXTRACT(Year FROM Quarter) ORDER BY total_sales DESC) AS quarterly_rank
FROM segment_quarterly_sales
WHERE Segment = 'SMB'
ORDER BY 1, 3 DESC;

-- Enterprise
WITH segment_quarterly_sales AS (
    SELECT    DATE_TRUNC(o.Order_Date, Quarter) AS Quarter,
              o.Segment,
              ROUND(SUM(o.Sales), 2) AS total_sales,
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  Quarter,
        Segment,
        total_sales,
        RANK() OVER (PARTITION BY EXTRACT(Year FROM Quarter) ORDER BY total_sales DESC) AS quarterly_rank
FROM segment_quarterly_sales
WHERE Segment = 'Enterprise'
ORDER BY 1, 3 DESC;

-- Strategic
WITH segment_quarterly_sales AS (
    SELECT    DATE_TRUNC(o.Order_Date, Quarter) AS Quarter,
              o.Segment,
              ROUND(SUM(o.Sales), 2) AS total_sales,
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  Quarter,
        Segment,
        total_sales,
        RANK() OVER (PARTITION BY EXTRACT(Year FROM Quarter) ORDER BY total_sales DESC) AS quarterly_rank
FROM segment_quarterly_sales
WHERE Segment = 'Strategic'
ORDER BY 1, 3 DESC;

-- Let's take a look at the lifetime total sales of our regions.
SELECT  CASE
        WHEN o.Region = 'APJ' THEN 'APAC'
        ELSE o.Region END AS Region,
        ROUND(SUM(o.Sales), 2) AS total_sales
FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
ON o.Customer_ID = c.ID
GROUP BY 1
ORDER BY 2 DESC;

-- Next, let's see the lifetime segment sales breakdown.
SELECT  o.Segment,
        ROUND(SUM(o.Sales), 2) AS total_sales
FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
ON o.Customer_ID = c.ID
GROUP BY 1
ORDER BY 2 DESC;

-- Let's look at how industries have performed overall by sales.
SELECT  CASE
        WHEN c.Industry = 'Misc' THEN 'Miscellaneous'
        ELSE c.Industry END AS Industry,
        ROUND(SUM(o.Sales), 2) AS total_sales
FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
ON o.Customer_ID = c.ID
GROUP BY 1
ORDER BY 2 DESC; 

-- Let's look at how much sales our products have generated overall.
SELECT  o.Product,
        ROUND(SUM(o.Sales), 2) AS total_sales
FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
ON o.Customer_ID = c.ID
GROUP BY 1
ORDER BY 2 DESC; 

-- Let's look at who the top 25 customers are by overall sales.
SELECT  c.Customer,
        ROUND(SUM(o.Sales), 2) AS total_sales
FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
ON o.Customer_ID = c.ID
GROUP BY 1
ORDER BY 2 DESC
LIMIT 25; 

-- Who are our top 5 customers in each industry by sales?
WITH rank_table AS (
    SELECT  c.Industry,
            c.Customer,
            ROUND(SUM(o.Sales), 2) AS total_sales,
            RANK() OVER (PARTITION BY c.Industry ORDER BY SUM(o.Sales) DESC) AS rank
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  CASE
        WHEN Industry = 'Misc' THEN 'Miscellaneous'
        ELSE Industry END AS Industry,
        Customer,
        total_sales,
        rank
FROM rank_table
WHERE rank BETWEEN 1 AND 5;

-- What about our top 5 customers in each region by sales?
WITH region_rank_table AS (
  SELECT  o.Region,
          c.Customer,
          ROUND(SUM(o.Sales), 2) AS total_sales,
          RANK() OVER (PARTITION BY o.Region ORDER BY SUM(o.Sales) DESC) AS rank
  FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
  JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
  ON o.Customer_ID = c.ID
  GROUP BY 1, 2
  ORDER BY 1, 3 DESC)
SELECT  CASE
          WHEN Region = 'APJ' THEN 'APAC'
          ELSE Region END AS Region,
        Customer,
        total_sales,
        rank
FROM region_rank_table
WHERE rank BETWEEN 1 AND 5;

-- Finally, who are our top 5 customers in each segment?
WITH seg_rank_table AS (
    SELECT  o.Segment,
            c.Customer,
            ROUND(SUM(o.Sales), 2) AS total_sales,
            RANK() OVER (PARTITION BY o.Segment ORDER BY SUM(o.Sales) DESC) AS rank
    FROM `mypersonalportfolio-1.SaaS_Sales.orders` o
    JOIN `mypersonalportfolio-1.SaaS_Sales.customer_info` c
    ON o.Customer_ID = c.ID
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC)
SELECT  Segment,
        Customer,
        total_sales,
        rank
FROM seg_rank_table
WHERE rank BETWEEN 1 AND 5;
