/*
================================================================================
MODULE 02: PROCEDURES & SECURITY
================================================================================
*/

/*
--------------------------------------------------------------------------------
SECURITY (ROLES)
--------------------------------------------------------------------------------
*/
CREATE ROLE investigator;
CREATE ROLE evidence_manager;
CREATE ROLE auditor;
CREATE ROLE admin;

GRANT SELECT, INSERT, UPDATE ON cases TO investigator;
GRANT SELECT, INSERT, UPDATE ON suspects TO investigator;
GRANT SELECT, INSERT ON evidence TO investigator;
GRANT SELECT, INSERT, UPDATE ON evidence TO evidence_manager;
GRANT SELECT ON audit_log TO auditor;
GRANT ALL PRIVILEGES ON cases TO admin;

/*
--------------------------------------------------------------------------------
FUNCTIONS & PROCEDURES
--------------------------------------------------------------------------------
*/

-- UUID Generator Placeholder
CREATE FUNCTION gen_uuid() RETURNS CHAR(36)
LANGUAGE SQL
DETERMINISTIC
RETURN '00000000-0000-0000-0000-000000000000'; -- Placeholder

-- Case Number Generator
CREATE FUNCTION gen_case_number() RETURNS VARCHAR(20)
LANGUAGE SQL
NOT DETERMINISTIC
BEGIN ATOMIC
    DECLARE next_val INTEGER;
    DECLARE year_str CHAR(4);
    SET next_val = NEXT VALUE FOR seq_case_number_id;
    SET year_str = CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS CHAR(4));
    RETURN 'CASE-' || year_str || '-' || CAST(next_val AS VARCHAR(10));
END;

-- Create Case
CREATE PROCEDURE sp_create_case(
    IN p_title VARCHAR(255),
    IN p_description VARCHAR(4000),
    IN p_officer_id CHAR(36),
    IN p_priority VARCHAR(10),
    OUT p_new_case_id CHAR(36),
    OUT p_new_case_number VARCHAR(20)
)
LANGUAGE SQL
BEGIN ATOMIC
    DECLARE v_case_id CHAR(36);
    DECLARE v_case_num VARCHAR(20);

    SET v_case_id = gen_uuid();
    SET v_case_num = gen_case_number();

    INSERT INTO cases (
        case_id, case_number, title, description,
        status, priority, lead_officer_id, incident_date
    ) VALUES (
        v_case_id, v_case_num, p_title, p_description,
        'OPEN', p_priority, p_officer_id, CURRENT_TIMESTAMP
    );

    SET p_new_case_id = v_case_id;
    SET p_new_case_number = v_case_num;
END;

-- Update Evidence Status
CREATE PROCEDURE sp_update_evidence_status(
    IN p_evidence_id CHAR(36),
    IN p_new_status VARCHAR(20),
    IN p_officer_id CHAR(36),
    IN p_notes VARCHAR(1000)
)
LANGUAGE SQL
BEGIN ATOMIC
    DECLARE v_current_status VARCHAR(20);

    SELECT chain_status INTO v_current_status
    FROM evidence WHERE evidence_id = p_evidence_id;

    IF v_current_status = 'DESTROYED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot update destroyed evidence';
    END IF;

    UPDATE evidence
    SET chain_status = p_new_status, updated_at = CURRENT_TIMESTAMP
    WHERE evidence_id = p_evidence_id;

    INSERT INTO evidence_chain (
        evidence_id, prev_status, new_status, handled_by, notes
    ) VALUES (
        p_evidence_id, v_current_status, p_new_status, p_officer_id, p_notes
    );
END;

-- Archive Old Cases
CREATE PROCEDURE sp_archive_old_cases()
LANGUAGE SQL
BEGIN ATOMIC
    UPDATE cases
    SET status = 'ARCHIVED'
    WHERE status = 'CLOSED'
      AND updated_at < CURRENT_DATE - INTERVAL '365' DAY;
END;

/*
--------------------------------------------------------------------------------
ENHANCEMENT PROCEDURES
--------------------------------------------------------------------------------
*/

-- Add Case Note
CREATE PROCEDURE sp_add_case_note(
    IN p_case_id CHAR(36),
    IN p_officer_id CHAR(36),
    IN p_note_text VARCHAR(4000),
    IN p_is_sensitive INTEGER
)
LANGUAGE SQL
BEGIN ATOMIC
    INSERT INTO case_notes (note_id, case_id, officer_id, note_text, is_sensitive)
    VALUES (gen_uuid(), p_case_id, p_officer_id, p_note_text, p_is_sensitive);
END;

-- Issue Warrant
CREATE PROCEDURE sp_issue_warrant(
    IN p_case_id CHAR(36),
    IN p_suspect_id CHAR(36),
    IN p_type VARCHAR(50),
    IN p_judge VARCHAR(100),
    IN p_desc VARCHAR(1000),
    OUT p_warrant_id CHAR(36)
)
LANGUAGE SQL
BEGIN ATOMIC
    DECLARE v_id CHAR(36);
    SET v_id = gen_uuid();
    
    INSERT INTO warrants (warrant_id, case_id, suspect_id, warrant_type, issued_by_judge, description)
    VALUES (v_id, p_case_id, p_suspect_id, p_type, p_judge, p_desc);
    
    SET p_warrant_id = v_id;
END;
