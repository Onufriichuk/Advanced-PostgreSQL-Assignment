
INSERT INTO customers (
    first_name,
    last_name,
    email,
    birth_date,
    country_code
)
VALUES
    ('Kamelia', 'Bohudinova', 'kamelia.bohudinova@example.com', '2006-11-29', 'UA'),
    ('Anfisa', 'Rohatina', 'anfisa.rohatina@example.com', '2007-05-05', 'UA'),
    ('Olga', 'Marshaluk', 'olga.marshaluk@example.com', '2007-07-14', 'UA'),
    ('Ahata', 'Apshai', 'ahata.apshai@example.com', '2006-08-05', 'US');


INSERT INTO accounts (
    customer_id,
    account_number,
    currency,
    balance,
    status
)
VALUES
    (1, 'UAH-100001', 'UAH', 50000.00, 'ACTIVE'),
    (2, 'USD-200001', 'USD', 12000.00, 'ACTIVE'),
    (3, 'EUR-300001', 'EUR', 8000.00, 'ACTIVE'),
    (4, 'USD-400001', 'USD', 25000.00, 'ACTIVE');


INSERT INTO cards (
    account_id,
    card_number_hash,
    card_type,
    status,
    expiration_date
)
VALUES
    (1, 'hash_card_anna_001', 'VISA', 'ACTIVE', '2028-12-31'),
    (2, 'hash_card_mark_001', 'MASTERCARD', 'ACTIVE', '2027-10-31'),
    (3, 'hash_card_olena_001', 'VISA', 'ACTIVE', '2029-05-31'),
    (4, 'hash_card_david_001', 'MASTERCARD', 'ACTIVE', '2028-08-31');


INSERT INTO fraud_rules (
    rule_name,
    rule_type,
    threshold_value,
    is_active
)
VALUES
    ('Large transaction amount', 'AMOUNT', 5000, TRUE),
    ('High risk merchant country', 'COUNTRY', 70, TRUE),
    ('High daily transaction volume', 'DAILY_VOLUME', 10000, TRUE),
    ('Very high risk score', 'RISK_SCORE', 70, TRUE);


INSERT INTO transactions (
    account_id,
    card_id,
    amount,
    currency,
    merchant_category,
    merchant_country,
    status,
    transaction_at
)
VALUES
    (1, 1, 250.00, 'UAH', 'GROCERY', 'UA', 'PENDING', CURRENT_TIMESTAMP),
    (1, 1, 1200.00, 'UAH', 'ELECTRONICS', 'UA', 'PENDING', CURRENT_TIMESTAMP),
    (2, 2, 6500.00, 'USD', 'ONLINE_STORE', 'US', 'PENDING', CURRENT_TIMESTAMP),
    (2, 2, 15000.00, 'USD', 'CRYPTO', 'NG', 'PENDING', CURRENT_TIMESTAMP),
    (3, 3, 300.00, 'EUR', 'CAFE', 'UA', 'PENDING', CURRENT_TIMESTAMP),
    (3, 3, 9000.00, 'EUR', 'TRAVEL', 'AF', 'PENDING', CURRENT_TIMESTAMP),
    (4, 4, 11000.00, 'USD', 'LUXURY', 'US', 'PENDING', CURRENT_TIMESTAMP),
    (4, 4, 22000.00, 'USD', 'UNKNOWN', 'KP', 'PENDING', CURRENT_TIMESTAMP);
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM accounts;
SELECT COUNT(*) FROM cards;
SELECT COUNT(*) FROM transactions;
SELECT COUNT(*) FROM fraud_alerts;
