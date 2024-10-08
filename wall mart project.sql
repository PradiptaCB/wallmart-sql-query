CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10 , 2 ) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6 , 4 ) NOT NULL,
    total DECIMAL(12 , 4 ) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10 , 2 ) NOT NULL,
    gross_margin_pct FLOAT(11 , 9 ),
    gross_income DECIMAL(12 , 4 ),
    rating FLOAT(2 , 1 )
);

-- Feature Engineering--


SELECT 
    time,
    (CASE
        WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_date
FROM
    sales;
    
    alter table sales add column time_of_day varchar(30);
    
UPDATE sales 
SET 
    time_of_day = (CASE
        WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END);
    
    
SELECT 
    date, DAYNAME(date) AS day_name
FROM
    sales;
    
    alter table 
    sales 
    add column 
    day_name varchar(20);
    
UPDATE sales 
SET 
    day_name = DAYNAME(date);
    
SELECT 
    date, MONTHNAME(date)
FROM
    sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales 
SET 
    month_name = MONTHNAME(date);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- GENERIC ------------------------------------------------------------------------------------------------------------------
--- How many unique cities does the data have? ------

SELECT 
distinct city 
from sales;

-- In which city is each branch? ----
SELECT DISTINCT
    branch
FROM
    sales;

SELECT DISTINCT
    city, branch
FROM
    sales;

---------------------------------------------- Product --------------------------------------------------------

-- How many unique product lines does the data have?
SELECT 
    COUNT(DISTINCT product_line)
FROM
    sales;

-- What is the most common payment method?
SELECT 
    COUNT(payment_method) AS cnt, payment_method
FROM
    sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most selling product line
SELECT 
    SUM(quantity) AS qty, product_line
FROM
    sales
GROUP BY product_line
ORDER BY qty DESC;

-- What is the total revenue by month
SELECT 
    month_name AS month, SUM(total) AS total_revenue
FROM
    sales
GROUP BY month_name
ORDER BY total_revenue;


-- What month had the largest COGS?
SELECT 
    month_name AS month, SUM(cogs) AS cogs
FROM
    sales
GROUP BY month_name
ORDER BY cogs;


-- What product line had the largest revenue?
SELECT 
    product_line, SUM(total) AS total_revenue
FROM
    sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT 
    branch, city, SUM(total) AS total_revenue
FROM
    sales
GROUP BY city , branch
ORDER BY total_revenue;


-- What product line had the largest VAT?
SELECT 
    product_line, AVG(tax_pct) AS avg_tax
FROM
    sales
GROUP BY product_line
ORDER BY avg_tax DESC;


-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
    AVG(quantity) AS avg_qnty
FROM
    sales;

SELECT 
    product_line,
    CASE
        WHEN AVG(quantity) > 5.5 THEN 'Good'
        ELSE 'Bad'
    END AS remark
FROM
    sales
GROUP BY product_line;


-- Which branch sold more products than average product sold?
SELECT 
    branch, SUM(quantity) AS qnty
FROM
    sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT 
        AVG(quantity)
    FROM
        sales);


-- What is the most common product line by gender
SELECT 
    gender, product_line, COUNT(gender) AS total_cnt
FROM
    sales
GROUP BY gender , product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line
SELECT 
    ROUND(AVG(rating), 2) AS avg_rating, product_line
FROM
    sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

SELECT DISTINCT
    customer_type
FROM
    sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT
    payment
FROM
    sales;


-- What is the most common customer type?
SELECT 
    customer_type, COUNT(*) AS count
FROM
    sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT 
    customer_type, COUNT(*)
FROM
    sales
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    sales
WHERE
    branch = 'C'
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

SELECT 
    time_of_day, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


SELECT 
    time_of_day, AVG(rating) AS avg_rating
FROM
    sales
WHERE
    branch = 'A'
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


SELECT 
    day_name, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY day_name
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



SELECT 
    day_name, COUNT(day_name) total_sales
FROM
    sales
WHERE
    branch = 'C'
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

SELECT 
    time_of_day, COUNT(*) AS total_sales
FROM
    sales
WHERE
    day_name = 'Sunday'
GROUP BY time_of_day
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

SELECT 
    customer_type, SUM(total) AS total_revenue
FROM
    sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT 
    city, ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM
    sales
GROUP BY city
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT 
    customer_type, AVG(tax_pct) AS total_tax
FROM
    sales
GROUP BY customer_type
ORDER BY total_tax;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------