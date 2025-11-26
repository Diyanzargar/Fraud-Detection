# Fraud Detection & Crime Investigation Database

## Project Overview
This project is a professional-grade **Crime Record & Investigation Management System** designed to handle complex fraud detection cases and criminal investigations. Built entirely in **SQL**, it features enterprise-level security, immutable audit trails, and strict evidence chain-of-custody management.

The system is architected to support sensitive data handling with column-level encryption readiness and role-based access control (RBAC), making it suitable for law enforcement and internal fraud investigation units.

## Key Features

### 🔒 Enterprise Security
-   **Encryption Metadata**: dedicated schema support for managing encryption keys (`encryption_keys_meta`) to protect PII (Personally Identifiable Information) like names and national IDs.
-   **Role-Based Access Control**: Pre-defined roles (`investigator`, `evidence_manager`, `auditor`) with granular permissions.
-   **Immutable Audit Logs**: Automatic triggers (`trg_audit_cases_after_update`) capture every change to critical case data.

### ⛓️ Evidence Integrity
-   **Chain of Custody**: A dedicated `evidence_chain` table tracks every movement of physical evidence.
-   **Tamper-Proofing**: Triggers (`trg_protect_evidence_chain`) prevent deletion or modification of historical chain-of-custody records, ensuring legal admissibility.

### 🕵️‍♂️ Advanced Investigation Tools
-   **Case Management**: Comprehensive tracking of cases, suspects, victims, and warrants.
-   **Link Analysis**: Many-to-Many relationships (`case_suspects`) allow investigators to map complex fraud rings across multiple cases.
-   **Workload Analytics**: Built-in views (`vw_officer_workload`) to monitor investigator performance and case distribution.

## Database Structure

### Core Modules
1.  **Schema & DDL** (`01_schema.sql`): Defines the normalized tables including `cases`, `suspects`, `officers`, and `evidence`.
2.  **Procedures** (`02_procedures.sql`): Stored procedures for standardized operations like `sp_create_case` and `sp_issue_warrant`.
3.  **Triggers** (`03_triggers.sql`): Automates auditing and enforces business rules.
4.  **Views** (`04_views.sql`): Provides analytical dashboards for unsolved cases and officer metrics.

### Key Tables
-   `cases`: Central repository for investigation details.
-   `suspects`: Profiles of individuals under investigation (with risk levels).
-   `evidence`: Inventory of physical and digital evidence.
-   `warrants`: Legal authorization tracking.
-   `audit_log`: System-wide activity tracking.

## Getting Started

### Prerequisites
-   A SQL-compliant database (PostgreSQL, MySQL, or similar).

### Installation
1.  **Initialize Schema**:
    Run `01_schema.sql` to build the table structure.
    ```sql
    \i 01_schema.sql
    ```

2.  **Load Logic**:
    Run `02_procedures.sql` and `03_triggers.sql` to install the application logic.

3.  **Populate Data**:
    Run `05_seed_data.sql` to load the initial dataset.

4.  **Verify**:
    Check the installation by querying the `vw_officer_workload` view.

## Author
**Diyan Zargar**
