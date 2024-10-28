/* --------------------
   Case Study 1 (Danny's Diner)
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT
    s.customer_id,
    SUM(m.price) AS total_spent
FROM
    dannys_diner.sales AS s
JOIN
    dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY
    s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS visit_days
FROM
    sales
GROUP BY
    customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH FirstPurchases AS (
    SELECT
        s.customer_id,
        s.order_date,
        s.product_id,
        m.product_name,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date, s.product_id) AS purchase_rank
    FROM
        sales AS s
    JOIN
        menu AS m ON s.product_id = m.product_id
)

SELECT
    customer_id,
    product_name AS first_item
FROM
    FirstPurchases
WHERE
    purchase_rank = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
    m.product_name,
    COUNT(s.product_id) AS purchase_count
FROM
    sales s
JOIN
    menu m ON s.product_id = m.product_id
GROUP BY
    m.product_name
ORDER BY
    purchase_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH Favourites AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(s.product_id) AS purchase_count,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id 
            ORDER BY COUNT(s.product_id) DESC, m.product_name ASC
        ) AS rank
    FROM
        sales s
    JOIN
        menu m ON s.product_id = m.product_id
    GROUP BY
        s.customer_id, m.product_name
)
SELECT
    customer_id,
    product_name AS most_popular_item
FROM
    Favourites
WHERE
    rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH FirstPurchases AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id 
            ORDER BY s.order_date
        ) AS purchase_rank
    FROM
        sales s
    JOIN
        members mem ON s.customer_id = mem.customer_id
    JOIN
        menu m ON s.product_id = m.product_id
    WHERE
        s.order_date >= mem.join_date  -- Ensure purchase is after joining
)

SELECT
    customer_id,
    product_name AS first_item_after_join
FROM
    FirstPurchases
WHERE
    purchase_rank = 1;  -- Get only the first purchase

-- 7. Which item was purchased just before the customer became a member?

WITH LastPurchases AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id 
            ORDER BY s.order_date DESC  -- Order by date in descending order
        ) AS purchase_rank
    FROM
        sales s
    JOIN
        members mem ON s.customer_id = mem.customer_id
    JOIN
        menu m ON s.product_id = m.product_id
    WHERE
        s.order_date < mem.join_date  -- Ensure purchase is before joining 
)

SELECT
    customer_id,
    product_name AS last_item_before_join  -- Update alias to reflect the correct meaning
FROM
    LastPurchases
WHERE
    purchase_rank = 1;  -- Get only the last purchase before joining


 --What is the total items and amount spent for each member before they became a member?

 SELECT
    s.customer_id,
    COUNT(s.product_id) AS total_items,                     -- Count of items purchased
    SUM(m.price) AS total_amount_spent                      -- Total amount spent
FROM
    sales s
JOIN
    members mem ON s.customer_id = mem.customer_id
JOIN
    menu m ON s.product_id = m.product_id
WHERE
    s.order_date < mem.join_date  -- Ensure purchase is before joining 
GROUP BY
    s.customer_id;                  -- Group by customer ID



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH CustomerPoints AS (
    SELECT
        s.customer_id,
        SUM(m.price) AS total_amount_spent,
        SUM(CASE WHEN m.product_name = 'sushi' THEN m.price * 2 ELSE m.price END) AS total_amount_with_multiplier
    FROM
        sales s
    JOIN
        menu m ON s.product_id = m.product_id
    GROUP BY
        s.customer_id
)

SELECT
    customer_id,
    (total_amount_spent * 10) + (total_amount_with_multiplier * 10) AS total_points
FROM
    CustomerPoints;




