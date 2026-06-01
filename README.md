# Advanced-PostgreSQL-Assignment

## Project Overview

This project is an advanced PostgreSQL database system for monitoring banking fraud.

The system stores customers, accounts, cards, transactions, fraud rules, fraud alerts, transaction status history, and audit logs. It also automatically evaluates transaction risk, flags suspicious transactions, creates fraud alerts, updates balances, stores status history and provides analytical reports through views and a materialized view.

## Database Objects

The project includes tables, primary keys, foreign keys, unique constraints, check constraints, functions, stored procedures, triggers, views, materialized view, audit log, sample data, demo queries, bonus scheduled refresh strategy

## Files

Run the files in this order:

1. 01_schema.sql
2. 03_functions.sql
3. 04_procedures.sql
4. 05_triggers.sql
5. 06_views.sql
6. 07_materialized_views.sql
7. 02_sample_data.sql
8. 09_final_required_bonus.sql
9. 08_demo_queries.sql

## Main Tables

The main tables are:

- customers
- accounts
- cards
- transactions
- transaction_status_history
- fraud_rules
- fraud_alerts
- audit_log

## Constraints and Data Integrity

The database uses constraints to protect data quality.

Examples:

- each table has a primary key
- customer email is unique
- account number is unique
- card hash is unique
- transaction amount must be greater than 0
- account balance cannot be negative
- currency is limited to UAH, USD, EUR
- transaction status is limited to PENDING, APPROVED, DECLINED, FLAGGED

## Fraud Logic

The fraud score is calculated by the function:

calculate_transaction_risk_score(transaction_id)

The score depends on transaction amount, merchant country, customer daily transaction volume

Risk score examples are large transaction amount, transactions from high-risk countries, high daily transaction volume 

If the risk score is 70 or higher, the transaction is marked as FLAGGED.

## Functions

The project includes these functions:

- calculate_customer_daily_volume(customer_id, target_date)
- is_high_risk_country(country_code)
- calculate_transaction_risk_score(transaction_id)
- mask_card_number(card_number)
- get_customer_age(customer_id)

## Stored Procedures

The project includes these stored procedures:

- process_transaction(transaction_id)
- create_fraud_alert(transaction_id, reason, risk_score)
- freeze_account(account_id)
- approve_pending_transactions()
- refresh_fraud_dashboard()

## Triggers

The project includes triggers for:

- automatic transaction risk evaluation
- automatic fraud alert creation
- account balance update after transaction approval
- transaction status history tracking
- audit logging
- customer deletion protection

## Views

The project includes these views:

- vw_customer_accounts
- vw_recent_transactions
- vw_flagged_transactions
- vw_customer_risk_profile

These views simplify reporting and analysis.

## Materialized View

The materialized view is:

mv_daily_fraud_summary

It contains:

- transaction date
- total transactions
- total transaction amount
- number of flagged transactions
- suspicious transaction amount
- average risk score
- top risky customers
- total fraud alerts

The materialized view can be refreshed with:

CALL refresh_fraud_dashboard();

## Bonus Refresh Strategy

For the bonus task, the project includes a pg_cron scheduled refresh strategy.

The planned job refreshes the fraud dashboard every hour:

CALL refresh_fraud_dashboard();

This may require additional PostgreSQL server configuration, because pg_cron is not always available in local installations.

## Demo Queries

The file 08_demo_queries.sql demonstrates:

- flagged transactions
- customer risk profiles
- recent transactions
- fraud alerts
- transaction status history
- audit log
- daily fraud summary
- helper functions

## Assumptions

This is a study project, so the fraud scoring logic is simplified.

Assumptions:

- all transactions are outgoing payments
- approved transactions reduce account balance
- high-risk countries are defined manually
- risk threshold is 70
- materialized view is refreshed manually or by scheduled job
- card numbers are stored as hashes, not plain numbers

## How to Run

Create a PostgreSQL database, for example:

banking_fraud

Then run all SQL files in the order listed above.

After running all files, execute:

SELECT * FROM vw_flagged_transactions;

SELECT * FROM fraud_alerts;

SELECT * FROM audit_log;

SELECT * FROM mv_daily_fraud_summary;

If these queries return data, the system works correctly.
