
CREATE OR REPLACE FUNCTION trg_calculate_risk_score()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    NEW.risk_score :=
        calculate_transaction_risk_score(
            NEW.transaction_id
        );

    IF NEW.risk_score >= 70 THEN
        NEW.status := 'FLAGGED';
    END IF;

    RETURN NEW;

END;
$$;


CREATE TRIGGER transaction_risk_trigger
AFTER INSERT
ON transactions
FOR EACH ROW
EXECUTE FUNCTION trg_calculate_risk_score();


CREATE OR REPLACE FUNCTION trg_create_fraud_alert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF NEW.risk_score >= 70 THEN

        INSERT INTO fraud_alerts (
            transaction_id,
            reason,
            risk_score
        )
        VALUES (
            NEW.transaction_id,
            'Automatically detected suspicious transaction',
            NEW.risk_score
        );

    END IF;

    RETURN NEW;

END;
$$;


CREATE TRIGGER fraud_alert_trigger
AFTER INSERT OR UPDATE
ON transactions
FOR EACH ROW
EXECUTE FUNCTION trg_create_fraud_alert();


CREATE OR REPLACE FUNCTION trg_transaction_status_history()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF OLD.status IS DISTINCT FROM NEW.status THEN

        INSERT INTO transaction_status_history (
            transaction_id,
            old_status,
            new_status,
            changed_by
        )
        VALUES (
            NEW.transaction_id,
            OLD.status,
            NEW.status,
            current_user
        );

    END IF;

    RETURN NEW;

END;
$$;


CREATE TRIGGER transaction_status_history_trigger
AFTER UPDATE
ON transactions
FOR EACH ROW
EXECUTE FUNCTION trg_transaction_status_history();


CREATE OR REPLACE FUNCTION trg_update_balance()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF NEW.status = 'APPROVED'
       AND OLD.status IS DISTINCT FROM 'APPROVED'
    THEN

        UPDATE accounts
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.account_id;

    END IF;

    RETURN NEW;

END;
$$;


CREATE TRIGGER update_balance_trigger
AFTER UPDATE
ON transactions
FOR EACH ROW
EXECUTE FUNCTION trg_update_balance();


CREATE OR REPLACE FUNCTION trg_prevent_customer_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM accounts
        WHERE customer_id = OLD.customer_id
          AND status = 'ACTIVE'
    ) THEN
        RAISE EXCEPTION
            'Cannot delete customer with active accounts';
    END IF;

    RETURN OLD;

END;
$$;


CREATE TRIGGER prevent_customer_delete_trigger
BEFORE DELETE
ON customers
FOR EACH ROW
EXECUTE FUNCTION trg_prevent_customer_delete();
