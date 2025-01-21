# Taking a look at all fields and records and pinning the tab
select * from superstore;

# Total sales by region
SELECT region, ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;

# Top 5 products by sales
SELECT product_name, ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 5;

# Profitability by category
SELECT category, ROUND(SUM(profit),2) AS total_profit, 
ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percentage
FROM superstore
GROUP BY category
ORDER BY profit_margin_percentage DESC;

#Monthly sales trend
SELECT DATE_FORMAT(STR_TO_DATE(order_date, '%d/%m/%Y'), '%Y-%m') AS order_month,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY order_month
ORDER BY order_month;

# Segments sales and profit
SELECT segment, ROUND(SUM(sales),2) AS total_sales, 
    ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY segment
ORDER BY total_sales DESC;

# Average disocunt by subcategory
SELECT subcategory, AVG(discount) AS avg_discount
FROM superstore
GROUP BY subcategory
ORDER BY avg_discount DESC;

# High and low performing cities
-- Top 3 Cities
SELECT city, ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY city
ORDER BY total_profit DESC
LIMIT 3;
-- Bottom 3 Cities
SELECT city, ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY city
ORDER BY total_profit ASC
LIMIT 3;

# Contribution of each delivery mode to total sales
SELECT delivery_mode, 
    ROUND(SUM(sales),2) AS total_sales, 
    ROUND(SUM(sales),2) / (SELECT  ROUND(SUM(sales),2) FROM superstore) * 100 AS contribution_percentage
FROM superstore
GROUP BY delivery_mode
ORDER BY contribution_percentage DESC;

# Running total of sales by region over time
SELECT region, 
    DATE_FORMAT(STR_TO_DATE(order_date, '%d/%m/%Y'), '%Y-%m-%d') AS order_date,
    ROUND(SUM(sales), 2) AS daily_sales,
    ROUND(SUM(SUM(sales)) OVER (PARTITION BY region ORDER BY STR_TO_DATE(order_date, '%d/%m/%Y')), 2) AS running_total_sales
FROM superstore
GROUP BY region, order_date
ORDER BY region, STR_TO_DATE(order_date, '%d/%m/%Y');

# Sales performance vs Discount analysis
SELECT 
	CASE WHEN discount > 0 THEN 'Discounted Sales' 
        ELSE 'Non-Discounted Sales' 
    END AS discount_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(profit / sales) * 100, 2) AS avg_profit_margin
FROM superstore
WHERE sales > 0
GROUP BY discount_category;

# Customer retention analysis
WITH yearly_customers AS (
    SELECT customer_id, YEAR(STR_TO_DATE(order_date, '%d/%m/%Y')) AS order_year
    FROM superstore
    GROUP BY customer_id, YEAR(STR_TO_DATE(order_date, '%d/%m/%Y'))
),
consecutive_years AS (
    SELECT c1.customer_id
    FROM yearly_customers c1
    INNER JOIN 
        yearly_customers c2 
        ON c1.customer_id = c2.customer_id 
        AND c1.order_year = c2.order_year - 1
)
SELECT COUNT(DISTINCT customer_id) AS retained_customers
FROM consecutive_years;









