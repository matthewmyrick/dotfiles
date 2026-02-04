-- Database Statistics
-- Overview of database health and performance

SELECT
    datname AS database,
    numbackends AS active_connections,
    xact_commit AS commits,
    xact_rollback AS rollbacks,
    blks_read AS disk_reads,
    blks_hit AS cache_hits,
    ROUND(
        CASE WHEN blks_read + blks_hit = 0 THEN 0
        ELSE blks_hit::numeric / (blks_read + blks_hit) * 100
        END, 2
    ) AS cache_hit_ratio,
    tup_returned AS rows_returned,
    tup_fetched AS rows_fetched,
    tup_inserted AS rows_inserted,
    tup_updated AS rows_updated,
    tup_deleted AS rows_deleted,
    deadlocks,
    pg_size_pretty(pg_database_size(datname)) AS db_size
FROM pg_stat_database
WHERE datname NOT LIKE 'template%'
ORDER BY pg_database_size(datname) DESC;
