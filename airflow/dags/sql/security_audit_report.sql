CREATE SCHEMA IF NOT EXISTS reports;

CREATE OR REPLACE VIEW reports.security_audit_report AS
SELECT
    actor_email,
    action,
    resource_type,
    COUNT(*) AS event_count,
    MAX(created_at) AS last_seen_at
FROM staging.audit_logs
GROUP BY actor_email, action, resource_type
ORDER BY last_seen_at DESC;
