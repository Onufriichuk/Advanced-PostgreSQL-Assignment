
CREATE TABLE customers (
customer_id BIGSERIAL PRIMARY KEY,
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
email VARCHAR(255) UNIQUE NOT NULL,
birth_date DATE NOT NULL,
country_code CHAR(2) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE accounts (
account_id BIGSERIAL PRIMARY KEY,
customer_id BIGINT NOT NULL,
account_number VARCHAR(30) UNIQUE NOT NULL,
currency VARCHAR(3) NOT NULL,
balance NUMERIC(15,2) DEFAULT 0,
status VARCHAR(20) DEFAULT 'ACTIVE',
opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CONSTRAINT fk_accounts_customer
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
    ON DELETE RESTRICT,

CONSTRAINT chk_balance
    CHECK (balance >= 0),

CONSTRAINT chk_currency
    CHECK (currency IN ('UAH','USD','EUR'))


);

CREATE TABLE cards (
card_id BIGSERIAL PRIMARY KEY,
account_id BIGINT NOT NULL,
card_number_hash VARCHAR(255) UNIQUE NOT NULL,
card_type VARCHAR(30) NOT NULL,
status VARCHAR(20) DEFAULT 'ACTIVE',
expiration_date DATE NOT NULL,

CONSTRAINT fk_cards_account
    FOREIGN KEY (account_id)
    REFERENCES accounts(account_id)
    ON DELETE CASCADE

);

CREATE TABLE transactions (
transaction_id BIGSERIAL PRIMARY KEY,
account_id BIGINT NOT NULL,
card_id BIGINT,
amount NUMERIC(15,2) NOT NULL,
currency VARCHAR(3) NOT NULL,
merchant_category VARCHAR(100),
merchant_country CHAR(2),
status VARCHAR(20) DEFAULT 'PENDING',
risk_score INTEGER DEFAULT 0,
transaction_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CONSTRAINT fk_transactions_account
    FOREIGN KEY (account_id)
    REFERENCES accounts(account_id),

CONSTRAINT fk_transactions_card
    FOREIGN KEY (card_id)
    REFERENCES cards(card_id),

CONSTRAINT chk_amount
    CHECK (amount > 0),

CONSTRAINT chk_transaction_currency
    CHECK (currency IN ('UAH','USD','EUR')),

CONSTRAINT chk_transaction_status
    CHECK (
        status IN (
            'PENDING',
            'APPROVED',
            'DECLINED',
            'FLAGGED'
        )
    )

);

CREATE TABLE transaction_status_history (
history_id BIGSERIAL PRIMARY KEY,
transaction_id BIGINT NOT NULL,
old_status VARCHAR(20),
new_status VARCHAR(20),
changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
changed_by VARCHAR(100),

CONSTRAINT fk_history_transaction
    FOREIGN KEY (transaction_id)
    REFERENCES transactions(transaction_id)
    ON DELETE CASCADE


);

CREATE TABLE fraud_rules (
rule_id BIGSERIAL PRIMARY KEY,
rule_name VARCHAR(200) NOT NULL,
rule_type VARCHAR(100),
threshold_value INTEGER,
is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE fraud_alerts (
alert_id BIGSERIAL PRIMARY KEY,
transaction_id BIGINT NOT NULL,
rule_id BIGINT,
reason TEXT,
risk_score INTEGER,
alert_status VARCHAR(20) DEFAULT 'OPEN',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CONSTRAINT fk_alert_transaction
    FOREIGN KEY (transaction_id)
    REFERENCES transactions(transaction_id),

CONSTRAINT fk_alert_rule
    FOREIGN KEY (rule_id)
    REFERENCES fraud_rules(rule_id)

);

CREATE TABLE audit_log (
audit_id BIGSERIAL PRIMARY KEY,
customer_id BIGINT,
table_name VARCHAR(100),
operation VARCHAR(20),
old_value JSONB,
new_value JSONB,
changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

CONSTRAINT fk_audit_customer
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)

);

CREATE INDEX idx_customer_email
ON customers(email);

CREATE INDEX idx_transaction_status
ON transactions(status);

CREATE INDEX idx_transaction_risk
ON transactions(risk_score);

CREATE INDEX idx_transaction_date
ON transactions(transaction_at);

CREATE INDEX idx_alert_status
ON fraud_alerts(alert_status);
