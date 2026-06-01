
CREATE OR REPLACE PROCEDURE create_fraud_alert(
    p_transaction_id BIGINT,
    p_reason TEXT,
    p_risk_score INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO fraud_alerts (
        transaction_id,
        reason,
        risk_score,
        alert_status
    )
    VALUES (
        p_transaction_id,
        p_reason,
        p_risk_score,
        'OPEN'
    );
END;
$$;


CREATE OR REPLACE PROCEDURE freeze_account(
    p_account_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE accounts
    SET status = 'FROZEN'
    WHERE account_id = p_account_id;
END;
$$;


CREATE OR REPLACE PROCEDURE process_transaction(
    p_transaction_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_risk_score INTEGER;
BEGIN

    v_risk_score :=
        calculate_transaction_risk_score(
            p_transaction_id
        );

    UPDATE transactions
    SET risk_score = v_risk_score
    WHERE transaction_id = p_transaction_id;

    IF v_risk_score >= 70 THEN

        UPDATE transactions
        SET status = 'FLAGGED'
        WHERE transaction_id = p_transaction_id;

        CALL create_fraud_alert(
            p_transaction_id,
            'High transaction risk detected',
            v_risk_score
        );

    ELSE

        UPDATE transactions
        SET status = 'APPROVED'
        WHERE transaction_id = p_transaction_id;

    END IF;

END;
$$;


CREATE OR REPLACE PROCEDURE approve_pending_transactions()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE transactions
    SET status = 'APPROVED'
    WHERE status = 'PENDING';
END;
$$;
