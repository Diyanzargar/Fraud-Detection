/*
================================================================================
CRIME INVESTIGATION SYSTEM - MASTER INSTALL SCRIPT
================================================================================
Usage:
Run this script to install the entire database system.
Ensure you have appropriate permissions.
*/

-- 1. Schema & Tables
\i 01_schema.sql

-- 2. Procedures & Security
\i 02_procedures.sql

-- 3. Triggers
\i 03_triggers.sql

-- 4. Views
\i 04_views.sql

-- 5. Seed Data (Generated)
\i 05_seed_data.sql

PRINT 'Installation Complete.';
