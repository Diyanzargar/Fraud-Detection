/*
================================================================================
MODULE 01: SCHEMA & DDL
================================================================================
*/

-- Create Schema
CREATE SCHEMA IF NOT EXISTS crime_db;

-- Sequences
CREATE SEQUENCE seq_case_number_id START WITH 1 INCREMENT BY 1;

/*
--------------------------------------------------------------------------------
TABLES
--------------------------------------------------------------------------------
*/

-- Encryption Keys
CREATE TABLE encryption_keys_meta (
    key_id          CHAR(36) NOT NULL PRIMARY KEY,
    algorithm       VARCHAR(50) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active       INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
    kms_reference   VARCHAR(255)
);

-- Officers
CREATE TABLE officers (
    officer_id      CHAR(36) NOT NULL PRIMARY KEY,
    badge_number    VARCHAR(20) NOT NULL UNIQUE,
    first_name      VARCHAR(100) NOT NULL, -- ENCRYPT
    last_name       VARCHAR(100) NOT NULL, -- ENCRYPT
    rank            VARCHAR(50) NOT NULL,
    unit            VARCHAR(50),
    status          VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'RETIRED', 'SUSPENDED')),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Suspects
CREATE TABLE suspects (
    suspect_id      CHAR(36) NOT NULL PRIMARY KEY,
    first_name      VARCHAR(100) NOT NULL, -- ENCRYPT
    last_name       VARCHAR(100) NOT NULL, -- ENCRYPT
    date_of_birth   DATE,                  -- ENCRYPT
    national_id     VARCHAR(50),           -- ENCRYPT
    biometric_hash  VARCHAR(255),
    risk_level      VARCHAR(20) DEFAULT 'UNKNOWN' CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cases
CREATE TABLE cases (
    case_id         CHAR(36) NOT NULL PRIMARY KEY,
    case_number     VARCHAR(20) NOT NULL UNIQUE,
    title           VARCHAR(255) NOT NULL,
    description     VARCHAR(4000),
    status          VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_PROGRESS', 'COLD', 'CLOSED', 'ARCHIVED')),
    priority        VARCHAR(10) DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'CRITICAL')),
    lead_officer_id CHAR(36),
    incident_date   TIMESTAMP,
    location_lat    DECIMAL(9,6),
    location_long   DECIMAL(9,6),
    location_text   VARCHAR(255),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lead_officer_id) REFERENCES officers(officer_id)
);

-- Evidence
CREATE TABLE evidence (
    evidence_id     CHAR(36) NOT NULL PRIMARY KEY,
    case_id         CHAR(36) NOT NULL,
    item_type       VARCHAR(50) NOT NULL,
    description     VARCHAR(1000) NOT NULL,
    storage_location VARCHAR(255) NOT NULL, -- ENCRYPT
    chain_status    VARCHAR(20) DEFAULT 'COLLECTED' CHECK (chain_status IN ('COLLECTED', 'IN_CUSTODY', 'TRANSIT', 'LAB', 'COURT', 'DESTROYED')),
    collected_by    CHAR(36) NOT NULL,
    collected_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    FOREIGN KEY (collected_by) REFERENCES officers(officer_id)
);

-- Associations
CREATE TABLE case_suspects (
    case_id         CHAR(36) NOT NULL,
    suspect_id      CHAR(36) NOT NULL,
    role            VARCHAR(50) DEFAULT 'SUSPECT',
    added_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes           VARCHAR(1000),
    PRIMARY KEY (case_id, suspect_id),
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    FOREIGN KEY (suspect_id) REFERENCES suspects(suspect_id)
);

CREATE TABLE case_officers (
    case_id         CHAR(36) NOT NULL,
    officer_id      CHAR(36) NOT NULL,
    role            VARCHAR(50) DEFAULT 'INVESTIGATOR',
    assigned_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (case_id, officer_id),
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    FOREIGN KEY (officer_id) REFERENCES officers(officer_id)
);

-- System Tables
CREATE TABLE audit_log (
    audit_id        CHAR(36) NOT NULL PRIMARY KEY,
    table_name      VARCHAR(50) NOT NULL,
    record_id       CHAR(36) NOT NULL,
    action          VARCHAR(10) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values      VARCHAR(4000),
    new_values      VARCHAR(4000),
    changed_by      VARCHAR(100) NOT NULL,
    changed_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE evidence_chain (
    chain_id        INTEGER NOT NULL,
    evidence_id     CHAR(36) NOT NULL,
    prev_status     VARCHAR(20),
    new_status      VARCHAR(20) NOT NULL,
    handled_by      CHAR(36) NOT NULL,
    custody_start   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    custody_end     TIMESTAMP,
    notes           VARCHAR(1000),
    PRIMARY KEY (chain_id),
    FOREIGN KEY (evidence_id) REFERENCES evidence(evidence_id),
    FOREIGN KEY (handled_by) REFERENCES officers(officer_id)
);

CREATE TABLE schema_migrations (
    version         VARCHAR(50) NOT NULL PRIMARY KEY,
    applied_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description     VARCHAR(255)
);

/*
--------------------------------------------------------------------------------
INDEXES
--------------------------------------------------------------------------------
*/
CREATE INDEX idx_cases_status ON cases(status);
CREATE INDEX idx_cases_lead_officer ON cases(lead_officer_id);
CREATE INDEX idx_cases_incident_date ON cases(incident_date);
CREATE INDEX idx_evidence_case_id ON evidence(case_id);
CREATE INDEX idx_case_suspects_suspect ON case_suspects(suspect_id);
CREATE INDEX idx_suspects_lastname ON suspects(last_name);
CREATE INDEX idx_officers_badge ON officers(badge_number);

/*
--------------------------------------------------------------------------------
ENHANCEMENTS (NOTES, VICTIMS, WARRANTS)
--------------------------------------------------------------------------------
*/

-- Case Notes (Investigative Log)
CREATE TABLE case_notes (
    note_id         CHAR(36) NOT NULL PRIMARY KEY,
    case_id         CHAR(36) NOT NULL,
    officer_id      CHAR(36) NOT NULL,
    note_text       VARCHAR(4000) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_sensitive    INTEGER DEFAULT 0 CHECK (is_sensitive IN (0, 1)),
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    FOREIGN KEY (officer_id) REFERENCES officers(officer_id)
);

-- Victims
CREATE TABLE victims (
    victim_id       CHAR(36) NOT NULL PRIMARY KEY,
    case_id         CHAR(36) NOT NULL,
    first_name      VARCHAR(100) NOT NULL, -- ENCRYPT
    last_name       VARCHAR(100) NOT NULL, -- ENCRYPT
    date_of_birth   DATE,                  -- ENCRYPT
    contact_info    VARCHAR(255),          -- ENCRYPT
    relation_to_suspect VARCHAR(100),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(case_id)
);

-- Warrants
CREATE TABLE warrants (
    warrant_id      CHAR(36) NOT NULL PRIMARY KEY,
    case_id         CHAR(36) NOT NULL,
    suspect_id      CHAR(36), -- Nullable (e.g., search warrant for location)
    warrant_type    VARCHAR(50) NOT NULL CHECK (warrant_type IN ('SEARCH', 'ARREST', 'SURVEILLANCE')),
    status          VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'SERVED', 'EXPIRED', 'RECALLED')),
    issued_by_judge VARCHAR(100) NOT NULL,
    issued_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    served_at       TIMESTAMP,
    description     VARCHAR(1000),
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    FOREIGN KEY (suspect_id) REFERENCES suspects(suspect_id)
);

-- Indexes for Enhancements
CREATE INDEX idx_case_notes_case ON case_notes(case_id);
CREATE INDEX idx_victims_case ON victims(case_id);
CREATE INDEX idx_warrants_case ON warrants(case_id);
CREATE INDEX idx_warrants_suspect ON warrants(suspect_id);
