/*
================================================================================
MODULE 03: TRIGGERS
================================================================================
*/

-- Audit Trigger
CREATE TRIGGER trg_audit_cases_after_update
AFTER UPDATE ON cases
REFERENCING OLD AS old_row NEW AS new_row
FOR EACH ROW
BEGIN ATOMIC
    INSERT INTO audit_log (
        audit_id, table_name, record_id, action,
        old_values, new_values, changed_by
    ) VALUES (
        gen_uuid(), 'cases', new_row.case_id, 'UPDATE',
        'Status: ' || old_row.status,
        'Status: ' || new_row.status,
        CURRENT_USER
    );
END;

-- Evidence Chain Protection
CREATE TRIGGER trg_protect_evidence_chain
BEFORE DELETE OR UPDATE ON evidence_chain
FOR EACH ROW
BEGIN ATOMIC
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Evidence chain records are immutable';
END;
