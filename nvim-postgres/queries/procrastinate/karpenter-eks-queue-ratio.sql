-- Karpenter EKS Queue Ratio
-- Ratio of todo (eligible to run within 5 minutes) to in-progress jobs for a queue
-- Replace <QUEUE_NAME> with the target queue name
SELECT
  COALESCE(
    (
      SELECT
        count(
          DISTINCT COALESCE(
            lock,
            id::text
          )
        )
      FROM
        procrastinate_jobs
      WHERE
        status = 'todo'
        AND queue_name = '<QUEUE_NAME>'
        AND (
          scheduled_at <= NOW() + INTERVAL '5 minutes'
          OR scheduled_at IS NULL
        )
    )::float / GREATEST(
      (
        SELECT
          count(
            DISTINCT COALESCE(
              lock,
              id::text
            )
          )
        FROM
          procrastinate_jobs
        WHERE
          status = 'doing'
          AND queue_name = '<QUEUE_NAME>'
      ),
      1
    ),
    0
  ) AS queue_ratio;
