# 1. Total sales by city

SELECT city, 
       SUM(CAST(total_sales_amount AS DECIMAL(10,2))) AS total_sales
FROM shop_activity
GROUP BY city
ORDER BY total_sales DESC;

#2. Total transactions by shop type

SELECT shop_type,
       SUM(CAST(transactions_count AS UNSIGNED)) AS total_transactions
FROM shop_activity
GROUP BY shop_type
ORDER BY total_transactions DESC;

#3. Average due amount per shop
SELECT shop_id,
       AVG(CAST(due_amount AS DECIMAL(10,2))) AS avg_due
FROM shop_activity
GROUP BY shop_id
ORDER BY avg_due DESC;
#4. New users count by city
SELECT city,
       SUM(CAST(new_user AS UNSIGNED)) AS new_users
FROM shop_activity
GROUP BY city
ORDER BY new_users DESC;

#5. Total expenses vs total sales
SELECT SUM(CAST(total_sales_amount AS DECIMAL(10,2))) AS total_sales,
       SUM(CAST(expenses_amount AS DECIMAL(10,2))) AS total_expenses,
       SUM(CAST(total_sales_amount AS DECIMAL(10,2))) - SUM(CAST(expenses_amount AS DECIMAL(10,2))) AS profit
FROM shop_activity;

#6. Total app sessions by shop type
SELECT shop_type,
       SUM(CAST(app_sessions AS UNSIGNED)) AS total_sessions
FROM shop_activity
GROUP BY shop_type
ORDER BY total_sessions DESC;

#7. Shops with subscription purchased
SELECT shop_id, shop_type, city
FROM shop_activity
WHERE CAST(subscription_purchased AS UNSIGNED) = 1;
#q1:
SELECT 
    DATE(date) AS sales_date,
    SUM(CAST(total_sales_amount AS DECIMAL(10,2))) AS total_sales,
    SUM(CAST(transactions_count AS UNSIGNED)) AS total_transactions,
    CASE 
        WHEN SUM(CAST(total_sales_amount AS DECIMAL(10,2))) >= 10000 
             AND SUM(CAST(transactions_count AS UNSIGNED)) >= 50 THEN 'Good'
        WHEN SUM(CAST(total_sales_amount AS DECIMAL(10,2))) >= 5000 
             AND SUM(CAST(transactions_count AS UNSIGNED)) >= 20 THEN 'Bad'
        ELSE 'Worst'
    END AS activity_type
FROM shop_activity
GROUP BY DATE(date)
ORDER BY sales_date;


#Calculate daily totals
WITH daily_totals AS (
    SELECT
        DATE(date) AS sales_date,
        SUM(CAST(total_sales_amount AS DECIMAL(10,2))) AS total_sales,
        SUM(CAST(transactions_count AS UNSIGNED)) AS total_transactions
    FROM shop_activity
    GROUP BY DATE(date)
), #Compute percentiles for classification
ranked_totals AS (
    SELECT *,
           NTILE(3) OVER (ORDER BY total_sales DESC) AS sales_bucket,
           NTILE(3) OVER (ORDER BY total_transactions DESC) AS txn_bucket
    FROM daily_totals
) #Combine buckets into activity type
SELECT
    sales_date,
    total_sales,
    total_transactions,
    CASE 
        WHEN GREATEST(sales_bucket, txn_bucket) = 3 THEN 'Good'
        WHEN GREATEST(sales_bucket, txn_bucket) = 2 THEN 'Bad'
        ELSE 'Worst'
    END AS activity_type
FROM ranked_totals
ORDER BY sales_date;

#Q2
SELECT
    CASE 
        WHEN new_user = 1 THEN 'New User'
        ELSE 'Existing User'
    END AS user_type,
    
    -- Total sales for the group
    SUM(CAST(total_sales_amount AS DECIMAL(10,2))) AS total_sales,
    
    -- Count of distinct shops for this group
    COUNT(DISTINCT shop_id) AS number_of_shops,
    
    -- Total subscription purchases
    SUM(CAST(subscription_purchased AS UNSIGNED)) AS total_subscriptions
FROM shop_activity
GROUP BY new_user
ORDER BY new_user DESC;

#Q3
SELECT
    shop_type,
    
    -- Total subscriptions purchased for this shop type
    SUM(CAST(subscription_purchased AS UNSIGNED)) AS total_subscriptions,
    
    -- Total number of shops of this type
    COUNT(DISTINCT shop_id) AS total_shops,
    
    -- Conversion rate = subscriptions / shops * 100
    ROUND(
        SUM(CAST(subscription_purchased AS UNSIGNED)) / COUNT(DISTINCT shop_id) * 100,
        2
    ) AS subscription_conversion_rate_percentage
FROM shop_activity
GROUP BY shop_type
ORDER BY subscription_conversion_rate_percentage DESC;

#Q4
SELECT
    city as Top_5_Cities,
    SUM(CAST(total_sales_amount AS DECIMAL(10,2))) AS total_sales,
    SUM(CAST(subscription_purchased AS UNSIGNED)) AS total_subscriptions,
    COUNT(DISTINCT shop_id) AS total_shops
FROM shop_activity
WHERE CAST(subscription_purchased AS UNSIGNED) > 0
GROUP BY city
ORDER BY total_sales DESC
LIMIT 5;

