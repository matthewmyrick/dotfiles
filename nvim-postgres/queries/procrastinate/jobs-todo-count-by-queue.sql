-- Count of jobs in todo status for a specific queue
-- Replace <QUEUE_NAME> with the target queue name
SELECT COUNT(*) AS todo_count
FROM procrastinate_jobs
WHERE status = 'todo'
  AND queue_name = '<QUEUE_NAME>';
