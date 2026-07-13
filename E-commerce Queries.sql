create database P3_ecommerce;
use p3_ecommerce;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(50),
    signup_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    category VARCHAR(50),
    price INT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    user_id INT,
    amount INT,
    txn_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ======================
-- INSERT DATA
-- ======================

-- USERS
INSERT INTO users VALUES
(1, 'Amit', '2023-01-10'),
(2, 'Neha', '2023-02-15'),
(3, 'Raj', '2023-03-20'),
(4, 'Simran', '2023-04-05'),
(5, 'Karan', '2023-05-12'),
(6, 'Rohit', '2023-06-01'),
(7, 'Sneha', '2023-06-10'),
(8, 'Arjun', '2023-07-15'),
(9, 'Meera', '2023-08-20'),
(10, 'Vikram', '2023-09-05');

-- PRODUCTS
INSERT INTO products VALUES
(101, 'Electronics', 500),
(102, 'Electronics', 800),
(103, 'Clothing', 120),
(104, 'Clothing', 200),
(105, 'Home', 300),
(106, 'Home', 450),
(107, 'Electronics', 1200),
(108, 'Electronics', 1500),
(109, 'Clothing', 250),
(110, 'Clothing', 350);

-- ORDERS
INSERT INTO orders VALUES
(1001, 1, '2024-01-01'),
(1002, 1, '2024-01-05'),
(1003, 2, '2024-01-03'),
(1004, 3, '2024-01-04'),
(1005, 2, '2024-01-10'),
(1006, 4, '2024-01-08'),
(1007, 5, '2024-01-09'),
(1008, 3, '2024-01-12'),
(1009, 6, '2024-01-02'),
(1010, 7, '2024-01-03'),
(1011, 8, '2024-01-04'),
(1012, 9, '2024-01-05'),
(1013, 10, '2024-01-06');

-- ORDER ITEMS
INSERT INTO order_items VALUES
(1, 1001, 101, 1, 500),
(2, 1001, 103, 2, 120),
(3, 1002, 102, 1, 800),
(4, 1003, 104, 3, 200),
(5, 1004, 105, 1, 300),
(6, 1005, 101, 2, 500),
(7, 1006, 106, 1, 450),
(8, 1007, 103, 4, 120),
(9, 1008, 104, 2, 200),
(10, 1009, 107, 1, 1200),
(11, 1010, 108, 1, 1500),
(12, 1011, 109, 3, 250),
(13, 1012, 110, 2, 350),
(14, 1013, 105, 1, 300);

-- TRANSACTIONS
INSERT INTO transactions VALUES
(1, 1, 740, '2024-01-01'),
(2, 1, 800, '2024-01-05'),
(3, 2, 600, '2024-01-03'),
(4, 3, 300, '2024-01-04'),
(5, 2, 1000, '2024-01-10'),
(6, 4, 450, '2024-01-08'),
(7, 5, 480, '2024-01-09'),
(8, 3, 400, '2024-01-12'),
(9, 6, 1200, '2024-01-02'),
(10, 7, 1500, '2024-01-03'),
(11, 8, 750, '2024-01-04'),
(12, 9, 700, '2024-01-05'),
(13, 10, 600, '2024-01-06'),
(14, 1, 500, '2024-01-02'),
(15, 1, 600, '2024-01-03'),
(16, 1, 700, '2024-01-04');


-- MODULE 1 ------------------------------------------------------------------------------------------------------------------


# Q1 - Total revenue per user

select o.user_id, sum(t.amount) as total_revenue
from orders o
join transactions t 
using (user_id)
group by 1;


# Q2 - Find all orders that contain more than 1 distinct product.

select DISTINCT order_id
from order_items
group by 1
having count(distinct order_id) > 1;


# Q3 - Return top 5 products by total quantity sold.

SELECT 
    oi.product_id, 
    SUM(oi.quantity) AS total_qty
FROM order_items oi
GROUP BY oi.product_id
ORDER BY total_qty DESC
LIMIT 5;


# Q4 - List users who have never placed an order.

select u.user_id, u.name
from users u
left join orders o
on u.user_id = o.user_id
where o.user_id is null;


# Q5 - Compute average order value across all orders.
 
select round(avg(avg_prod), 2) as average from
(
	select order_id, sum(quantity * price) as avg_prod
    from order_items
    group by 1
) as abc;


# Q6 - Calculate total revenue grouped by product category.

select p.category, sum(oi.quantity * oi.price) as revenue
from products p
join order_items oi
using (product_id)
group by 1;


# Q7 - Find orders where order value is greater than that user's average order value.

WITH OrderTotals AS (
    SELECT 
        o.user_id, 
        o.order_id, 
        SUM(oi.quantity * oi.price) AS order_value
    FROM orders o
    JOIN order_items oi USING (order_id)
    GROUP BY 1, 2
),

UserAverages AS (
    SELECT 
        user_id, 
        order_id, 
        order_value,
        AVG(order_value) OVER(PARTITION BY user_id) AS avg_per_user
    FROM OrderTotals
)

select user_id, order_id, order_value
from UserAverages
where order_value > avg_per_user;

# Q8 - Return the latest order for each user.

SELECT o.*
FROM orders o
JOIN (
    SELECT user_id, MAX(order_date) AS max_date
    FROM orders
    GROUP BY user_id
) t
ON o.user_id = t.user_id 
AND o.order_date = t.max_date;


# Q9 - Find products that were never purchased.

SELECT p.product_id
FROM products p
WHERE not EXISTS (
    SELECT 1 
    FROM order_items oi 
    WHERE p.product_id = oi.product_id
);


# Q10 - Find users who placed more than 1 order.

select user_id 
from orders
group by user_id
having count(user_id) > 1;


# Q11 - Return each user’s highest value order.

WITH OrderTotals AS (
    SELECT 
        o.user_id, 
        o.order_id, 
        SUM(oi.quantity * oi.price) AS order_total
    FROM order_items oi
    JOIN orders o USING (order_id)
    GROUP BY 1, 2
),
RankedOrders AS (
    SELECT 
        user_id, 
        order_id, 
        order_total,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_total DESC) AS rnk
    FROM OrderTotals
)

SELECT user_id, order_id, order_total
FROM RankedOrders
WHERE rnk = 1;


# Q12 - Compute total revenue per month.

select year(o.order_date), monthname(o.order_date), sum(oi.quantity * oi.price) as revenue
from orders o
join order_items oi
using (order_id)
group by 1,2;


# Q13 - Find orders that don’t have a corresponding transaction.

SELECT o.order_id
FROM orders o
LEFT JOIN transactions t 
    ON o.user_id = t.user_id 
    AND o.order_date = t.txn_date
WHERE t.txn_id IS NULL;


# Q14. User Spending Buckets

select o.user_id, 
case 
	when sum(oi.quantity*oi.price) > 10000 then 'High'
    when sum(oi.quantity*oi.price) between 1000 and 10000 then 'Medium'
    else 'Low'
end as bucket
from orders o
join order_items oi
using (order_id)
group by 1;


# Q15 - Return the single most purchased product (by quantity).

select product_id, sum(quantity) as qty
from order_items
group by 1
order by qty desc
limit 1;


-- MODULE 2 ------------------------------------------------------------------------------------------------------------------


# Q16 - For each user, find their first order month, then count how many users belong to each cohort.

WITH UserCohorts AS (
    SELECT user_id, MIN(DATE_FORMAT(order_date, '%Y-%M')) AS first_month
    FROM orders
    GROUP BY 1
)

SELECT first_month AS cohort, COUNT(user_id) AS users
FROM UserCohorts
GROUP BY first_month;


# Q17 - For each product: total unique buyers, number of users who bought it more than once.

WITH UserPurchases AS (
SELECT oi.product_id, o.user_id, COUNT(o.order_id) AS times_bought
    FROM order_items oi
    JOIN orders o 
    USING (order_id)
    GROUP BY 1,2
)

SELECT product_id, COUNT(user_id) AS total_unique_buyers,
SUM(CASE WHEN times_bought > 1 THEN 1 ELSE 0 END) AS repeat_buyers
FROM UserPurchases
GROUP BY product_id;


# Q18 - Find users who fall in the top 20% of total spend.

-- Step 1: Calculate total spend per user
WITH UserSpend AS (
    SELECT u.user_id, u.name, SUM(t.amount) AS total_spend
    FROM users u
    JOIN transactions t ON u.user_id = t.user_id
    GROUP BY u.user_id, u.name
),
-- Step 2: Assign row numbers using the variable
RankedUsers AS (
    SELECT *, (@row_num := @row_num + 1) AS rank_num
    FROM UserSpend
    CROSS JOIN (SELECT @row_num := 0) i
    ORDER BY total_spend DESC
)
-- Step 3: Filter for the top 20%
SELECT user_id, name, total_spend
FROM RankedUsers
WHERE rank_num <= (SELECT COUNT(*) * 0.20 FROM UserSpend);

WITH UserSpend AS (
    -- Phase 1: Get everyone's total spend
    SELECT u.user_id, u.name, SUM(t.amount) AS total_spend
    FROM users u
    JOIN transactions t ON u.user_id = t.user_id
    GROUP BY u.user_id, u.name
),

ManualRanking AS (
    -- Phase 2: The "How Many Beat Me?" Self-Join
    SELECT 
        u1.user_id, 
        u1.name, 
        u1.total_spend,
        -- If 0 people beat them, they are rank 1. 
        COUNT(u2.user_id) + 1 AS rank_num
    FROM UserSpend u1
    LEFT JOIN UserSpend u2 
        -- The Magic: Only join to people who spent strictly MORE
        ON u2.total_spend > u1.total_spend
    GROUP BY 
        u1.user_id, 
        u1.name, 
        u1.total_spend
)

-- Phase 3: The 20% Filter
SELECT 
    user_id, 
    name, 
    total_spend
FROM ManualRanking
WHERE rank_num <= (SELECT CEIL(COUNT(*) * 0.20) FROM UserSpend)
ORDER BY total_spend DESC;

# Q19 - Return users who have purchased from every product category.

select u.user_id, u.name
from users u
join orders o
on u.user_id = o.user_id
join order_items od
on o.order_id = od.order_id
join products p 
on od.product_id = p.product_id
group by 1,2
having COUNT(DISTINCT p.category) = (SELECT COUNT(DISTINCT category) FROM products);


# Q20 - Find the product with the highest quantity sold within each category.

-- Total quantity sold per product
WITH ProductTotals AS (
    SELECT product_id, SUM(quantity) AS total_quantity
    FROM order_items 
    GROUP BY product_id
),

 -- Attach the category to each product's total
ProductCategoryTotals AS (
    SELECT p.product_id, p.category, pt.total_quantity
    FROM ProductTotals pt
    JOIN products p ON pt.product_id = p.product_id
),

-- Find the absolute highest quantity for each category
MaxCategoryTotals AS (
    SELECT category, MAX(total_quantity) AS max_quantity
    FROM ProductCategoryTotals
    GROUP BY category
)

-- Join to find exactly which products hit that max quantity
SELECT pct.category, pct.product_id, pct.total_quantity
FROM ProductCategoryTotals pct
JOIN MaxCategoryTotals mct 
ON pct.category = mct.category 
AND pct.total_quantity = mct.max_quantity;
 
 
 # Q21 - Find users whose last 2 orders are lower than their previous ones.
 
 -- Get the total price for each order
WITH OrderTotals AS (
    SELECT 
        o.user_id, o.order_id, o.order_date, SUM(oi.quantity * oi.price) AS order_total
    FROM orders o
    JOIN order_items oi 
    ON o.order_id = oi.order_id
    GROUP BY 1,2,3
),

  -- Emulate ROW_NUMBER() by counting newer orders
RankedOrders AS (
    SELECT 
        ot1.user_id, ot1.order_id, ot1.order_total,
        (
            SELECT COUNT(*) + 1
            FROM OrderTotals ot2
            WHERE ot2.user_id = ot1.user_id
              AND (
                  ot2.order_date > ot1.order_date 
                  OR (ot2.order_date = ot1.order_date AND ot2.order_id > ot1.order_id)
              )
        ) AS order_rank
    FROM OrderTotals ot1
),

-- Create the strict High/Low buckets
TrendComparison AS (
    SELECT 
        user_id,
        MAX(CASE WHEN order_rank <= 2 THEN order_total END) AS max_recent_2,
        MIN(CASE WHEN order_rank >= 3 THEN order_total END) AS min_older
    FROM RankedOrders
    GROUP BY user_id
)

-- Compare the buckets and get the user names
SELECT u.name, t.user_id
FROM TrendComparison t
JOIN users u 
ON t.user_id = u.user_id
WHERE t.max_recent_2 < t.min_older;


# Q22 - Find orders where all products belong to the same category.

WITH col3 AS (
    SELECT oi.order_id, oi.product_id, p.category 
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
),

-- Find the order_ids that have mismatched categories
MixedOrders AS (
    SELECT DISTINCT c1.order_id
    FROM col3 c1
    JOIN col3 c2 ON c1.order_id = c2.order_id
    WHERE c1.category != c2.category
)
-- Select orders that did NOT get caught in the mixed-category trap
SELECT DISTINCT order_id, product_id, category
FROM col3 
WHERE order_id NOT IN (SELECT order_id FROM MixedOrders)
order by 1;

with col as (
SELECT oi.order_id
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY 1
HAVING COUNT(DISTINCT p.category) = 1)

select c.order_id, oi.product_id, p.category
from col c 
join order_items oi
on c.order_id = oi.order_id
join products p
on p.product_id = oi.product_id;


# Q23 - Find users who:
	-- placed at least 2 orders
	-- but haven’t ordered in the last X days (assume a max date)

SELECT user_id
FROM orders
GROUP BY user_id
HAVING COUNT(order_id) >= 2 
AND MAX(order_date) < DATE_SUB((SELECT MAX(order_date) FROM orders), INTERVAL 5 DAY);


# Q24 - Within each category, find the product contributing the most revenue %.

-- Calculate TOTAL revenue for each product
WITH ProductRevenues AS (
    SELECT p.category, p.product_id, SUM(oi.quantity * oi.price) AS prod_rev
    FROM order_items oi
    JOIN products p 
    ON oi.product_id = p.product_id
    GROUP BY 1,2
),

-- Find the winning revenue AND the total pool for the category
CategoryAggregates AS (
    SELECT 
        category,
        MAX(prod_rev) AS max_prod_rev,
        SUM(prod_rev) AS total_cat_rev
    FROM ProductRevenues
    GROUP BY 1
)

-- Match the winner and calculate the percentage
SELECT pr.category, pr.product_id,
    concat(round((pr.prod_rev / ca.total_cat_rev) * 100.0, 2), '%') AS revenue_percentage
FROM ProductRevenues pr
JOIN CategoryAggregates ca 
ON pr.category = ca.category AND pr.prod_rev = ca.max_prod_rev;


# Q25 - Find users whose max order value is not more than 2x their min order value

with ordervalues as (
select o.user_id, oi.order_id, sum(oi.quantity*oi.price) as ot
from orders o 
join order_items oi
on o.order_id = oi.order_id
group by 1,2
)

select user_id
from ordervalues
group by 1
having max(ot) <= (2* min(ot));

# Q26 - Find orders whose value is above the average order value of their category

with avgcat as (
select p.category, avg(oi.quantity*oi.price) as avgpercat
from products p
join order_items oi
on p.product_id = oi.product_id
group by 1
)

select oi.order_id
from order_items oi
join products p
on oi.product_id = p.product_id
join avgcat ac
on p.category = ac.category
where (oi.quantity*oi.price) > ac.avgpercat;

# Q27 - Most Recent Transaction Per User
-- Return full row (not just date)

with lattrans as (
select user_id, max(order_date) as lt
from orders
group by 1)

select o.user_id, o.order_id, o.order_date, oi.product_id, (oi.quantity * oi.price) as total_bill, p.category
from orders o 
join order_items oi
on o.order_id = oi.order_id
join products p
on oi.product_id = p.product_id
join lattrans latt
on latt.user_id = o.user_id and latt.lt = o.order_date
order by 1;


# Q28 - Find pairs of products that appear in the same order

select oi1.order_id, oi1.product_id, oi2.product_id
from order_items oi1
join order_items oi2
on oi1.order_id = oi2.order_id
where oi1.product_id < oi2.product_id;


# Q29 - Users who only ever bought one unique product

select o.user_id, count(distinct oi.product_id) dpid
from orders o
join order_items oi
on o.order_id = oi.order_id
group by 1
having dpid = 1;


# Q30 - Compute:
      -- total revenue
      -- revenue from repeat users only
      
WITH UserOrderCounts AS (
    -- Safely count how many distinct orders each user made
    SELECT 
        user_id, 
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY user_id
)

-- Calculate both metrics side-by-side
SELECT 
    -- Total Revenue
    SUM(oi.quantity * oi.price) AS total_revenue,
    
    -- Repeat Revenue
    SUM(CASE WHEN uoc.total_orders > 1 THEN (oi.quantity * oi.price) ELSE 0 END) AS repeat_user_revenue
    
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
JOIN UserOrderCounts uoc 
ON o.user_id = uoc.user_id;