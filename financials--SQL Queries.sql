 CREATE TABLE FINANCIALS 
		(Segment VARCHAR(20),
		Country VARCHAR(30),
		Product VARCHAR(20),
		Discount_Band VARCHAR(10),
		Units_Sold FLOAT,
		Manufacturing_Price FLOAT,
		Sale_Price FLOAT,
		Gross_Sales FLOAT,
		Discounts FLOAT,
		Sales FLOAT,
		COGS FLOAT,
		Profit FLOAT,
		Date DATE,
		Month_Number INT,
		Month_Name VARCHAR(20),
		Year INT)


---basic queries
---Q1: Count the total number of records in the dataset.

SELECT COUNT(*)
FROM FINANCIALS

---Q2: Find the total sales amount for the entire dataset.

SELECT SUM(SALES) AS TOTAL_SALES
FROM FINANCIALS

---Q3: List all unique products in the dataset.

SELECT DISTINCT(PRODUCT)
FROM FINANCIALS

---Q4: Find the total profit generated per country.

SELECT COUNTRY, SUM(SALES) AS TOTAL_PROFIT
FROM FINANCIALS
GROUP BY COUNTRY

---Q4: Get the total revenue for each segment.

SELECT SEGMENT, SUM(SALES) AS TOTAL_REVENUE
FROM FINANCIALS
GROUP BY 1

---Q5: Find the Top 3 Products by Sales in Each Segment

SELECT SEGMENT, PRODUCT, SALES,
	   ROW_NUMBER() OVER (PARTITION BY SEGMENT ORDER BY SALES DESC) AS RANK
FROM FINANCIALS
ORDER BY 1, 4

--intermediate queries
---Q7: Calculate the average profit margin for each country.

SELECT 
    COUNTRY, 
    ROUND(CAST(AVG(PROFIT / SALES) * 100 AS NUMERIC), 2) AS AVG_PROFIT_MARGIN
FROM 
    FINANCIALS
WHERE 
    SALES > 0
GROUP BY 
    COUNTRY;

---Q8: Find the month with the highest total sales.

SELECT MONTH_NAME, SUM(SALES) AS TOTAL_SALES 
FROM FINANCIALS 
GROUP BY 1 
ORDER BY 2 DESC 
LIMIT 1;

---Q9: Get the cumulative revenue by month (year-wise).

WITH SALES_PER_MONTH AS(
			SELECT YEAR, MONTH_NUMBER, MONTH_NAME, SUM(SALES) AS MONTHLY_SALES
			FROM FINANCIALS
			GROUP BY 1, 2, 3
			ORDER BY 2
               		   )
SELECT *, SUM(MONTHLY_SALES) OVER (PARTITION BY YEAR ORDER BY MONTH_NUMBER) AS CUMULATIVE_REVENUE
FROM SALES_PER_MONTH

---Q10:  Find the top 3 most profitable countries.

SELECT COUNTRY, SUM(PROFIT) AS TOTAL_PROFIT
FROM FINANCIALS
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3

---Q11: Find the revenue difference between consecutive months.

SELECT 
    YEAR, 
    MONTH_NAME, 
    SUM(SALES) AS MONTHLY_SALES,
    LAG(SUM(SALES)) OVER (PARTITION BY YEAR ORDER BY MONTH_NUMBER) AS PREV_MONTH_SALES,
    (SUM(SALES) - LAG(SUM(SALES)) OVER (PARTITION BY YEAR ORDER BY MONTH_NUMBER)) AS REVENUE_CHANGE
FROM FINANCIALS
GROUP BY YEAR, MONTH_NAME, MONTH_NUMBER
ORDER BY YEAR, MONTH_NUMBER;

--- advance queries

---Q12: Identify the segment that had the highest revenue growth between two years.

SELECT SEGMENT, 
       SUM(CASE WHEN Year = 2013 THEN SALES ELSE 0 END) AS SALES_2013, 
       SUM(CASE WHEN Year = 2014 THEN SALES ELSE 0 END) AS SALES_2014,
       (SUM(CASE WHEN Year = 2014 THEN SALES ELSE 0 END) - SUM(CASE WHEN Year = 2013 THEN SALES ELSE 0 END)) AS REVENUE_GROWTH
FROM FINANCIALS 
GROUP BY SEGMENT 
ORDER BY REVENUE_GROWTH DESC 
LIMIT 1;

---Q13: Create a ranking of products based on profit within each country.

SELECT COUNTRY, PRODUCT, SUM(PROFIT) AS TOTAL_PROFIT,
	   RANK() OVER (PARTITION BY COUNTRY ORDER BY SUM(PROFIT) DESC) AS RANK
FROM FINANCIALS
GROUP BY 1, 2

---Q14:  Find the moving average of sales over a 3-month window.

SELECT Year, Month_Name, Sales, 
       AVG(Sales) OVER (PARTITION BY Year ORDER BY Month_Number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Moving_Avg
FROM financials;

---Q15: Identify anomalies where profit margin is significantly lower than the average.

SELECT *, (PROFIT/SALES) * 100 AS PROFIT_MARGIN
FROM FINANCIALS
WHERE (PROFIT/SALES) * 100 <
	(SELECT AVG((PROFIT/SALES) * 100)
	FROM FINANCIALS)

---Q16: Identify the Most and Least Profitable Product in Each Country

SELECT DISTINCT COUNTRY,
       FIRST_VALUE(PRODUCT) OVER (PARTITION BY COUNTRY ORDER BY PROFIT DESC) AS MOST_PROFITABLE_PRODUCT,
       LAST_VALUE(PRODUCT) OVER (PARTITION BY COUNTRY ORDER BY PROFIT DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LEAST_PROFITABLE_PRODUCT
FROM FINANCIALS;



SELECT *
FROM FINANCIALS

---- END PROJECT ----