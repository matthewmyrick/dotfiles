-- Total count of jobs in todo status
SELECT COUNT(*) AS todo_count
FROM procrastinate_jobs
WHERE status = 'todo';
