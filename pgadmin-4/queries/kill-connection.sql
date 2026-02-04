-- Kill Connection / Terminate PID
-- Use these to cancel or terminate problem connections
--
-- IMPORTANT: Replace <PID> with the actual process ID from active-connections.sql

-- Option 1: GRACEFUL - Cancel the current query (lets the connection live)
-- SELECT pg_cancel_backend(<PID>);

-- Option 2: FORCE - Terminate the entire connection
-- SELECT pg_terminate_backend(<PID>);

-- Kill all connections to a specific database (except yours)
-- SELECT pg_terminate_backend(pid)
-- FROM pg_stat_activity
-- WHERE datname = 'your_database_name'
--   AND pid <> pg_backend_pid();

-- Kill all connections from a specific user (except yours)
-- SELECT pg_terminate_backend(pid)
-- FROM pg_stat_activity
-- WHERE usename = 'problem_user'
--   AND pid <> pg_backend_pid();

-- Kill all idle connections older than 10 minutes
-- SELECT pg_terminate_backend(pid)
-- FROM pg_stat_activity
-- WHERE state = 'idle'
--   AND NOW() - state_change > INTERVAL '10 minutes'
--   AND pid <> pg_backend_pid();

-- First, see what you're about to kill (always run this before the above):
SELECT
    pid,
    usename AS username,
    datname AS database,
    state,
    NOW() - query_start AS duration,
    LEFT(query, 100) AS query_preview
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
ORDER BY state, duration DESC;
