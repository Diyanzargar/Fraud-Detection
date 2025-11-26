/*
================================================================================
MODULE 04: VIEWS & REPORTS
================================================================================
*/

-- Officer Workload
CREATE VIEW vw_officer_workload AS
SELECT
    o.officer_id,
    o.badge_number,
    o.last_name,
    COUNT(c.case_id) AS active_cases
FROM officers o
LEFT JOIN cases c ON o.officer_id = c.lead_officer_id AND c.status IN ('OPEN', 'IN_PROGRESS')
GROUP BY o.officer_id, o.badge_number, o.last_name;

-- Unsolved Cases Aging
CREATE VIEW vw_unsolved_cases_aging AS
SELECT
    c.case_number,
    c.title,
    c.incident_date,
    c.status,
    CAST(CURRENT_DATE - CAST(c.incident_date AS DATE) AS INTEGER) AS days_open
FROM cases c
WHERE c.status IN ('OPEN', 'IN_PROGRESS')
  AND c.incident_date < CURRENT_DATE - INTERVAL '30' DAY;

/*
--------------------------------------------------------------------------------
COMMON QUERIES (Examples)
--------------------------------------------------------------------------------
-- Solved vs Unsolved
SELECT status, COUNT(*) as total_cases FROM cases GROUP BY status;

-- Suspect Link Analysis
SELECT s.last_name, COUNT(cs.case_id) as case_count
FROM suspects s JOIN case_suspects cs ON s.suspect_id = cs.suspect_id
GROUP BY s.suspect_id, s.last_name HAVING COUNT(cs.case_id) > 1;
*/
