INSERT INTO permissions (name, description)
VALUES ('AUDIT_READ', 'Read audit logs')
ON CONFLICT (name) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.name = 'AUDIT_READ'
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING;
