-- Queueing locks with multiple active jobs (potential conflicts)
SELECT
    queueing_lock,
    queue_name,
    COUNT(*) AS active_jobs,
    ARRAY_AGG(id ORDER BY id) AS job_ids,
    ARRAY_AGG(status ORDER BY id) AS statuses
FROM procrastinate_jobs
WHERE status IN ('todo', 'doing')
  AND queueing_lock IS NOT NULL
GROUP BY queueing_lock, queue_name
HAVING COUNT(*) > 1
ORDER BY active_jobs DESC;
