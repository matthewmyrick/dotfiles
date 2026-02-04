-- Users and Permissions
-- Shows all database users/roles and their privileges

-- All roles and their attributes
SELECT
    rolname AS role,
    rolsuper AS superuser,
    rolcreaterole AS can_create_roles,
    rolcreatedb AS can_create_db,
    rolcanlogin AS can_login,
    rolreplication AS replication,
    rolconnlimit AS connection_limit,
    rolvaliduntil AS password_expires
FROM pg_roles
ORDER BY rolname;

-- Who has access to what tables
SELECT
    grantee,
    table_schema AS schema,
    table_name AS table,
    string_agg(privilege_type, ', ') AS privileges
FROM information_schema.table_privileges
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
GROUP BY grantee, table_schema, table_name
ORDER BY grantee, table_schema, table_name;
