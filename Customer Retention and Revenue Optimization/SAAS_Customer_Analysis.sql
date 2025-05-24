create table saas_customers
(
customer_id number,
name      varchar(100),
signup_date date,
country varchar(100)
);


select * from saas_customers;

create table saas_subscriptions
(
subscription_id number,
customer_id number,
plan      varchar(10),
start_date date,
end_date date,
is_active int
);

create table SAAS_PAYMENTS
(
payment_id number,
customer_id number,
amount      number(18,0),
payment_date date,
payment_method varchar(20)
);

create table saas_user_activity
(
activity_id number,
customer_id number,
activity_date date,
feature_used varchar(50)
);


select * from saas_user_activity;




--### Step-by-Step Analysis

----- **Step 1: Monthly Revenue Trend**

select *  from saas_payments;

SELECT 
    EXTRACT(Year FROM payment_date) AS Year,   
    to_char(payment_date, 'Month') AS month,
    SUM(amount) AS total_revenue
FROM saas_payments
GROUP BY EXTRACT(Year FROM payment_date), to_char(payment_date, 'Month')
ORDER BY EXTRACT(Year FROM payment_date) , to_char(payment_date, 'Month');


--**Step 2: Active vs Inactive saas_customers**

select * from saas_subscriptions;

SELECT 
    is_active,
    COUNT(DISTINCT customer_id) AS customer_count
FROM saas_subscriptions
GROUP BY is_active;




--- **Step 3: Churn Rate (saas_customers whose saas_subscriptions ended in the last 6 months)**

---sql
SELECT 
    COUNT(*) FILTER (WHERE end_date >= sysdate - INTERVAL '6 months') * 1.0 / 
    COUNT(*) AS churn_rate_last_6_months
FROM saas_subscriptions
WHERE end_date IS NOT NULL;



DECLARE
    churn_rate_last_6_months NUMBER;
    total_count NUMBER;
    churned_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO total_count
    FROM saas_subscriptions
    WHERE end_date IS NOT NULL;

    SELECT COUNT(*) INTO churned_count
    FROM saas_subscriptions
    WHERE end_date IS NOT NULL
      AND end_date >= SYSDATE - INTERVAL '6' MONTH;

    IF total_count > 0 THEN
        churn_rate_last_6_months := churned_count / total_count;
    ELSE
        churn_rate_last_6_months := 0;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Churn rate (last 6 months): ' || TO_CHAR(churn_rate_last_6_months));
END;
/

--Churn rate (last 6 months): .49



--- **Step 4: Top 3 Countries by Total Revenue**

---sql
SELECT 
    c.country,
    SUM(p.amount) AS revenue
FROM saas_customers c
JOIN saas_payments p ON c.customer_id = p.customer_id
GROUP BY c.country
ORDER BY revenue DESC
FETCH NEXT 3 ROWS ONLY;



--- **Step 5: Feature Engagement Score (number of times a feature used)**

---sql
SELECT 
    feature_used,
    COUNT(*) AS usage_count
FROM saas_user_activity
GROUP BY feature_used
ORDER BY usage_count DESC;



--- **Step 6: Revenue by Plan Type**

---sql
SELECT 
    s.plan,
    SUM(p.amount) AS revenue
FROM saas_subscriptions s
JOIN saas_payments p ON s.customer_id = p.customer_id
GROUP BY s.plan;



--- **Step 7: Average Revenue per Active User (ARPU)**

---sql
SELECT 
    ROUND(SUM(p.amount) * 1.0 / COUNT(DISTINCT s.customer_id), 2) AS arpu
FROM saas_subscriptions s
JOIN saas_payments p ON s.customer_id = p.customer_id
WHERE s.is_active = 1;



--- **Step 8: saas_customers with Low Engagement but High Payment (Churn Risk)**
select * from saas_customers
---sql
SELECT 
    p.customer_id, c.name customer_name,
    SUM(p.amount) AS total_paid,
    COUNT(a.activity_id) AS activity_count
FROM saas_payments p
LEFT JOIN saas_user_activity a ON p.customer_id = a.customer_id
LEFT JOIN saas_customers c ON p.customer_id = c.customer_id
GROUP BY p.customer_id, c.name
HAVING COUNT(a.activity_id) between 1 and 2 AND SUM(p.amount) > 100
order by total_paid desc;



--### Insights You Can Derive

* Retention strategies for high-paying low-engagement saas_customers
* Revenue growth over time by plan or country
* ARPU by segment
* Feature popularity trends for product development
* Churn prediction based on usage + payment + subscription data



1. Retention Strategies for High-Paying, Low-Engagement Customers
Definition:
Customers on Premium plans or with high total payment amounts but low feature usage.

SQL to Identify Them (PostgreSQL-style):

SELECT 
    c.customer_id,
    SUM(p.amount) AS total_spent,
    COUNT(a.activity_id) AS activity_count
FROM saas_customers c
LEFT JOIN saas_payments p ON c.customer_id = p.customer_id
LEFT JOIN saas_user_activity a ON c.customer_id = a.customer_id
GROUP BY c.customer_id
HAVING SUM(p.amount) > 1000 AND COUNT(a.activity_id) < 5;




--Revenue Growth Over Time by Plan or Country

SELECT 
    to_char(p.payment_date, 'Month') AS month,
    s.plan,
    c.country,
    SUM(p.amount) AS revenue
FROM saas_payments p
JOIN saas_subscriptions s ON p.customer_id = s.customer_id
JOIN saas_customers c ON p.customer_id = c.customer_id
where p.payment_date between '01-jan-2023' and '31-dec-2023'
GROUP BY to_char(p.payment_date, 'Month'), s.plan,
    c.country
ORDER BY 1;


SELECT 
    s.plan,
    c.country,
    SUM(p.amount) / COUNT(DISTINCT p.customer_id) AS arpu
FROM saas_payments p
JOIN saas_customers c ON c.customer_id = p.customer_id
JOIN saas_subscriptions s ON s.customer_id = c.customer_id
WHERE s.is_active = 1
GROUP BY s.plan, c.country;


-- Feature Popularity Trends for Product Development


SELECT 
    to_char(activity_date, 'Month') AS month,
    feature_used,
    COUNT(*) AS usage_count
FROM saas_user_activity
GROUP BY to_char(activity_date, 'Month'), feature_used
ORDER BY to_char(activity_date, 'Month');

Python Visualization:


import matplotlib.pyplot as plt
df.pivot(index='month', columns='feature_used', values='usage_count').plot(kind='line')
plt.title("Feature Popularity Over Time")

--Churn Prediction Based on Usage + Payment + Subscription
--Label:
-- Churned if end_date is not null and in past
select * from saas_subscriptions;

UPDATE saas_subscriptions
SET churn_flag = CASE 
    WHEN end_date IS NOT NULL AND end_date < '01-jan-2025' THEN 1 
    ELSE 0 
END;


    SELECT 
        s.customer_id,
        s.plan,
        s.is_active,
        COUNT(a.activity_id) AS total_logins,
        SUM(p.amount) AS total_spent,
        s.churn_flag
    FROM saas_subscriptions s
    LEFT JOIN saas_payments p ON s.customer_id = p.customer_id
    LEFT JOIN saas_user_activity a ON s.customer_id = a.customer_id
    GROUP BY s.customer_id, s.plan, s.is_active, s.churn_flag

select * from test_user;

create table test_user
(
id int,
name varchar(10)
);

--truncate table saas_user_activity;
select * from saas_user_activity t ;
select count(1) from saas_user_activity;




---Extra

--Suggested Analysis Queries
--Monthly Recurring Revenue (MRR) by Plan:


SELECT 
    plan,
    TO_CHAR(start_date, 'YYYY-MM') AS month,
    COUNT(*) AS active_subscriptions,
    COUNT(*) * 100 AS estimated_mrr -- assuming fixed MRR of 100 per subscription
FROM saas_subscriptions
WHERE is_active = 1
GROUP BY plan, TO_CHAR(start_date, 'YYYY-MM')
ORDER BY plan, month;


DECLARE
    CURSOR sub_cursor IS
        SELECT 
            plan,
            TO_CHAR(start_date, 'YYYY-MM') AS month,
            COUNT(*) AS active_subscriptions,
            COUNT(*) * 100 AS estimated_mrr
        FROM saas_subscriptions
        WHERE is_active = 1
        GROUP BY plan, TO_CHAR(start_date, 'YYYY-MM')
        ORDER BY plan, month;
    
    v_plan saas_subscriptions.plan%TYPE;
    v_month VARCHAR2(7);
    v_active_subs NUMBER;
    v_estimated_mrr NUMBER;
BEGIN
    OPEN sub_cursor;
    LOOP
        FETCH sub_cursor INTO v_plan, v_month, v_active_subs, v_estimated_mrr;
        EXIT WHEN sub_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Plan: ' || v_plan || ', Month: ' || v_month ||
                             ', Active Subs: ' || v_active_subs || ', MRR: ' || v_estimated_mrr);
    END LOOP;
    CLOSE sub_cursor;
END;
/



--Customer Lifetime Value (CLV):

SELECT 
    c.name,
    SUM(p.amount) AS lifetime_value
FROM saas_customers c
JOIN saas_payments p ON c.customer_id = p.customer_id
GROUP BY c.name;


    
--Top Feature Usage:


SELECT feature_used, COUNT(*) AS usage_count
FROM saas_user_activity
GROUP BY feature_used
ORDER BY usage_count DESC;


--High Value Customers (Revenue + Engagement):

SELECT 
    c.name,
    SUM(p.amount) AS revenue,
    COUNT(a.activity_id) AS activity_count
FROM saas_customers c
JOIN saas_payments p ON c.customer_id = p.customer_id
JOIN saas_user_activity a ON c.customer_id = a.customer_id
GROUP BY c.name
ORDER BY revenue DESC, activity_count DESC;


--📈 2. Revenue Cohort Analysis
--Group users by signup month and track revenue or retention over time.

SELECT
    TRUNC(c.signup_date, 'MM') AS cohort_month,
    TRUNC(p.payment_date, 'MM') AS active_month,
    COUNT(DISTINCT p.customer_id) AS active_users,
    SUM(p.amount) AS revenue
FROM saas_customers c
JOIN saas_payments p ON c.customer_id = p.customer_id
GROUP BY TRUNC(c.signup_date, 'MM'), TRUNC(p.payment_date, 'MM')
ORDER BY cohort_month, active_month;




/*



🔁 1. Churn Drivers (Predictive Insights)
Use a classification model (like Random Forest or XGBoost) to identify key features that influence churn, such as:

Plan type

Number of logins (engagement)

Payment frequency

Total revenue contribution

Last activity date

Feature importance from the model will tell you which behaviors predict churn the most.

📈 2. Revenue Cohort Analysis
Group users by signup month and track revenue or retention over time.

sql
Copy
Edit
SELECT 
    DATE_TRUNC('month', signup_date) AS cohort_month,
    DATE_TRUNC('month', p.payment_date) AS active_month,
    COUNT(DISTINCT p.customer_id) AS active_users,
    SUM(p.amount) AS revenue
FROM saas_customers c
JOIN saas_payments p ON c.customer_id = p.customer_id
GROUP BY 1, 2
ORDER BY 1, 2;
Use a heatmap to visualize revenue retention by cohort.

💰 3. LTV (Lifetime Value) per Segment
Calculate total revenue per customer and group by:

Country

Plan

Signup channel (if available)

python
Copy
Edit
df.groupby("plan")["total_spent"].mean()
Plot ARPU and LTV over time.

🎯 4. Power Users vs. At-Risk Customers
Segment customers into 4 quadrants based on:

Engagement: Total logins or feature usage

Value: Total spent

Quadrant	Strategy
High Spend / Low Use	Upsell value-added services or training
Low Spend / High Use	Offer conversion to premium plans
High / High	Loyalty rewards
Low / Low	Consider churn outreach

📊 5. Feature Usage Correlation to Revenue
Analyze which features (feature_used) drive more spending.

python
Copy
Edit
usage_revenue = df.groupby("feature_used")["amount"].sum().sort_values()
usage_revenue.plot(kind='barh')
Helps product team prioritize enhancements.

🧠 6. Behavior-Based Plan Recommendations
Cluster customers using KMeans on:

Total logins

Total spent

Active days
Then recommend suitable plans based on cluster profiles.

🚨 7. Churn Risk Scoring
Use logistic regression or probability outputs from a RandomForest:

Generate a churn probability for each user.

Flag users with P(churn) > 0.7 for retention campaigns.

🌍 8. Geo-Specific Trends
If country is available:

Compare churn, ARPU, and engagement by country.

Identify regions with high growth or poor retention.

🧾 9. Subscription Upgrade/Downgrade Patterns
Track customer movement between plans over time:

Basic → Premium

Premium → Standard (churn indicator)

*/



--window functions and CTE function on above data set on SaaS Customer Analytics project


--1. CTE with Window Function – Monthly Revenue and Running Total

WITH monthly_revenue AS (
    SELECT 
        TRUNC(p.payment_date, 'MM') AS revenue_month,
        SUM(p.amount) AS monthly_total
    FROM saas_payments p
    GROUP BY TRUNC(p.payment_date, 'MM')
)
SELECT 
    revenue_month,
    monthly_total,
    SUM(monthly_total) OVER (ORDER BY revenue_month) AS running_total_revenue
FROM monthly_revenue;

--2. CTE – Churned Customers by Month with Retention Flag
WITH active_customers AS (
    SELECT 
        s.customer_id,
        MAX(s.end_date) AS last_end_date
    FROM saas_subscriptions s
    GROUP BY s.customer_id
),
churned AS (
    SELECT 
        customer_id,
        CASE 
            WHEN last_end_date < ADD_MONTHS(SYSDATE, -1) THEN 1
            ELSE 0
        END AS churn_flag
    FROM active_customers
)
SELECT 
    TRUNC(c.signup_date, 'MM') AS cohort_month,
    COUNT(*) AS total_customers,
    SUM(churn_flag) AS churned_customers
FROM saas_customers c
JOIN churned ch ON c.customer_id = ch.customer_id
GROUP BY TRUNC(c.signup_date, 'MM')
ORDER BY cohort_month;

--3. Window Function – Rank Customers by Total Payment

SELECT 
    p.customer_id,
    SUM(p.amount) AS total_payment,
    RANK() OVER (ORDER BY SUM(p.amount) DESC) AS payment_rank
FROM saas_payments p
GROUP BY p.customer_id;


--4. CTE – ARPU (Average Revenue Per User) by Plan
WITH revenue_per_plan AS (
    SELECT 
        s.plan,
        COUNT(DISTINCT s.customer_id) AS users,
        SUM(p.amount) AS total_revenue
    FROM saas_subscriptions s
    JOIN saas_payments p ON s.customer_id = p.customer_id
    GROUP BY s.plan
)
SELECT 
    plan,
    total_revenue,
    users,
    ROUND(total_revenue / users, 2) AS arpu
FROM revenue_per_plan;


--5. Window Function – Lag to Detect Drop in Monthly Activity

WITH monthly_activity AS (
    SELECT 
        customer_id,
        TRUNC(activity_date, 'MM') AS activity_month,
        COUNT(*) AS events
    FROM saas_user_activity
    GROUP BY customer_id, TRUNC(activity_date, 'MM')
)
SELECT 
    customer_id,
    activity_month,
    events,
    LAG(events) OVER (PARTITION BY customer_id ORDER BY activity_month) AS previous_month_events,
    (events - LAG(events) OVER (PARTITION BY customer_id ORDER BY activity_month)) AS change_in_activity
FROM monthly_activity;


--🔁 1. Materialized Views (MV)
--a. Monthly Revenue with Running Total
CREATE MATERIALIZED VIEW mv_monthly_revenue_summary
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
WITH monthly_revenue AS (
    SELECT 
        TRUNC(p.payment_date, 'MM') AS revenue_month,
        SUM(p.amount) AS monthly_total
    FROM saas_payments p
    GROUP BY TRUNC(p.payment_date, 'MM')
)
SELECT 
    revenue_month,
    monthly_total,
    SUM(monthly_total) OVER (ORDER BY revenue_month) AS running_total_revenue
FROM monthly_revenue;

begin
EXEC DBMS_MVIEW.REFRESH('mv_monthly_revenue_summary');
end;


--🔧 2. Stored Procedure
--b. Stored Procedure to Insert Churn Report Monthly

CREATE OR REPLACE PROCEDURE proc_generate_churn_report IS
BEGIN
    INSERT INTO churn_report (cohort_month, total_customers, churned_customers)
    WITH active_customers AS (
        SELECT 
            s.customer_id,
            MAX(s.end_date) AS last_end_date
        FROM saas_subscriptions s
        GROUP BY s.customer_id
    ),
    churned AS (
        SELECT 
            customer_id,
            CASE 
                WHEN last_end_date < ADD_MONTHS(SYSDATE, -1) THEN 1
                ELSE 0
            END AS churn_flag
        FROM active_customers
    )
    SELECT 
        TRUNC(c.signup_date, 'MM') AS cohort_month,
        COUNT(*) AS total_customers,
        SUM(churn_flag) AS churned_customers
    FROM saas_customers c
    JOIN churned ch ON c.customer_id = ch.customer_id
    GROUP BY TRUNC(c.signup_date, 'MM');

    COMMIT;
END;
/


select * from  churn_report;



--Schedule it using DBMS_SCHEDULER.


--🧮 3. Scalar Function
--c. Get ARPU by Plan

CREATE OR REPLACE FUNCTION get_arpu(p_plan VARCHAR2)
RETURN NUMBER
IS
    arpu NUMBER;
BEGIN
    SELECT ROUND(SUM(p.amount)/COUNT(DISTINCT s.customer_id), 2)
    INTO arpu
    FROM saas_subscriptions s
    JOIN saas_payments p ON s.customer_id = p.customer_id
    WHERE s.plan = p_plan;

    RETURN arpu;
END;
/


SELECT get_arpu('Premium') FROM dual;



/*
📊 4. Interactive Dashboards (Suggestions)
Build these in Oracle APEX, Power BI, or Looker Studio using materialized views or REST APIs.

Example Dashboards:
Revenue Overview: Line chart from mv_monthly_revenue_summary.

Churn Trends: From churn_report table updated via procedure.

Top Customers: Use the RANK() output query in a table visual.

Feature Usage Trends: Use monthly aggregated user activity grouped by feature_used

*/


