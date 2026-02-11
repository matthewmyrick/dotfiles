-- Job counts by task name and status
SELECT
    task_name,
    COUNT(*) FILTER (WHERE status = 'todo')      AS todo,
    COUNT(*) FILTER (WHERE status = 'doing')     AS doing,
    COUNT(*) FILTER (WHERE status = 'succeeded') AS succeeded,
    COUNT(*) FILTER (WHERE status = 'failed')    AS failed,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled,
    COUNT(*)                                      AS total
FROM procrastinate_jobs
GROUP BY task_name
ORDER BY total DESC;
