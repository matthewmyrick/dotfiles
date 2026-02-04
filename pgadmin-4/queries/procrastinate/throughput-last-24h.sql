-- Job throughput per queue in the last 24 hours (completed jobs)
-- Uses procrastinate_events to find when jobs started
SELECT
    j.queue_name,
    COUNT(*) AS completed,
    MIN(j.scheduled_at) AS earliest_scheduled,
    MAX(j.scheduled_at) AS latest_scheduled
FROM procrastinate_jobs j
WHERE j.status = 'succeeded'
  AND j.scheduled_at >= NOW() - INTERVAL '24 hours'
GROUP BY j.queue_name
ORDER BY completed DESC;
