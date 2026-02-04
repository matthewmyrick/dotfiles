-- Vacuum & Dead Tuple Stats
-- Shows tables that need vacuuming (high dead tuple count)

SELECT
    schemaname AS schema,
    relname AS table,
    n_live_tup AS live_rows,
    n_dead_tup AS dead_rows,
    ROUND(
        CASE WHEN n_live_tup = 0 THEN 0
        ELSE n_dead_tup::numeric / n_live_tup * 100
        END, 2
    ) AS dead_pct,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;
