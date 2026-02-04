-- Jobs where abort has been requested
SELECT
    id,
    queue_name,
    task_name,
    status,
    attempts,
    scheduled_at,
    args
FROM procrastinate_jobs
WHERE abort_requested = true
ORDER BY id DESC;
