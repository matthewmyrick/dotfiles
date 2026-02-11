-- Event history for a single job
-- Replace <JOB_ID> with the job id
SELECT
    e.id,
    e.job_id,
    e.type,
    e.at
FROM procrastinate_events e
WHERE e.job_id = <JOB_ID>
ORDER BY e.at ASC;
