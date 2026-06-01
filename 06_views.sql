
CREATE OR REPLACE VIEW vw_customer_accounts AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.country_code,
    a.account_id,
    a.account_number,
    a.currency,
    a.balance,
    a.status AS account_status,
    a.opened_at
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id;


CREATE OR REPLACE VIEW vw_recent_transactions AS
SELECT
    t.transaction_id,
    c.customer_id,
    c.first_name,
    c.last_name,
    a.account_number,
    t.amount,
    t.currency,
    t.merchant_category,
    t.merchant_country,
    t.status,
    t.risk_score,
    t.transaction_at
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN customers c
    ON a.customer_id = c.customer_id
WHERE t.transaction_at >= CURRENT_DATE - INTERVAL '30 days';


CREATE OR REPLACE VIEW vw_flagged_transactions AS
SELECT
    t.transaction_id,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    a.account_number,
    t.amount,
    t.currency,
    t.merchant_category,
    t.merchant_country,
    t.status,
    t.risk_score,
    t.transaction_at
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN customers c
    ON a.customer_id = c.customer_id
WHERE t.status = 'FLAGGED'
   OR t.risk_score >= 70;


CREATE OR REPLACE VIEW vw_customer_risk_profile AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(t.transaction_id) AS total_transactions,
    COALESCE(SUM(t.amount), 0) AS total_transaction_amount,
    COALESCE(AVG(t.risk_score), 0) AS average_risk_score,
    COUNT(
        CASE
            WHEN t.status = 'FLAGGED' THEN 1
        END
    ) AS flagged_transactions,
    COUNT(fa.alert_id) AS total_fraud_alerts
FROM customers c
LEFT JOIN accounts a
    ON c.customer_id = a.customer_id
LEFT JOIN transactions t
    ON a.account_id = t.account_id
LEFT JOIN fraud_alerts fa
    ON t.transaction_id = fa.transaction_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;
