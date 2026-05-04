-- DBA admin user (superuser, used by pgAdmin and DBA tools)
-- Password is set via the create-db-admin.sh script or manually
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'db_admin') THEN
    CREATE ROLE db_admin
      WITH LOGIN
           SUPERUSER
           CREATEDB
           CREATEROLE
           PASSWORD 'dbadmin123';
    COMMENT ON ROLE db_admin IS 'DBA superuser for pgAdmin and maintenance tasks';
  END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE ecommerce TO db_admin;
