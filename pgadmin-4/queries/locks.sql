-- Lock Monitoring
-- Shows current locks and what's blocking what

SELECT
    blocked.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    LEFT(blocked_activity.query, 80) AS blocked_query,
    blocking.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    LEFT(blocking_activity.query, 80) AS blocking_query,
    NOW() - blocked_activity.query_start AS blocked_duration
FROM pg_catalog.pg_locks blocked
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked.pid
JOIN pg_catalog.pg_locks blocking ON blocking.locktype = blocked.locktype
    AND blocking.database IS NOT DISTINCT FROM blocked.database
    AND blocking.relation IS NOT DISTINCT FROM blocked.relation
    AND blocking.page IS NOT DISTINCT FROM blocked.page
    AND blocking.tuple IS NOT DISTINCT FROM blocked.tuple
    AND blocking.virtualxid IS NOT DISTINCT FROM blocked.virtualxid
    AND blocking.transactionid IS NOT DISTINCT FROM blocked.transactionid
    AND blocking.classid IS NOT DISTINCT FROM blocked.classid
    AND blocking.objid IS NOT DISTINCT FROM blocked.objid
    AND blocking.objsubid IS NOT DISTINCT FROM blocked.objsubid
    AND blocking.pid != blocked.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking.pid
WHERE NOT blocked.granted
ORDER BY blocked_duration DESC;
