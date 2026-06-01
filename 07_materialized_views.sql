
CREATE MATERIALIZED VIEW mv_daily_fraud_summary AS
WITH daily_data AS (
    SELECT
        DATE(t.transaction_at) AS transaction_date,
        COUNT(t.transaction_id) AS total_transactions,
        COALESCE(SUM(t.amount), 0) AS total_transaction_amount,
        COUNT(
            CASE
                WHEN t.status = 'FLAGGED' THEN 1
            END
        ) AS flagged_transactions,
        COALESCE(SUM(
            CASE
                WHEN t.status = 'FLAGGED' THEN t.amount
                ELSE 0
            END
        ), 0) AS suspicious_transaction_amount,
        COALESCE(AVG(t.risk_score), 0) AS average_risk_score,
        COUNT(fa.alert_id) AS total_fraud_alerts
    FROM transactions t
    LEFT JOIN fraud_alerts fa
        ON t.transaction_id = fa.transaction_id
    GROUP BY DATE(t.transaction_at)
),

top_customers AS (
    SELECT
        transaction_date,
        STRING_AGG(
            customer_name,
            ', '
            ORDER BY customer_risk_score DESC
        ) AS top_risky_customers
    FROM (
        SELECT
            DATE(t.transaction_at) AS transaction_date,
            c.first_name || ' ' || c.last_name AS customer_name,
            AVG(t.risk_score) AS customer_risk_score,
            ROW_NUMBER() OVER (
                PARTITION BY DATE(t.transaction_at)
                ORDER BY AVG(t.risk_score) DESC
            ) AS rn
        FROM transactions t
        JOIN accounts a
            ON t.account_id = a.account_id
        JOIN customers c
            ON a.customer_id = c.customer_id
        GROUP BY
            DATE(t.transaction_at),
            c.customer_id,
            c.first_name,
            c.last_name
    ) ranked_customers
    WHERE rn <= 3
    GROUP BY transaction_date
)

SELECT
    d.transaction_date,
    d.total_transactions,
    d.total_transaction_amount,
    d.flagged_transactions,
    d.suspicious_transaction_amount,
    d.average_risk_score,
    COALESCE(tc.top_risky_customers, 'No risky customers') AS top_risky_customers,
    d.total_fraud_alerts
FROM daily_data d
LEFT JOIN top_customers tc
    ON d.transaction_date = tc.transaction_date;


CREATE UNIQUE INDEX idx_mv_daily_fraud_summary_date
ON mv_daily_fraud_summary(transaction_date);


CREATE OR REPLACE PROCEDURE refresh_fraud_dashboard()
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW mv_daily_fraud_summary;
END;
$$;
