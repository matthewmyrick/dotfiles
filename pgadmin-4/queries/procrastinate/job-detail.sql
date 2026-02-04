-- Full detail for a single job
-- Replace <JOB_ID> with the job id
SELECT
    j.id,
    j.queue_name,
    j.task_name,
    j.status,
    j.lock,
    j.queueing_lock,
    j.args,
    j.scheduled_at,
    j.attempts,
    j.abort_requested
FROM procrastinate_jobs j
WHERE j.id = <JOB_ID>;
