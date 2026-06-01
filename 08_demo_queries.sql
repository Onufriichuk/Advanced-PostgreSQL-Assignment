
SELECT *
FROM vw_flagged_transactions;

SELECT *
FROM vw_customer_risk_profile
ORDER BY average_risk_score DESC;


SELECT *
FROM vw_recent_transactions
ORDER BY transaction_at DESC;


SELECT *
FROM fraud_alerts
ORDER BY created_at DESC;


SELECT *
FROM transaction_status_history
ORDER BY changed_at DESC;



SELECT *
FROM audit_log
ORDER BY changed_at DESC;


SELECT *
FROM mv_daily_fraud_summary;


SELECT
    customer_id,
    first_name,
    last_name,
    get_customer_age(customer_id) AS age
FROM customers
WHERE get_customer_age(customer_id) > 30;

SELECT
    customer_id,
    first_name,
    last_name,
    calculate_customer_daily_volume(
        customer_id,
        CURRENT_DATE
    ) AS daily_volume
FROM customers;


SELECT mask_card_number(
    '1234567812345678'
) AS masked_card;
