-- List jobs for a specific queue
-- Replace <QUEUE_NAME> with the target queue name
SELECT
    id,
    task_name,
    status,
    attempts,
    queueing_lock,
    scheduled_at,
    abort_requested
FROM procrastinate_jobs
WHERE queue_name = '<QUEUE_NAME>'
ORDER BY id DESC
LIMIT 50;
