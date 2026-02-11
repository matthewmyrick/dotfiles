-- Jobs stuck in "doing" status for more than 1 hour
-- Uses procrastinate_events to find when the job started executing
SELECT
    j.id,
    j.queue_name,
    j.task_name,
    j.attempts,
    e.at AS started_doing_at,
    NOW() - e.at AS duration,
    j.args
FROM procrastinate_jobs j
JOIN procrastinate_events e ON e.job_id = j.id AND e.type = 'started'
WHERE j.status = 'doing'
  AND e.at < NOW() - INTERVAL '1 hour'
ORDER BY e.at ASC;
