use walmart_db;
select * from walmart;
select count(*) from walmart;

-- Business Problem
-- 1.Find diffểnt payment method and number of transactions, number of quantity sold
select payment_method, count(*) as transations, sum(quantity) as quantity_sold
from walmart
group by payment_method;

 -- 2.Identify the highest-rated category in each branch, displaying the branch, category 
 -- AVG RATING
SELECT 
    branch,
    category,
    avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE rnk = 1;

-- 3.Identỳy the busiest day for each branch based on the number of transations
SELECT branch, weekday_name AS busiest_day, total_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS weekday_name,
        COUNT(*) AS total_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, DAYNAME(STR_TO_DATE(date, '%d/%m/%y'))
) AS ranked
WHERE rnk = 1;

-- 4.Calculate the total quantity of items sold per payment method. List payment_method and total_quantity
select payment_method, sum(quantity) as total_quantity
from Walmart
group by payment_method;

-- 5.Determine the average, minimum, maximun rating of category for each city. List the city, average_rating, min_rating, max_rating
select city, category, avg(rating) as avg_rating, min(rating) as min_rating, max(rating) as max_rating
from Walmart
group by 1, 2;

-- 6.Caculate the total profit fot each category by cosidering total_profit as (unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit
select category, sum(total) as total_revenue, sum(total * profit_margin) as profit
from Walmart
group by 1;

-- 7.Determine the most common payment method for each branch. Display branch and the preferred_payment_method
select * 
from
(
select branch, payment_method, count(*) as total_trans, rank() over(partition by branch order by count(*) desc) as rnk
from Walmart
group by 1,2
) as ranked
where rnk = 1;

-- 8.Categorize sales into 3 group MORNING, AFTERNOON, EVENING. Find out each of the shift and number of invoices
select branch, shift, COUNT(*) AS invoice_count
from (
    select 
        branch,
        case 
            WHEN TIME(time) BETWEEN '05:00:00' AND '11:59:59' THEN 'MORNING'
            WHEN TIME(time) BETWEEN '12:00:00' AND '17:59:59' THEN 'AFTERNOON'
            WHEN TIME(time) BETWEEN '18:00:00' AND '22:59:59' THEN 'EVENING'
            ELSE 'OTHER'
        end as shift
    from Walmart
) as shifts
group by 1, 2
order by 1, 2;

-- 9.Identify 5 branch with highest decrese ratio in revenue compare to last year (current year 2023 and last year 2022)
with yearly_revenue as (
    select branch, YEAR(STR_TO_DATE(date, '%d/%m/%y')) AS year, SUM(total) AS revenue
    from Walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) IN (2022, 2023)
    GROUP BY branch, YEAR(STR_TO_DATE(date, '%d/%m/%y'))
),
pivoted AS (
    SELECT 
        branch,
        MAX(CASE WHEN year = 2022 THEN revenue END) AS revenue_2022,
        MAX(CASE WHEN year = 2023 THEN revenue END) AS revenue_2023
    FROM yearly_revenue
    GROUP BY branch
),
final AS (
    SELECT 
        branch,
        revenue_2022,
        revenue_2023,
        ROUND((revenue_2022 - revenue_2023) / revenue_2022, 2) AS decrease_ratio
    FROM pivoted
    WHERE revenue_2022 IS NOT NULL AND revenue_2023 IS NOT NULL
        AND revenue_2022 > revenue_2023
)
SELECT *
FROM final
ORDER BY decrease_ratio DESC
LIMIT 5;



