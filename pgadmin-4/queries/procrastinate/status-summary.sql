-- Global status summary across all queues
SELECT
    status,
    COUNT(*) AS count
FROM procrastinate_jobs
GROUP BY status
ORDER BY count DESC;
