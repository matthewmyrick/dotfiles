-- Queue overview: job counts by queue and status
SELECT
    queue_name,
    COUNT(*) FILTER (WHERE status = 'todo')      AS todo,
    COUNT(*) FILTER (WHERE status = 'doing')     AS doing,
    COUNT(*) FILTER (WHERE status = 'succeeded') AS succeeded,
    COUNT(*) FILTER (WHERE status = 'failed')    AS failed,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled,
    COUNT(*)                                      AS total
FROM procrastinate_jobs
GROUP BY queue_name
ORDER BY queue_name;
