-- All failed jobs, most recent first
SELECT
    id,
    queue_name,
    task_name,
    attempts,
    queueing_lock,
    scheduled_at,
    args
FROM procrastinate_jobs
WHERE status = 'failed'
ORDER BY id DESC
LIMIT 50;
