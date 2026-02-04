-- Slow Running Queries
-- Shows queries that have been running for more than 5 seconds

SELECT
    pid,
    usename AS username,
    datname AS database,
    state,
    NOW() - query_start AS duration,
    wait_event_type,
    wait_event,
    query
FROM pg_stat_activity
WHERE state = 'active'
    AND NOW() - query_start > INTERVAL '5 seconds'
ORDER BY duration DESC;
