--6.2 Confirm our observation date
SELECT
    MIN(order_date_dateorders) AS first_order,
    MAX(order_date_dateorders) AS last_order
FROM valid_customer_orders;

--6.4 Create the customer RFM base
DROP TABLE IF EXISTS customer_rfm_base;

CREATE TABLE customer_rfm_base AS

SELECT
    customer_id,

    -- Most recent valid purchase
    MAX(order_date_dateorders) AS last_purchase_date,

    -- Number of valid orders
    COUNT(DISTINCT order_id) AS frequency,

    -- Total net order value
    SUM(order_item_total) AS monetary

FROM valid_customer_orders

GROUP BY customer_id;

--Now check:
SELECT *
FROM customer_rfm_base

--6.5 Add Recency
SELECT
    customer_id,
    last_purchase_date,
    '2018-01-31 23:38:00'::timestamp
        - last_purchase_date AS recency_interval,
    frequency,
    monetary
FROM customer_rfm_base
ORDER BY recency_interval;

--6.6 Convert Recency to days
---Add the column:
ALTER TABLE customer_rfm_base
ADD COLUMN recency INTEGER;

--then
UPDATE customer_rfm_base
SET recency =
    EXTRACT(
        DAY FROM
        ('2018-01-31 23:38:00'::timestamp
        - last_purchase_date)
    )::INTEGER;

--check
SELECT
    MIN(recency) AS min_recency,
    MAX(recency) AS max_recency,
    AVG(recency) AS avg_recency
FROM customer_rfm_base;


--6.7 Now understand Frequency
--6.8 Understand Monetary
SELECT
    MIN(monetary) AS minimum_monetary,
    MAX(monetary) AS maximum_monetary,
    AVG(monetary) AS average_monetary,
    SUM(monetary) AS total_monetary
FROM customer_rfm_base;

--Validate:
SELECT
    SUM(monetary)
FROM customer_rfm_base;

--against:
SELECT
    SUM(order_item_total)
FROM valid_customer_orders;


--6.9 Validate customer count
SELECT
    COUNT(*) AS rfm_customers
FROM customer_rfm_base;

--against:
SELECT
    COUNT(DISTINCT customer_id) AS valid_purchase_customers
FROM valid_customer_orders;

--6.10 Check RFM distributions
SELECT
    MIN(recency) AS min_recency,
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY recency) AS p25,
    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY recency) AS median,
    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY recency) AS p75,
    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY recency) AS p90,
    MAX(recency) AS max_recency
FROM customer_rfm_base;

--6.11 Frequency distribution
SELECT
    MIN(frequency) AS min_frequency,
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY frequency) AS p25,
    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY frequency) AS median,
    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY frequency) AS p75,
    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY frequency) AS p90,
    MAX(frequency) AS max_frequency
FROM customer_rfm_base;

--6.12 Monetary distribution
SELECT
    MIN(monetary) AS min_monetary,

    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY monetary) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY monetary) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY monetary) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY monetary) AS p90,

    MAX(monetary) AS max_monetary

FROM customer_rfm_base;

--6.14 One more important analysis: repeat vs one-time
SELECT
    CASE
        WHEN frequency = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS customer_type,

    COUNT(*) AS customers,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM customer_rfm_base

GROUP BY
    CASE
        WHEN frequency = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END

ORDER BY customers DESC;

--6.15 Repeat customers and revenue
SELECT
    CASE
        WHEN frequency = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS customer_type,

    COUNT(*) AS customers,

    SUM(monetary) AS revenue,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_customer_value

FROM customer_rfm_base

GROUP BY
    CASE
        WHEN frequency = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END

ORDER BY revenue DESC;

--Your Phase 6 checkpoint
SELECT
    MIN(order_date_dateorders),
    MAX(order_date_dateorders)
FROM valid_customer_orders;

--9. Next analytical step — understand frequency distribution
SELECT
    frequency,
    COUNT(*) AS customers,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM customer_rfm_base
GROUP BY frequency
ORDER BY frequency;

--10. Next — Recency distribution around our churn threshold
SELECT
    CASE
        WHEN recency <= 90 THEN '0-90 days'
        WHEN recency <= 180 THEN '91-180 days'
        WHEN recency <= 365 THEN '181-365 days'
        WHEN recency <= 730 THEN '366-730 days'
        ELSE '731+ days'
    END AS recency_bucket,

    COUNT(*) AS customers,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM customer_rfm_base

GROUP BY
    CASE
        WHEN recency <= 90 THEN '0-90 days'
        WHEN recency <= 180 THEN '91-180 days'
        WHEN recency <= 365 THEN '181-365 days'
        WHEN recency <= 730 THEN '366-730 days'
        ELSE '731+ days'
    END

ORDER BY MIN(recency);

--11. And calculate our actual churn baseline
SELECT
    CASE
        WHEN recency > 365 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,

    COUNT(*) AS customers,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage,

    SUM(monetary) AS revenue

FROM customer_rfm_base

GROUP BY
    CASE
        WHEN recency > 365 THEN 'Churned'
        ELSE 'Active'
    END

ORDER BY churn_status;

--12. But one more analysis I want before RFM scoring
SELECT
    CASE
        WHEN frequency = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS customer_type,

    CASE
        WHEN recency > 365 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,

    COUNT(*) AS customers,

    SUM(monetary) AS revenue

FROM customer_rfm_base

GROUP BY
    CASE
        WHEN frequency = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END,

    CASE
        WHEN recency > 365 THEN 'Churned'
        ELSE 'Active'
    END

ORDER BY customer_type, churn_status;	

--14. One more thing I want to investigate
SELECT
    CASE
        WHEN recency <= 90 THEN '0-90'
        WHEN recency <= 180 THEN '91-180'
        WHEN recency <= 365 THEN '181-365'
        WHEN recency <= 730 THEN '366-730'
        ELSE '731+'
    END AS recency_bucket,

    COUNT(*) AS customers,

    ROUND(AVG(frequency), 2) AS avg_frequency,

    ROUND(AVG(monetary), 2) AS avg_monetary,

    SUM(monetary) AS total_revenue

FROM customer_rfm_base

GROUP BY
    CASE
        WHEN recency <= 90 THEN '0-90'
        WHEN recency <= 180 THEN '91-180'
        WHEN recency <= 365 THEN '181-365'
        WHEN recency <= 730 THEN '366-730'
        ELSE '731+'
    END

ORDER BY
    MIN(recency);

--15. Then one final analysis before scoring
SELECT
    frequency,

    COUNT(*) AS customers,

    ROUND(AVG(monetary), 2) AS avg_monetary,

    ROUND(
        MIN(monetary), 2
    ) AS min_monetary,

    ROUND(
        MAX(monetary), 2
    ) AS max_monetary,

    ROUND(
        SUM(monetary), 2
    ) AS total_revenue

FROM customer_rfm_base

GROUP BY frequency

ORDER BY frequency;

--6.8.3 Monetary scoring
SELECT
    PERCENTILE_CONT(0.20)
        WITHIN GROUP (ORDER BY monetary) AS p20,

    PERCENTILE_CONT(0.40)
        WITHIN GROUP (ORDER BY monetary) AS p40,

    PERCENTILE_CONT(0.60)
        WITHIN GROUP (ORDER BY monetary) AS p60,

    PERCENTILE_CONT(0.80)
        WITHIN GROUP (ORDER BY monetary) AS p80

FROM customer_rfm_base;


--🟢 Your immediate task
---Query 1 — Recency quintile boundaries
SELECT
    PERCENTILE_CONT(0.20)
        WITHIN GROUP (ORDER BY recency) AS p20,

    PERCENTILE_CONT(0.40)
        WITHIN GROUP (ORDER BY recency) AS p40,

    PERCENTILE_CONT(0.60)
        WITHIN GROUP (ORDER BY recency) AS p60,

    PERCENTILE_CONT(0.80)
        WITHIN GROUP (ORDER BY recency) AS p80

FROM customer_rfm_base;

---Query 2 — Monetary quintile boundaries
SELECT
    PERCENTILE_CONT(0.20)
        WITHIN GROUP (ORDER BY monetary) AS p20,

    PERCENTILE_CONT(0.40)
        WITHIN GROUP (ORDER BY monetary) AS p40,

    PERCENTILE_CONT(0.60)
        WITHIN GROUP (ORDER BY monetary) AS p60,

    PERCENTILE_CONT(0.80)
        WITHIN GROUP (ORDER BY monetary) AS p80

FROM customer_rfm_base;

--1. First investigate Recency
SELECT
    MIN(recency) AS min_recency,
    MAX(recency) AS max_recency,

    COUNT(*) FILTER (WHERE recency < 0) AS negative_recency,

    COUNT(*) FILTER (WHERE recency = 0) AS zero_recency,

    COUNT(*) FILTER (WHERE recency > 365) AS churned_customers

FROM customer_rfm_base;

--2. Show the customers with negative Recency
SELECT
    customer_id,
    last_purchase_date,
    recency
FROM customer_rfm_base
WHERE recency < 0
ORDER BY recency;

--3. Verify the actual maximum order date
SELECT
    MIN(order_date_dateorders) AS first_order,
    MAX(order_date_dateorders) AS last_order
FROM valid_customer_orders;

--4. Check the cutoff we're actually using
SELECT
    '2018-01-31 23:38:00'::timestamp AS cutoff_date;
--then
SELECT
    MAX(last_purchase_date) AS latest_customer_purchase,
    MAX(
        last_purchase_date
        - '2018-01-31 23:38:00'::timestamp
    ) AS difference_from_cutoff
FROM customer_rfm_base;

--5. Now investigate Monetary
SELECT
    MIN(monetary) AS min_monetary,
    MAX(monetary) AS max_monetary,

    COUNT(*) FILTER (WHERE monetary < 0) AS negative_monetary,

    COUNT(*) FILTER (WHERE monetary = 0) AS zero_monetary

FROM customer_rfm_base;

--6. Show negative Monetary customers
SELECT
    customer_id,
    frequency,
    monetary
FROM customer_rfm_base
WHERE monetary < 0
ORDER BY monetary;
--Let's verify the percentile calculation properly
--Instead of guessing what happened, let's run one diagnostic query that calculates:

--1. Recency
SELECT
    MIN(recency) AS min_recency,

    PERCENTILE_CONT(0.20)
        WITHIN GROUP (ORDER BY recency) AS p20,

    PERCENTILE_CONT(0.40)
        WITHIN GROUP (ORDER BY recency) AS p40,

    PERCENTILE_CONT(0.60)
        WITHIN GROUP (ORDER BY recency) AS p60,

    PERCENTILE_CONT(0.80)
        WITHIN GROUP (ORDER BY recency) AS p80,

    MAX(recency) AS max_recency

FROM customer_rfm_base;

--2. Monetary
SELECT
    MIN(monetary) AS min_monetary,

    PERCENTILE_CONT(0.20)
        WITHIN GROUP (ORDER BY monetary) AS p20,

    PERCENTILE_CONT(0.40)
        WITHIN GROUP (ORDER BY monetary) AS p40,

    PERCENTILE_CONT(0.60)
        WITHIN GROUP (ORDER BY monetary) AS p60,

    PERCENTILE_CONT(0.80)
        WITHIN GROUP (ORDER BY monetary) AS p80,

    MAX(monetary) AS max_monetary

FROM customer_rfm_base;

--3. One additional sanity check
SELECT
    PERCENTILE_DISC(0.20)
        WITHIN GROUP (ORDER BY recency) AS p20,

    PERCENTILE_DISC(0.40)
        WITHIN GROUP (ORDER BY recency) AS p40,

    PERCENTILE_DISC(0.60)
        WITHIN GROUP (ORDER BY recency) AS p60,

    PERCENTILE_DISC(0.80)
        WITHIN GROUP (ORDER BY recency) AS p80
FROM customer_rfm_base;
--And:
SELECT
    PERCENTILE_DISC(0.20)
        WITHIN GROUP (ORDER BY monetary) AS p20,

    PERCENTILE_DISC(0.40)
        WITHIN GROUP (ORDER BY monetary) AS p40,

    PERCENTILE_DISC(0.60)
        WITHIN GROUP (ORDER BY monetary) AS p60,

    PERCENTILE_DISC(0.80)
        WITHIN GROUP (ORDER BY monetary) AS p80
FROM customer_rfm_base;

--5. Now let's create the scores
--Before permanently modifying anything, let's preview the scoring.

SELECT
    customer_id,
    recency,
    frequency,
    monetary,

    CASE
        WHEN recency <= 94.4 THEN 5
        WHEN recency <= 215 THEN 4
        WHEN recency <= 380 THEN 3
        WHEN recency <= 621 THEN 2
        ELSE 1
    END AS r_score,

    CASE
        WHEN frequency = 1 THEN 1
        WHEN frequency = 2 THEN 2
        WHEN frequency = 3 THEN 3
        WHEN frequency = 4 THEN 4
        ELSE 5
    END AS f_score,

    CASE
        WHEN monetary <= 246.15 THEN 1
        WHEN monetary <= 553.806 THEN 2
        WHEN monetary <= 1048.028 THEN 3
        WHEN monetary <= 1655.63 THEN 4
        ELSE 5
    END AS m_score

FROM customer_rfm_base;

--6. Then validate the scores
SELECT
    r_score,
    COUNT(*) AS customers
FROM (
    SELECT
        CASE
            WHEN recency <= 94.4 THEN 5
            WHEN recency <= 215 THEN 4
            WHEN recency <= 380 THEN 3
            WHEN recency <= 621 THEN 2
            ELSE 1
        END AS r_score
    FROM customer_rfm_base
) x
GROUP BY r_score
ORDER BY r_score;

--Frequency score
SELECT
    CASE
        WHEN frequency = 1 THEN 1
        WHEN frequency = 2 THEN 2
        WHEN frequency = 3 THEN 3
        WHEN frequency = 4 THEN 4
        ELSE 5
    END AS f_score,

    COUNT(*) AS customers

FROM customer_rfm_base

GROUP BY
    CASE
        WHEN frequency = 1 THEN 1
        WHEN frequency = 2 THEN 2
        WHEN frequency = 3 THEN 3
        WHEN frequency = 4 THEN 4
        ELSE 5
    END

ORDER BY f_score;

--Monetary score
SELECT
    m_score,
    COUNT(*) AS customers
FROM (
    SELECT
        CASE
            WHEN monetary <= 246.15 THEN 1
            WHEN monetary <= 553.806 THEN 2
            WHEN monetary <= 1048.028 THEN 3
            WHEN monetary <= 1655.63 THEN 4
            ELSE 5
        END AS m_score
    FROM customer_rfm_base
) x
GROUP BY m_score
ORDER BY m_score;

--7. Then create the RFM score
ALTER TABLE customer_rfm_base
ADD COLUMN r_score INTEGER,
ADD COLUMN f_score INTEGER,
ADD COLUMN m_score INTEGER;

UPDATE customer_rfm_base
SET
    r_score =
        CASE
            WHEN recency <= 94.4 THEN 5
            WHEN recency <= 215 THEN 4
            WHEN recency <= 380 THEN 3
            WHEN recency <= 621 THEN 2
            ELSE 1
        END,

    f_score =
        CASE
            WHEN frequency = 1 THEN 1
            WHEN frequency = 2 THEN 2
            WHEN frequency = 3 THEN 3
            WHEN frequency = 4 THEN 4
            ELSE 5
        END,

    m_score =
        CASE
            WHEN monetary <= 246.15 THEN 1
            WHEN monetary <= 553.806 THEN 2
            WHEN monetary <= 1048.028 THEN 3
            WHEN monetary <= 1655.63 THEN 4
            ELSE 5
        END;

--8. Create the combined RFM code
ALTER TABLE customer_rfm_base
ADD COLUMN rfm_score VARCHAR(3);

UPDATE customer_rfm_base
SET rfm_score =
    CONCAT(
        r_score,
        f_score,
        m_score
    );

--First let's inspect the actual combinations.
SELECT
    rfm_score,
    COUNT(*) AS customers,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM customer_rfm_base
GROUP BY rfm_score
ORDER BY rfm_score;

--1. Run the preview query for R/F/M scores.
SELECT
    rfm_score,
    COUNT(*) AS customers,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM customer_rfm_base
GROUP BY rfm_score
ORDER BY rfm_score;

--We need to know whether you have all the combinations through:
SELECT
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE r_score = 5
    ) AS r5_customers,

    COUNT(*) FILTER (
        WHERE f_score = 5
    ) AS f5_customers,

    COUNT(*) FILTER (
        WHERE m_score = 5
    ) AS m5_customers

FROM customer_rfm_base;

--
SELECT
    MAX(r_score) AS max_r,
    MAX(f_score) AS max_f,
    MAX(m_score) AS max_m,
    COUNT(DISTINCT rfm_score) AS unique_rfm_combinations
FROM customer_rfm_base;

--10. One more validation that is VERY important
--Let's directly identify our highest-value inactive customers.

SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    rfm_score
FROM customer_rfm_base
WHERE r_score <= 2
  AND f_score >= 4
  AND m_score >= 4
ORDER BY monetary DESC
LIMIT 20;


--
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    rfm_score
FROM customer_rfm_base
WHERE r_score <= 2
  AND f_score >= 4
  AND m_score >= 4
ORDER BY monetary DESC
LIMIT 20;

--Step 6.10.2 — Let's identify the high-value at-risk population first
SELECT
    COUNT(*) AS customers,
    SUM(monetary) AS historical_revenue,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM customer_rfm_base
WHERE r_score <= 2
  AND f_score >= 4
  AND m_score >= 4;

--Step 6.10.3 — Find our Champions
SELECT
    COUNT(*) AS customers,
    SUM(monetary) AS historical_revenue,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM customer_rfm_base
WHERE r_score >= 4
  AND f_score >= 4
  AND m_score >= 4;

--Step 6.10.4 — Identify potential loyalists
SELECT
    COUNT(*) AS customers,
    SUM(monetary) AS historical_revenue,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM customer_rfm_base
WHERE r_score >= 4
  AND f_score BETWEEN 2 AND 3;

--Step 6.10.5 — Identify low-valueinactive customers
SELECT
    COUNT(*) AS customers,
    SUM(monetary) AS historical_revenue,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM customer_rfm_base
WHERE r_score <= 2
  AND f_score <= 2
  AND m_score <= 2;

--Step 6.10.6 — One important group: New Customers
SELECT
    COUNT(*) AS customers,
    SUM(monetary) AS historical_revenue,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM customer_rfm_base
WHERE r_score = 5
  AND f_score = 1;

--Step 6.10.7 — Don't create the segment column yet

--12. Before permanently creating the segment

SELECT
    CASE

        WHEN r_score <= 2
             AND f_score >= 4
             AND m_score >= 4
            THEN 'High-Value At Risk'

        WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 3
             AND f_score >= 3
             AND m_score >= 3
            THEN 'Loyal Customers'

        WHEN r_score >= 4
             AND f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

        WHEN r_score = 5
             AND f_score = 1
            THEN 'New Customers'

        WHEN r_score <= 2
             AND f_score >= 2
            THEN 'At Risk'

        WHEN r_score <= 2
             AND f_score <= 2
             AND m_score <= 2
            THEN 'Hibernating'

        ELSE 'Need Attention'

    END AS rfm_segment,

    COUNT(*) AS customers,

    SUM(monetary) AS historical_revenue,

    ROUND(AVG(recency), 2) AS avg_recency,

    ROUND(AVG(frequency), 2) AS avg_frequency,

    ROUND(AVG(monetary), 2) AS avg_monetary

FROM customer_rfm_base

GROUP BY
    CASE

        WHEN r_score <= 2
             AND f_score >= 4
             AND m_score >= 4
            THEN 'High-Value At Risk'

        WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 3
             AND f_score >= 3
             AND m_score >= 3
            THEN 'Loyal Customers'

        WHEN r_score >= 4
             AND f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

        WHEN r_score = 5
             AND f_score = 1
            THEN 'New Customers'

        WHEN r_score <= 2
             AND f_score >= 2
            THEN 'At Risk'

        WHEN r_score <= 2
             AND f_score <= 2
             AND m_score <= 2
            THEN 'Hibernating'

        ELSE 'Need Attention'

    END

ORDER BY customers DESC;

--9. Let's investigate Need Attention
SELECT
    rfm_score,
    COUNT(*) AS customers,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    SUM(monetary) AS revenue
FROM customer_rfm_base
WHERE NOT (
       (r_score <= 2 AND f_score >= 4 AND m_score >= 4)
    OR (r_score >= 4 AND f_score >= 4 AND m_score >= 4)
    OR (r_score >= 3 AND f_score >= 3 AND m_score >= 3)
    OR (r_score >= 4 AND f_score BETWEEN 2 AND 3)
    OR (r_score = 5 AND f_score = 1)
    OR (r_score <= 2 AND f_score >= 2)
    OR (r_score <= 2 AND f_score <= 2 AND m_score <= 2)
)
GROUP BY rfm_score
ORDER BY customers DESC;

--10. There's another validation we must do now
--We need to compare our RFM segments against the actual churn definition.
SELECT
    CASE

        WHEN r_score <= 2
             AND f_score >= 4
             AND m_score >= 4
            THEN 'High-Value At Risk'

        WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 3
             AND f_score >= 3
             AND m_score >= 3
            THEN 'Loyal Customers'

        WHEN r_score >= 4
             AND f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

        WHEN r_score = 5
             AND f_score = 1
            THEN 'New Customers'

        WHEN r_score <= 2
             AND f_score >= 2
            THEN 'At Risk'

        WHEN r_score <= 2
             AND f_score <= 2
             AND m_score <= 2
            THEN 'Hibernating'

        ELSE 'Need Attention'

    END AS rfm_segment,

    CASE
        WHEN recency > 365 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,

    COUNT(*) AS customers,

    SUM(monetary) AS revenue

FROM customer_rfm_base

GROUP BY
    1, 2

ORDER BY
    1, 2;


--9. Let's calculate the exact churn rate for every segment
SELECT
    rfm_segment,
    COUNT(*) AS customers,

    COUNT(*) FILTER (
        WHERE churn_status = 'Churned'
    ) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE churn_status = 'Churned'
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    SUM(monetary) AS historical_revenue,

    SUM(monetary) FILTER (
        WHERE churn_status = 'Churned'
    ) AS churned_customer_revenue

FROM (
    SELECT
        CASE

            WHEN r_score <= 2
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'High-Value Churned'

            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 3
                 AND m_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score = 1
                THEN 'New Customers'

            WHEN r_score <= 2
                 AND f_score >= 2
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                 AND m_score <= 2
                THEN 'Hibernating'

            ELSE 'Need Attention'

        END AS rfm_segment,

        CASE
            WHEN recency > 365 THEN 'Churned'
            ELSE 'Active'
        END AS churn_status,

        monetary

    FROM customer_rfm_base
) x

GROUP BY rfm_segment
ORDER BY churn_rate DESC;

-----------
SELECT
    COUNT(*) AS customers,
    SUM(monetary) AS historical_revenue,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM customer_rfm_base
WHERE recency BETWEEN 181 AND 365
  AND frequency >= 3
  AND monetary >= 1048.03;

--------------------
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    rfm_score
FROM customer_rfm_base
WHERE recency BETWEEN 181 AND 365
  AND frequency >= 3
  AND monetary >= 1048.03
ORDER BY monetary DESC;

--7.1.1 — Understand delivery_status
SELECT
    delivery_status,
    COUNT(*) AS order_count,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM shipping

GROUP BY delivery_status

ORDER BY order_count DESC;
--7.1.2 — Understand late_delivery_risk
SELECT
    late_delivery_risk,
    COUNT(*) AS order_count,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM shipping

GROUP BY late_delivery_risk

ORDER BY late_delivery_risk;

--7.1.3 — Analyze actual vs scheduled shipping
SELECT
    ROUND(
        AVG(days_for_shipping_real),
        2
    ) AS avg_actual_shipping_days,

    ROUND(
        AVG(days_for_shipment_scheduled),
        2
    ) AS avg_scheduled_shipping_days,

    ROUND(
        AVG(
            days_for_shipping_real
            - days_for_shipment_scheduled
        ),
        2
    ) AS avg_shipping_delay,

    MIN(
        days_for_shipping_real
        - days_for_shipment_scheduled
    ) AS minimum_delay,

    MAX(
        days_for_shipping_real
        - days_for_shipment_scheduled
    ) AS maximum_delay

FROM shipping;

--7.1.4 — Understand the distribution of delay
SELECT
    delivery_delay,
    COUNT(*) AS orders

FROM (
    SELECT
        days_for_shipping_real
        - days_for_shipment_scheduled AS delivery_delay

    FROM shipping
) x

GROUP BY delivery_delay

ORDER BY delivery_delay;

--7.1.5 — Compare delivery status against actual delay
SELECT
    delivery_status,

    COUNT(*) AS orders,

    ROUND(
        AVG(
            days_for_shipping_real
            - days_for_shipment_scheduled
        ),
        2
    ) AS avg_delay,

    MIN(
        days_for_shipping_real
        - days_for_shipment_scheduled
    ) AS min_delay,

    MAX(
        days_for_shipping_real
        - days_for_shipment_scheduled
    ) AS max_delay

FROM shipping

GROUP BY delivery_status

ORDER BY orders DESC;

--7.1.6 — Validate the relationship between risk and actual delivery
SELECT
    late_delivery_risk,
    delivery_status,

    COUNT(*) AS orders,

    ROUND(
        100.0 * COUNT(*)
        /
        SUM(COUNT(*)) OVER (
            PARTITION BY late_delivery_risk
        ),
        2
    ) AS percentage_within_risk

FROM shipping

GROUP BY
    late_delivery_risk,
    delivery_status

ORDER BY
    late_delivery_risk,
    orders DESC;


--7.1.7 — Check for impossible/missing shipping values
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE days_for_shipping_real IS NULL
    ) AS null_actual_days,

    COUNT(*) FILTER (
        WHERE days_for_shipment_scheduled IS NULL
    ) AS null_scheduled_days,

    COUNT(*) FILTER (
        WHERE delivery_status IS NULL
    ) AS null_delivery_status,

    COUNT(*) FILTER (
        WHERE late_delivery_risk IS NULL
    ) AS null_late_risk,

    COUNT(*) FILTER (
        WHERE days_for_shipping_real < 0
    ) AS negative_actual_days,

    COUNT(*) FILTER (
        WHERE days_for_shipment_scheduled < 0
    ) AS negative_scheduled_days

FROM shipping;

--7.1.8 — Check whether shipping has one row per order
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM shipping;

SELECT
    order_id,
    COUNT(*) AS row_count
FROM shipping
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC
LIMIT 20;


--Create order_shipping_base
CREATE OR REPLACE VIEW order_shipping_base AS

SELECT
    o.order_id,
    o.customer_id,
    o.order_date_dateorders,
    o.order_status,

    s.shipping_date_dateorders,
    s.shipping_mode,
    s.delivery_status,
    s.late_delivery_risk,

    s.days_for_shipping_real,
    s.days_for_shipment_scheduled,

    (
        s.days_for_shipping_real
        - s.days_for_shipment_scheduled
    ) AS delivery_delay,

    CASE
        WHEN s.delivery_status = 'Late delivery'
        THEN 1
        ELSE 0
    END AS is_late,

    CASE
        WHEN s.delivery_status = 'Shipping canceled'
        THEN 1
        ELSE 0
    END AS is_canceled

FROM orders o

INNER JOIN shipping s
    ON o.order_id = s.order_id;

---Immediately validate the view
SELECT COUNT(*) AS rows
FROM order_shipping_base;

----
SELECT
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM order_shipping_base;

SELECT
    is_late,
    COUNT(*) AS orders
FROM order_shipping_base
GROUP BY is_late
ORDER BY is_late;

--
SELECT
    is_canceled,
    COUNT(*) AS orders
FROM order_shipping_base
GROUP BY is_canceled
ORDER BY is_canceled;

--7.2.5 Validate the delay calculation
SELECT
    MIN(delivery_delay) AS min_delay,
    MAX(delivery_delay) AS max_delay,
    ROUND(AVG(delivery_delay), 2) AS avg_delay
FROM order_shipping_base;

--7.2.6 Validate that our is_late definition matches the source
SELECT
    delivery_status,
    is_late,
    COUNT(*) AS orders

FROM order_shipping_base

GROUP BY
    delivery_status,
    is_late

ORDER BY
    delivery_status,
    is_late;


--7.2.7 One more important validation
SELECT
    COUNT(*) AS canceled_and_late
FROM order_shipping_base
WHERE is_canceled = 1
  AND is_late = 1;

--7.3.2 — Create the customer supply-chain view

CREATE OR REPLACE VIEW customer_supply_chain_base AS

SELECT
    customer_id,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(is_late) AS late_orders,

    ROUND(
        100.0 * SUM(is_late)
        / COUNT(DISTINCT order_id),
        2
    ) AS late_delivery_rate,

    ROUND(
        AVG(delivery_delay),
        2
    ) AS avg_delivery_delay,

    MAX(delivery_delay) AS max_delivery_delay,

    SUM(is_canceled) AS canceled_orders,

    ROUND(
        100.0 * SUM(is_canceled)
        / COUNT(DISTINCT order_id),
        2
    ) AS cancellation_rate,

    ROUND(
        AVG(days_for_shipping_real),
        2
    ) AS avg_actual_shipping_days,

    ROUND(
        AVG(days_for_shipment_scheduled),
        2
    ) AS avg_scheduled_shipping_days

FROM order_shipping_base

GROUP BY customer_id;

--7.3.3 — Check the number of customers
SELECT
    COUNT(*) AS customer_count
FROM customer_supply_chain_base;

--7.3.4 — Check whether customer IDs are unique
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM customer_supply_chain_base;

--7.3.5 — Inspect the first customers
SELECT *
FROM customer_supply_chain_base
ORDER BY customer_id;

--7.3.6 — Validate the fundamental mathematical rules
SELECT
    COUNT(*) FILTER (
        WHERE late_orders > total_orders
    ) AS invalid_late_orders,

    COUNT(*) FILTER (
        WHERE canceled_orders > total_orders
    ) AS invalid_cancellations,

    COUNT(*) FILTER (
        WHERE late_delivery_rate < 0
           OR late_delivery_rate > 100
    ) AS invalid_late_rates,

    COUNT(*) FILTER (
        WHERE cancellation_rate < 0
           OR cancellation_rate > 100
    ) AS invalid_cancellation_rates

FROM customer_supply_chain_base;

--7.3.7 — Check customer-level totals against order-level totals
SELECT
    SUM(total_orders) AS customer_level_orders,
    SUM(late_orders) AS customer_level_late_orders,
    SUM(canceled_orders) AS customer_level_canceled_orders
FROM customer_supply_chain_base;

--7.3.8 — Check the overall customer late-delivery rate
SELECT
    ROUND(
        100.0 * SUM(late_orders)
        / SUM(total_orders),
        2
    ) AS overall_late_delivery_rate
FROM customer_supply_chain_base;

--7.3.9 — Check the distribution of customer late-delivery rates
SELECT
    CASE
        WHEN late_delivery_rate = 0
            THEN '0%'

        WHEN late_delivery_rate > 0
             AND late_delivery_rate <= 25
            THEN '1-25%'

        WHEN late_delivery_rate > 25
             AND late_delivery_rate <= 50
            THEN '26-50%'

        WHEN late_delivery_rate > 50
             AND late_delivery_rate <= 75
            THEN '51-75%'

        ELSE '76-100%'
    END AS late_rate_bucket,

    COUNT(*) AS customers,

    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage

FROM customer_supply_chain_base

GROUP BY 1

ORDER BY 1;

--7.4.1 Compare customer populations
SELECT
    COUNT(*) AS supply_chain_customers
FROM customer_supply_chain_base;

SELECT
    COUNT(*) AS rfm_customers
FROM customer_rfm_base;

SELECT
    COUNT(*) AS customers_in_both
FROM customer_supply_chain_base s
INNER JOIN customer_rfm_base r
    ON s.customer_id = r.customer_id;

--7.4.2 Customers in supply chain but not RFM
SELECT
    COUNT(*) AS supply_chain_only
FROM customer_supply_chain_base s
LEFT JOIN customer_rfm_base r
    ON s.customer_id = r.customer_id
WHERE r.customer_id IS NULL;

--7.4.3 Customers in RFM but not supply chain
SELECT
    COUNT(*) AS rfm_only
FROM customer_rfm_base r
LEFT JOIN customer_supply_chain_base s
    ON r.customer_id = s.customer_id
WHERE s.customer_id IS NULL;

--7.4.4 Validate the RFM + Supply Chain join
SELECT
    COUNT(*) AS joined_rows,
    COUNT(DISTINCT r.customer_id) AS unique_customers
FROM customer_rfm_base r
INNER JOIN customer_supply_chain_base s
    ON r.customer_id = s.customer_id;

--7.4.5 Check for missing supply-chain values after the join
SELECT
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE s.total_orders IS NULL
    ) AS missing_total_orders,

    COUNT(*) FILTER (
        WHERE s.late_delivery_rate IS NULL
    ) AS missing_late_rate,

    COUNT(*) FILTER (
        WHERE s.avg_delivery_delay IS NULL
    ) AS missing_avg_delay

FROM customer_rfm_base r

LEFT JOIN customer_supply_chain_base s
    ON r.customer_id = s.customer_id;


--Phase 7.5 — Build the Combined Customer Churn Analysis
--7.5.1 Before creating it — inspect the RFM table structure
SELECT *
FROM customer_rfm_base;

--7.5.2 — Create the corrected customer_churn_analysis
CREATE OR REPLACE VIEW customer_churn_analysis AS

SELECT
    r.customer_id,

    -- =========================
    -- RFM METRICS
    -- =========================

    r.recency,
    r.frequency,
    r.monetary,

    r.r_score,
    r.f_score,
    r.m_score,
    r.rfm_score,

    -- =========================
    -- RFM SEGMENT
    -- =========================

    CASE

        WHEN r.r_score <= 2
             AND r.f_score >= 4
             AND r.m_score >= 4
            THEN 'High-Value Churned'

        WHEN r.r_score >= 4
             AND r.f_score >= 4
             AND r.m_score >= 4
            THEN 'Champions'

        WHEN r.r_score >= 3
             AND r.f_score >= 3
             AND r.m_score >= 3
            THEN 'Loyal Customers'

        WHEN r.r_score >= 4
             AND r.f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

        WHEN r.r_score = 5
             AND r.f_score = 1
            THEN 'New Customers'

        WHEN r.r_score <= 2
             AND r.f_score >= 2
            THEN 'At Risk'

        WHEN r.r_score <= 2
             AND r.f_score <= 2
             AND r.m_score <= 2
            THEN 'Hibernating'

        ELSE 'Need Attention'

    END AS rfm_segment,

    -- =========================
    -- CHURN STATUS
    -- =========================

    CASE
        WHEN r.recency > 365
            THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,

    -- =========================
    -- SUPPLY CHAIN EXPERIENCE
    -- =========================

    s.total_orders,

    s.late_orders,

    s.late_delivery_rate,

    s.avg_delivery_delay,

    s.max_delivery_delay,

    s.canceled_orders,

    s.cancellation_rate,

    s.avg_actual_shipping_days,

    s.avg_scheduled_shipping_days

FROM customer_rfm_base r

INNER JOIN customer_supply_chain_base s
    ON r.customer_id = s.customer_id;

--7.5.3 — Validate the row count
SELECT
    COUNT(*) AS rows
FROM customer_churn_analysis;

--7.5.4 — Validate uniqueness
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM customer_churn_analysis;

--7.5.5 — Verify the newly created columns
SELECT
    rfm_segment,
    churn_status,
    COUNT(*) AS customers
FROM customer_churn_analysis
GROUP BY
    rfm_segment,
    churn_status
ORDER BY
    rfm_segment,
    churn_status;

--7.5.6 — Check missing values
SELECT
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer,

    COUNT(*) FILTER (
        WHERE recency IS NULL
    ) AS missing_recency,

    COUNT(*) FILTER (
        WHERE frequency IS NULL
    ) AS missing_frequency,

    COUNT(*) FILTER (
        WHERE monetary IS NULL
    ) AS missing_monetary,

    COUNT(*) FILTER (
        WHERE rfm_segment IS NULL
    ) AS missing_rfm_segment,

    COUNT(*) FILTER (
        WHERE churn_status IS NULL
    ) AS missing_churn,

    COUNT(*) FILTER (
        WHERE total_orders IS NULL
    ) AS missing_orders,

    COUNT(*) FILTER (
        WHERE late_delivery_rate IS NULL
    ) AS missing_late_rate,

    COUNT(*) FILTER (
        WHERE avg_delivery_delay IS NULL
    ) AS missing_delay

FROM customer_churn_analysis;

--7.5.7 — Reconcile RFM population
SELECT
    COUNT(*) AS customers,
    SUM(monetary) AS total_monetary
FROM customer_rfm_base;
--Then:
SELECT
    COUNT(*) AS customers,
    SUM(monetary) AS total_monetary
FROM customer_churn_analysis;

--7.5.8 — Reconcile churn
SELECT
    churn_status,
    COUNT(*) AS customers,
    SUM(monetary) AS revenue
FROM customer_churn_analysis
GROUP BY churn_status
ORDER BY churn_status;

--PHASE 7.6 — Delivery Performance × Churn
--7.6.1 — Compare Active vs Churned customers
SELECT
    churn_status,

    COUNT(*) AS customers,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_delivery_rate,

    ROUND(
        AVG(avg_delivery_delay),
        2
    ) AS avg_delivery_delay,

    ROUND(
        AVG(cancellation_rate),
        2
    ) AS avg_cancellation_rate,

    ROUND(
        AVG(total_orders),
        2
    ) AS avg_total_orders,

    ROUND(
        AVG(late_orders),
        2
    ) AS avg_late_orders

FROM customer_churn_analysis

GROUP BY churn_status

ORDER BY churn_status;

--7.6.2 — Compare the actual number of late orders
SELECT
    churn_status,

    SUM(total_orders) AS total_orders,

    SUM(late_orders) AS late_orders,

    ROUND(
        100.0 * SUM(late_orders)
        / SUM(total_orders),
        2
    ) AS weighted_late_delivery_rate,

    SUM(canceled_orders) AS canceled_orders,

    ROUND(
        100.0 * SUM(canceled_orders)
        / SUM(total_orders),
        2
    ) AS weighted_cancellation_rate

FROM customer_churn_analysis

GROUP BY churn_status

ORDER BY churn_status;

--7.6.3 — Compare customer late-delivery exposure:-
SELECT
    late_delivery_exposure,

    COUNT(*) AS customers,

    COUNT(*) FILTER (
        WHERE churn_status = 'Churned'
    ) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE churn_status = 'Churned'
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary

FROM (
    SELECT
        churn_status,
        monetary,

        CASE
            WHEN late_delivery_rate = 0
                THEN 'No Late Deliveries'

            WHEN late_delivery_rate > 0
                 AND late_delivery_rate <= 25
                THEN '1-25%'

            WHEN late_delivery_rate > 25
                 AND late_delivery_rate <= 50
                THEN '26-50%'

            WHEN late_delivery_rate > 50
                 AND late_delivery_rate <= 75
                THEN '51-75%'

            ELSE '76-100%'
        END AS late_delivery_exposure,

        CASE
            WHEN late_delivery_rate = 0 THEN 1
            WHEN late_delivery_rate <= 25 THEN 2
            WHEN late_delivery_rate <= 50 THEN 3
            WHEN late_delivery_rate <= 75 THEN 4
            ELSE 5
        END AS exposure_order

    FROM customer_churn_analysis
) x

GROUP BY
    late_delivery_exposure,
    exposure_order

ORDER BY
    exposure_order;

--7.6.4 — Delivery Delay Severity × Churn
SELECT
    avg_delay_bucket,

    COUNT(*) AS customers,

    COUNT(*) FILTER (
        WHERE churn_status = 'Churned'
    ) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE churn_status = 'Churned'
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary

FROM (
    SELECT
        churn_status,
        monetary,

        CASE
            WHEN avg_delivery_delay <= 0
                THEN 'On/Ahead of Schedule'

            WHEN avg_delivery_delay > 0
                 AND avg_delivery_delay <= 1
                THEN 'Up to 1 Day Delay'

            WHEN avg_delivery_delay > 1
                 AND avg_delivery_delay <= 2
                THEN '1-2 Days Delay'

            ELSE 'More Than 2 Days Delay'
        END AS avg_delay_bucket,

        CASE
            WHEN avg_delivery_delay <= 0 THEN 1
            WHEN avg_delivery_delay <= 1 THEN 2
            WHEN avg_delivery_delay <= 2 THEN 3
            ELSE 4
        END AS delay_order

    FROM customer_churn_analysis
) x

GROUP BY
    avg_delay_bucket,
    delay_order

ORDER BY
    delay_order;

--7.6.5 — Cancellation × Churn
SELECT
    cancellation_exposure,

    COUNT(*) AS customers,

    COUNT(*) FILTER (
        WHERE churn_status = 'Churned'
    ) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE churn_status = 'Churned'
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary

FROM (
    SELECT
        churn_status,
        monetary,

        CASE
            WHEN cancellation_rate = 0
                THEN 'No Cancellations'

            WHEN cancellation_rate > 0
                 AND cancellation_rate <= 25
                THEN '1-25%'

            WHEN cancellation_rate > 25
                 AND cancellation_rate <= 50
                THEN '26-50%'

            ELSE '51%+'
        END AS cancellation_exposure,

        CASE
            WHEN cancellation_rate = 0 THEN 1
            WHEN cancellation_rate <= 25 THEN 2
            WHEN cancellation_rate <= 50 THEN 3
            ELSE 4
        END AS cancellation_order

    FROM customer_churn_analysis
) x

GROUP BY
    cancellation_exposure,
    cancellation_order

ORDER BY
    cancellation_order;



--PHASE 7.7 — RFM × Supply Chain × Churn
--7.7.1 — First, compare churn by RFM segment
SELECT
    rfm_segment,

    COUNT(*) AS customers,

    COUNT(*) FILTER (
        WHERE churn_status = 'Churned'
    ) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE churn_status = 'Churned'
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_delivery_rate

FROM customer_churn_analysis

GROUP BY rfm_segment

ORDER BY churn_rate DESC;

--7.7.2 — RFM segment × late-delivery exposure
SELECT
    rfm_segment,

    CASE
        WHEN late_delivery_rate = 0
            THEN 'No Late Deliveries'

        WHEN late_delivery_rate <= 25
            THEN '1-25%'

        WHEN late_delivery_rate <= 50
            THEN '26-50%'

        WHEN late_delivery_rate <= 75
            THEN '51-75%'

        ELSE '76-100%'
    END AS late_delivery_exposure,

    COUNT(*) AS customers,

    COUNT(*) FILTER (
        WHERE churn_status = 'Churned'
    ) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE churn_status = 'Churned'
        )
        / COUNT(*),
        2
    ) AS churn_rate,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary

FROM customer_churn_analysis

GROUP BY
    rfm_segment,
    CASE
        WHEN late_delivery_rate = 0
            THEN 'No Late Deliveries'

        WHEN late_delivery_rate <= 25
            THEN '1-25%'

        WHEN late_delivery_rate <= 50
            THEN '26-50%'

        WHEN late_delivery_rate <= 75
            THEN '51-75%'

        ELSE '76-100%'
    END

ORDER BY
    rfm_segment,
    churn_rate DESC;

--7.7.3 — Focus specifically on valuable customers:-
SELECT
    rfm_segment,

    COUNT(*) AS active_customers,

    ROUND(
        SUM(monetary),
        2
    ) AS active_customer_value,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_customer_value,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_delivery_rate,

    ROUND(
        AVG(cancellation_rate),
        2
    ) AS avg_cancellation_rate

FROM customer_churn_analysis

WHERE churn_status = 'Active'

GROUP BY rfm_segment

ORDER BY active_customer_value DESC;

--7.7.4 — Identify active customers with high delivery exposure
SELECT
    rfm_segment,

    COUNT(*) AS active_customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_customer_value,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_rate,

    ROUND(
        AVG(cancellation_rate),
        2
    ) AS avg_cancellation_rate

FROM customer_churn_analysis

WHERE churn_status = 'Active'

  AND late_delivery_rate >= 50

GROUP BY rfm_segment

ORDER BY total_customer_value DESC;

--7.8.1 — First identify active customers approaching churn
SELECT
    recency_risk_bucket,

    COUNT(*) AS customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_monetary,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_rate,

    ROUND(
        AVG(cancellation_rate),
        2
    ) AS avg_cancellation_rate

FROM (
    SELECT
        recency,
        monetary,
        late_delivery_rate,
        cancellation_rate,

        CASE
            WHEN recency <= 90
                THEN '0-90 days'

            WHEN recency <= 180
                THEN '91-180 days'

            WHEN recency <= 270
                THEN '181-270 days'

            WHEN recency <= 365
                THEN '271-365 days'

            ELSE 'Churned'
        END AS recency_risk_bucket,

        CASE
            WHEN recency <= 90 THEN 1
            WHEN recency <= 180 THEN 2
            WHEN recency <= 270 THEN 3
            WHEN recency <= 365 THEN 4
            ELSE 5
        END AS recency_order

    FROM customer_churn_analysis

    WHERE churn_status = 'Active'
) x

GROUP BY
    recency_risk_bucket,
    recency_order

ORDER BY
    recency_order;

--7.8.2 — Frequency Query:-
SELECT
    frequency_group,

    COUNT(*) AS customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_monetary,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_rate

FROM (
    SELECT
        frequency,
        monetary,
        late_delivery_rate,

        CASE
            WHEN frequency = 1
                THEN 'One-Time'

            WHEN frequency BETWEEN 2 AND 3
                THEN '2-3 Orders'

            WHEN frequency BETWEEN 4 AND 5
                THEN '4-5 Orders'

            ELSE '6+ Orders'
        END AS frequency_group,

        CASE
            WHEN frequency = 1 THEN 1
            WHEN frequency BETWEEN 2 AND 3 THEN 2
            WHEN frequency BETWEEN 4 AND 5 THEN 3
            ELSE 4
        END AS frequency_order

    FROM customer_churn_analysis

    WHERE churn_status = 'Active'
) x

GROUP BY
    frequency_group,
    frequency_order

ORDER BY
    frequency_order;

--7.8.3 — Find the Monetary distribution of active customers
SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY monetary) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY monetary) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY monetary) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY monetary) AS p90

FROM customer_churn_analysis

WHERE churn_status = 'Active';

--7.8.4 — Find Frequency distribution of active customers
SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY frequency) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY frequency) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY frequency) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY frequency) AS p90

FROM customer_churn_analysis

WHERE churn_status = 'Active';

--7.8.5 — Find the Recency distribution of active customers
SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY recency) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY recency) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY recency) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY recency) AS p90

FROM customer_churn_analysis

WHERE churn_status = 'Active';

--7.8.6 — Find the delivery-experience distribution for active customers
SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY late_delivery_rate) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY late_delivery_rate) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY late_delivery_rate) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY late_delivery_rate) AS p90

FROM customer_churn_analysis

WHERE churn_status = 'Active';

--Cancellation rate
SELECT
    PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY cancellation_rate) AS p25,

    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY cancellation_rate) AS median,

    PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY cancellation_rate) AS p75,

    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY cancellation_rate) AS p90

FROM customer_churn_analysis

WHERE churn_status = 'Active';


--Phase 7.9 — Build the Retention Priority Population
--7.9.1 — Profile near-churn active customers
SELECT
    COUNT(*) AS customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_monetary,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary,

    ROUND(
        AVG(frequency),
        2
    ) AS avg_frequency,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_rate,

    ROUND(
        AVG(cancellation_rate),
        2
    ) AS avg_cancellation_rate

FROM customer_churn_analysis

WHERE churn_status = 'Active'
  AND recency BETWEEN 271 AND 365;

--7.9.2 — Split near-churn customers by value
SELECT
    value_group,

    COUNT(*) AS customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_monetary,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary,

    ROUND(
        AVG(frequency),
        2
    ) AS avg_frequency,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_rate,

    ROUND(
        AVG(cancellation_rate),
        2
    ) AS avg_cancellation_rate

FROM (
    SELECT
        monetary,
        frequency,
        late_delivery_rate,
        cancellation_rate,

        CASE
            WHEN monetary >= 2301.05
                THEN 'Very High Value'

            WHEN monetary >= 1531.17
                THEN 'High Value'

            WHEN monetary >= 660.97
                THEN 'Medium Value'

            ELSE 'Low Value'
        END AS value_group,

        CASE
            WHEN monetary >= 2301.05 THEN 1
            WHEN monetary >= 1531.17 THEN 2
            WHEN monetary >= 660.97 THEN 3
            ELSE 4
        END AS value_order

    FROM customer_churn_analysis

    WHERE churn_status = 'Active'
      AND recency BETWEEN 271 AND 365
) x

GROUP BY
    value_group,
    value_order

ORDER BY
    value_order;

--7.9.3 — Now let's examine the 657 high-value near-churn customers
SELECT
    rfm_segment,

    COUNT(*) AS customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_monetary,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary,

    ROUND(
        AVG(frequency),
        2
    ) AS avg_frequency,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_rate,

    ROUND(
        AVG(cancellation_rate),
        2
    ) AS avg_cancellation_rate

FROM customer_churn_analysis

WHERE churn_status = 'Active'
  AND recency BETWEEN 271 AND 365
  AND monetary >= 1531.17

GROUP BY rfm_segment

ORDER BY total_monetary DESC;

--7.9.4 — Examine their delivery exposure
SELECT
    delivery_exposure,

    COUNT(*) AS customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_monetary,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary,

    ROUND(
        AVG(cancellation_rate),
        2
    ) AS avg_cancellation_rate

FROM (
    SELECT
        monetary,
        cancellation_rate,

        CASE
            WHEN late_delivery_rate = 0
                THEN 'No Late Deliveries'

            WHEN late_delivery_rate < 50
                THEN '1-49%'

            WHEN late_delivery_rate < 100
                THEN '50-99%'

            ELSE '100%'
        END AS delivery_exposure,

        CASE
            WHEN late_delivery_rate = 0 THEN 1
            WHEN late_delivery_rate < 50 THEN 2
            WHEN late_delivery_rate < 100 THEN 3
            ELSE 4
        END AS delivery_order

    FROM customer_churn_analysis

    WHERE churn_status = 'Active'
      AND recency BETWEEN 271 AND 365
      AND monetary >= 1531.17
) x

GROUP BY
    delivery_exposure,
    delivery_order

ORDER BY
    delivery_order;

--7.9.5 — Cancellation Exposure
SELECT
    cancellation_exposure,

    COUNT(*) AS customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_monetary,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary,

    ROUND(
        AVG(frequency),
        2
    ) AS avg_frequency

FROM (
    SELECT
        monetary,
        frequency,

        CASE
            WHEN cancellation_rate = 0
                THEN 'No Cancellation'

            WHEN cancellation_rate < 10
                THEN '1-9.99%'

            ELSE '10%+'
        END AS cancellation_exposure,

        CASE
            WHEN cancellation_rate = 0 THEN 1
            WHEN cancellation_rate < 10 THEN 2
            ELSE 3
        END AS cancellation_order

    FROM customer_churn_analysis

    WHERE churn_status = 'Active'
      AND recency BETWEEN 271 AND 365
      AND monetary >= 1531.17
) x

GROUP BY
    cancellation_exposure,
    cancellation_order

ORDER BY
    cancellation_order;

--7.9.6 — Identify the highest-priority population
SELECT
    retention_priority,

    COUNT(*) AS customers,

    ROUND(
        SUM(monetary),
        2
    ) AS total_monetary,

    ROUND(
        AVG(monetary),
        2
    ) AS avg_monetary,

    ROUND(
        AVG(frequency),
        2
    ) AS avg_frequency,

    ROUND(
        AVG(late_delivery_rate),
        2
    ) AS avg_late_rate,

    ROUND(
        AVG(cancellation_rate),
        2
    ) AS avg_cancellation_rate

FROM (
    SELECT
        monetary,
        frequency,
        late_delivery_rate,
        cancellation_rate,

        CASE
            WHEN cancellation_rate >= 10
                 AND late_delivery_rate >= 50
                THEN 'Critical - Delivery + Cancellation'

            WHEN cancellation_rate >= 10
                THEN 'High - Cancellation'

            WHEN late_delivery_rate >= 50
                THEN 'High - Delivery'

            ELSE 'Monitor'
        END AS retention_priority,

        CASE
            WHEN cancellation_rate >= 10
                 AND late_delivery_rate >= 50
                THEN 1

            WHEN cancellation_rate >= 10
                THEN 2

            WHEN late_delivery_rate >= 50
                THEN 3

            ELSE 4
        END AS priority_order

    FROM customer_churn_analysis

    WHERE churn_status = 'Active'
      AND recency BETWEEN 271 AND 365
      AND monetary >= 1531.17
) x

GROUP BY
    retention_priority,
    priority_order

ORDER BY
    priority_order;

--7.9.7 — Quantify the business value at risk
WITH priority_population AS (

    SELECT
        CASE
            WHEN cancellation_rate >= 10
                 AND late_delivery_rate >= 50
                THEN 'Critical - Delivery + Cancellation'

            WHEN cancellation_rate >= 10
                THEN 'High - Cancellation'

            WHEN late_delivery_rate >= 50
                THEN 'High - Delivery'

            ELSE 'Monitor'
        END AS retention_priority,

        monetary

    FROM customer_churn_analysis

    WHERE churn_status = 'Active'
      AND recency BETWEEN 271 AND 365
      AND monetary >= 1531.17
),

active_total AS (

    SELECT
        SUM(monetary) AS total_active_monetary
    FROM customer_churn_analysis
    WHERE churn_status = 'Active'
)

SELECT
    p.retention_priority,

    COUNT(*) AS customers,

    ROUND(
        SUM(p.monetary),
        2
    ) AS monetary_value,

    ROUND(
        100.0 * SUM(p.monetary)
        / a.total_active_monetary,
        2
    ) AS percentage_of_active_value

FROM priority_population p

CROSS JOIN active_total a

GROUP BY
    p.retention_priority,
    a.total_active_monetary

ORDER BY
    monetary_value DESC;


--7.9.8 — Calculate the overall intervention opportunity:-
WITH priority_population AS (

    SELECT
        monetary

    FROM customer_churn_analysis

    WHERE churn_status = 'Active'
      AND recency BETWEEN 271 AND 365
      AND monetary >= 1531.17

      AND (
          late_delivery_rate >= 50
          OR cancellation_rate >= 10
      )
),

active_total AS (

    SELECT
        COUNT(*) AS active_customers,
        SUM(monetary) AS active_monetary
    FROM customer_churn_analysis

    WHERE churn_status = 'Active'
)

SELECT

    COUNT(*) AS priority_customers,

    ROUND(
        SUM(monetary),
        2
    ) AS priority_monetary,

    ROUND(
        100.0 * COUNT(*)
        / active_total.active_customers,
        2
    ) AS percentage_of_active_customers,

    ROUND(
        100.0 * SUM(monetary)
        / active_total.active_monetary,
        2
    ) AS percentage_of_active_value

FROM priority_population

CROSS JOIN active_total

GROUP BY
    active_total.active_customers,
    active_total.active_monetary;