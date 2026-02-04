-- Recent event timeline across all jobs (last 100 events)
SELECT
    e.id AS event_id,
    e.job_id,
    e.type,
    e.at,
    j.queue_name,
    j.task_name,
    j.status AS current_status
FROM procrastinate_events e
JOIN procrastinate_jobs j ON j.id = e.job_id
ORDER BY e.at DESC
LIMIT 100;
