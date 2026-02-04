-- Active Connections
-- Shows all current database connections, what they're doing, and how long they've been running

SELECT
    pid,
    usename AS username,
    datname AS database,
    client_addr AS client_ip,
    state,
    query_start,
    NOW() - query_start AS duration,
    wait_event_type,
    wait_event,
    LEFT(query, 100) AS query_preview
FROM pg_stat_activity
WHERE state IS NOT NULL
ORDER BY query_start ASC;
