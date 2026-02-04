-- Jobs with the most retry attempts
SELECT
    id,
    queue_name,
    task_name,
    status,
    attempts,
    scheduled_at,
    args
FROM procrastinate_jobs
WHERE attempts > 1
ORDER BY attempts DESC
LIMIT 50;
