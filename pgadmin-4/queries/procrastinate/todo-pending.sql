-- Jobs waiting to be picked up (todo), oldest first
SELECT
    id,
    queue_name,
    task_name,
    scheduled_at,
    queueing_lock,
    args
FROM procrastinate_jobs
WHERE status = 'todo'
ORDER BY scheduled_at ASC
LIMIT 50;
