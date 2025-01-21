# Sales Analysis of a Supermarket Chain with Recommendations

Sources is Tableau file Sample - Superstore Sales, which offers interesting business insights and visualization opportunities.
This mini project wants to showcase *SQL querying* and *Tableau visualization*.

![image](https://github.com/user-attachments/assets/444deaa9-7d91-43c7-b3fe-9b7d90993df7)
 
![image](https://github.com/user-attachments/assets/3a2dc070-04e4-404b-827f-f5adff167e41)

First of all, I want to take a quick look at fields and records and to count total number of lines.

![image](https://github.com/user-attachments/assets/d8f12503-5ddb-4047-991f-5540959d9544)

### 1) Total sales by region

```sql -- Add 3 backticks followed by sql
SELECT region, ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;
```

Central region is by far the most profitable; I order the results in descending order.

![image](https://github.com/user-attachments/assets/00e2e49a-ec11-4abb-9332-5dcc90130a35)

### 2) Top products by sales

```sql -- Add 3 backticks followed by sql
SELECT product_name, ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 5;
```

The 5 most sold products? As I will do all the time in this file, I round the digits after zero to two.

![image](https://github.com/user-attachments/assets/74a5c9c6-8357-41be-9e42-6df9c484f03f)

### 3) Profitability by category

```sql -- Add 3 backticks followed by sql
SELECT category, ROUND(SUM(profit),2) AS total_profit, 
ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percentage
FROM superstore
GROUP BY category
ORDER BY profit_margin_percentage DESC;
```

Here I showcase total profit and *profit margin percentage*, which is a calculated metric that represents the percentage of profit relative to sales for each category.

This shows how much profit is made for every dollar (or unit of currency) of sales, expressed as a percentage.

![image](https://github.com/user-attachments/assets/79335a6f-b566-402e-b14d-321bbbaa2d38)

### 4) Monthly sales trend

```sql -- Add 3 backticks followed by sql
SELECT DATE_FORMAT(STR_TO_DATE(order_date, '%d/%m/%Y'), '%Y-%m') AS order_month,
ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY order_month
ORDER BY order_month;
```
I want to look at a detailed trend of sales over time: I should first isolate month and year, then I simply sum sales.
Here I showcase the first results.

![image](https://github.com/user-attachments/assets/28cac190-43ea-4048-8a32-d7cbac728c44)


### 5) Segments' sales and profits

```sql -- Add 3 backticks followed by sql
SELECT subcategory, AVG(discount) AS avg_discount
FROM superstore
GROUP BY subcategory
ORDER BY avg_discount DESC;
```

![image](https://github.com/user-attachments/assets/821392a4-efa3-4ff3-a834-d40a8509bfdf)

### 6) High and low performing cities

```sql -- Add 3 backticks followed by sql
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
```
![image](https://github.com/user-attachments/assets/0b1df71b-eaa0-4b15-854d-be0f2843dddb)

![image](https://github.com/user-attachments/assets/7c1594a9-2ab7-421c-8641-0403da295ac8)

### 7) Contribution of each delivery mode to total number of sales

```sql -- Add 3 backticks followed by sql
SELECT delivery_mode, 
    ROUND(SUM(sales), 2) AS total_sales, 
    ROUND(ROUND(SUM(sales), 2) / (SELECT ROUND(SUM(sales), 2) FROM superstore) * 100, 2) AS contribution_percentage
FROM superstore
GROUP BY delivery_mode
ORDER BY contribution_percentage DESC;
```
This query determines the contribution of each delivery mode to the overall sales, both as a total value (total_sales) and as a percentage (contribution_percentage).
Standard Class counts more than half the total number of sales.
![image](https://github.com/user-attachments/assets/5996afe7-95fb-422f-8e06-9befdb27838b)

### 8) Running total of sales by region over time

```sql -- Add 3 backticks followed by sql
SELECT region, 
    DATE_FORMAT(STR_TO_DATE(order_date, '%d/%m/%Y'), '%Y-%m-%d') AS order_date,
    ROUND(SUM(sales), 2) AS daily_sales,
    ROUND(SUM(SUM(sales)) OVER (PARTITION BY region ORDER BY STR_TO_DATE(order_date, '%d/%m/%Y')), 2) AS running_total_sales
FROM superstore
GROUP BY region, order_date
ORDER BY region, STR_TO_DATE(order_date, '%d/%m/%Y');
```
I calculate total sales for each region on specific dates; then I track cumulative sales progression over time for each region.
Finally I ensure that both the daily sales and running totals are aligned by date, making trends over time easy to analyze.

![image](https://github.com/user-attachments/assets/6b964309-fad6-43cf-913b-aa580653659c)

### 9) Sales performances vs Discount analysis

```sql -- Add 3 backticks followed by sql
SELECT 
	CASE WHEN discount > 0 THEN 'Discounted Sales' 
        ELSE 'Non-Discounted Sales' 
    END AS discount_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(profit / sales) * 100, 2) AS avg_profit_margin
FROM superstore
WHERE sales > 0
GROUP BY discount_category;
```
Interestingly enough, while discounts may boost sales volume for the discounted category, the losses incurred outweigh the benefits.

**Potential Actions to Take:**
*Review Discount Strategy:* Reassess the discounting policy to ensure it is not set too aggressively, resulting in substantial losses.
*Identify Discount Thresholds:* Evaluate which discounts are sustainable and adjust the percentage or frequency of discounts accordingly.
*Segment Customers:* Determine if discounted sales are targeting the right customer segments or if they are cannibalizing profits from customers willing to pay full price.
*Analyze Cost Structure:* Examine the cost of goods sold and operational costs to identify ways to reduce expenses for discounted sales.

![image](https://github.com/user-attachments/assets/378e195b-28b4-4e7b-97ca-e3c81cef8737)

### 10) Customer retention analysis

```sql -- Add 3 backticks followed by sql
WITH yearly_customers AS (
    SELECT 
        customer_id, 
        YEAR(STR_TO_DATE(order_date, '%d/%m/%Y')) AS order_year
    FROM superstore
    GROUP BY customer_id, YEAR(STR_TO_DATE(order_date, '%d/%m/%Y'))
),
consecutive_years AS (
    SELECT 
        c1.customer_id
    FROM yearly_customers c1
    INNER JOIN yearly_customers c2 
        ON c1.customer_id = c2.customer_id 
        AND c1.order_year = c2.order_year - 1
),
total_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers
    FROM superstore
)
SELECT 
    COUNT(DISTINCT consecutive_years.customer_id) AS retained_customers,
    (SELECT total_customers.total_customers FROM total_customers) AS total_customers,
    ROUND(
        (COUNT(DISTINCT consecutive_years.customer_id) / 
         (SELECT total_customers.total_customers FROM total_customers)) * 100, 
        2
    ) AS retention_percentage
FROM consecutive_years;
```
I am calculating the number and percentage of the superstore's customers retention. The retention rate is 25.70%, 147 out of a total of 572 recorded customers.

![image](https://github.com/user-attachments/assets/0200ba89-c89c-40da-a4e4-74eda9cd9ca7)
