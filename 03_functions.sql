
CREATE OR REPLACE FUNCTION calculate_customer_daily_volume(
p_customer_id BIGINT,
p_target_date DATE
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
total_volume NUMERIC;
BEGIN
SELECT COALESCE(SUM(t.amount), 0)
INTO total_volume
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE a.customer_id = p_customer_id
AND DATE(t.transaction_at) = p_target_date
AND t.status IN ('APPROVED', 'FLAGGED', 'PENDING');

RETURN total_volume;

END;
$$;

CREATE OR REPLACE FUNCTION is_high_risk_country(
p_country_code CHAR(2)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
RETURN p_country_code IN ('IR', 'KP', 'NG', 'AF');
END;
$$;

CREATE OR REPLACE FUNCTION get_customer_age(
p_customer_id BIGINT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
result_age INTEGER;
BEGIN
SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))::INTEGER
INTO result_age
FROM customers
WHERE customer_id = p_customer_id;

RETURN result_age;

END;
$$;

CREATE OR REPLACE FUNCTION mask_card_number(
p_card_number TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
IF p_card_number IS NULL OR LENGTH(p_card_number) < 4 THEN
RETURN '****';
END IF;

RETURN '**** **** **** ' || RIGHT(p_card_number, 4);

END;
$$;

CREATE OR REPLACE FUNCTION calculate_transaction_risk_score(
p_transaction_id BIGINT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
v_amount NUMERIC;
v_merchant_country CHAR(2);
v_customer_id BIGINT;
v_daily_volume NUMERIC;
v_risk_score INTEGER := 0;
BEGIN
SELECT
t.amount,
t.merchant_country,
a.customer_id
INTO
v_amount,
v_merchant_country,
v_customer_id
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE t.transaction_id = p_transaction_id;

IF v_amount IS NULL THEN
    RETURN 0;
END IF;

IF v_amount > 10000 THEN
    v_risk_score := v_risk_score + 40;
ELSIF v_amount > 5000 THEN
    v_risk_score := v_risk_score + 25;
ELSIF v_amount > 1000 THEN
    v_risk_score := v_risk_score + 10;
END IF;

IF is_high_risk_country(v_merchant_country) THEN
    v_risk_score := v_risk_score + 35;
END IF;

v_daily_volume := calculate_customer_daily_volume(
    v_customer_id,
    CURRENT_DATE
);

IF v_daily_volume > 20000 THEN
    v_risk_score := v_risk_score + 25;
ELSIF v_daily_volume > 10000 THEN
    v_risk_score := v_risk_score + 15;
END IF;

IF v_risk_score > 100 THEN
    v_risk_score := 100;
END IF;

RETURN v_risk_score;


END;
$$;
