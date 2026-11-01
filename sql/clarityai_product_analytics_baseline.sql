-- ============================================================
-- ClarityAI Product Analytics Baseline
-- Snapshot date: 2026-10-03
--
-- OWNER ACCOUNTS EXCLUDED:
-- Owner UUID placeholders are used below; insert private UUIDs locally
-- before execution. Do not commit real identifiers to this public repository.
--
-- Purpose:
-- Establish a reproducible baseline of external-user behavior.
-- ============================================================


-- ============================================================
-- 1. BASIC PRODUCT FUNNEL
-- Measures:
-- - Total external registered users
-- - External users who ran at least one analysis
-- - External users who never ran an analysis
-- - Total external analyses
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
external_users AS (
  SELECT id
  FROM auth.users
  WHERE id NOT IN (SELECT id FROM owner_accounts)
),
external_analyses AS (
  SELECT a.*
  FROM analyses a
  WHERE a.user_id IN (SELECT id FROM external_users)
)

SELECT
  (SELECT COUNT(*) FROM external_users) AS external_registered_users,
  (SELECT COUNT(DISTINCT user_id) FROM external_analyses) AS external_users_who_analyzed,
  (SELECT COUNT(*) FROM external_users eu
   WHERE NOT EXISTS (
     SELECT 1
     FROM external_analyses ea
     WHERE ea.user_id = eu.id
   )
  ) AS external_users_never_analyzed,
  (SELECT COUNT(*) FROM external_analyses) AS external_total_analyses;


-- ============================================================
-- 2. ANALYSIS FREQUENCY
-- Measures how many external users analyzed 1, 2, 3, etc. times.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
user_analysis_counts AS (
  SELECT
    a.user_id,
    COUNT(*) AS analysis_count
  FROM analyses a
  WHERE a.user_id NOT IN (SELECT id FROM owner_accounts)
  GROUP BY a.user_id
)

SELECT
  analysis_count,
  COUNT(*) AS users
FROM user_analysis_counts
GROUP BY analysis_count
ORDER BY analysis_count;


-- ============================================================
-- 3. ONE-TIME VS REPEAT USERS
-- Measures:
-- - External users who analyzed exactly once
-- - External users who analyzed 2+ times
-- - Repeat-user percentage
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
user_analysis_counts AS (
  SELECT
    user_id,
    COUNT(*) AS analysis_count
  FROM analyses
  WHERE user_id NOT IN (SELECT id FROM owner_accounts)
  GROUP BY user_id
)

SELECT
  COUNT(*) AS external_users_who_analyzed,

  COUNT(*) FILTER (
    WHERE analysis_count = 1
  ) AS one_time_users,

  COUNT(*) FILTER (
    WHERE analysis_count >= 2
  ) AS repeat_users,

  ROUND(
    100.0 *
    COUNT(*) FILTER (WHERE analysis_count >= 2)
    / NULLIF(COUNT(*), 0),
    2
  ) AS repeat_user_percent

FROM user_analysis_counts;


-- ============================================================
-- 4. EXTERNAL ANALYSIS VOLUME
-- Measures how many analyses came from one-time vs repeat users.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
user_analysis_counts AS (
  SELECT
    user_id,
    COUNT(*) AS analysis_count
  FROM analyses
  WHERE user_id NOT IN (SELECT id FROM owner_accounts)
  GROUP BY user_id
)

SELECT
  COUNT(*) AS external_total_analyses,

  COUNT(*) FILTER (
    WHERE uac.analysis_count = 1
  ) AS analyses_from_one_time_users,

  COUNT(*) FILTER (
    WHERE uac.analysis_count >= 2
  ) AS analyses_from_repeat_users

FROM analyses a
JOIN user_analysis_counts uac
  ON uac.user_id = a.user_id
WHERE a.user_id NOT IN (SELECT id FROM owner_accounts);


-- ============================================================
-- 5. REPEAT ANALYSIS TIMING
-- Measures how quickly external users repeat an analysis.
--
-- A repeat analysis is compared with the user's immediately
-- preceding analysis.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
ordered_analyses AS (
  SELECT
    user_id,
    created_at,
    LAG(created_at) OVER (
      PARTITION BY user_id
      ORDER BY created_at
    ) AS previous_analysis_at
  FROM analyses
  WHERE user_id NOT IN (SELECT id FROM owner_accounts)
),
repeat_intervals AS (
  SELECT
    user_id,
    created_at,
    previous_analysis_at,
    EXTRACT(
      EPOCH FROM (created_at - previous_analysis_at)
    ) / 3600.0 AS hours_since_previous
  FROM ordered_analyses
  WHERE previous_analysis_at IS NOT NULL
)

SELECT
  COUNT(*) AS repeat_analyses,

  COUNT(*) FILTER (
    WHERE hours_since_previous <= 24
  ) AS within_24_hours,

  COUNT(*) FILTER (
    WHERE hours_since_previous <= 168
  ) AS within_7_days,

  ROUND(
    100.0 * COUNT(*) FILTER (
      WHERE hours_since_previous <= 24
    ) / NULLIF(COUNT(*), 0),
    2
  ) AS percent_within_24_hours,

  ROUND(
    100.0 * COUNT(*) FILTER (
      WHERE hours_since_previous <= 168
    ) / NULLIF(COUNT(*), 0),
    2
  ) AS percent_within_7_days

FROM repeat_intervals;


-- ============================================================
-- 6. ANALYSIS SCORE DISTRIBUTION
-- Measures minimum, average, median and maximum score.
-- External users only.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
)

SELECT
  MIN(score) AS minimum_score,
  ROUND(AVG(score), 2) AS average_score,
  PERCENTILE_CONT(0.5)
    WITHIN GROUP (ORDER BY score) AS median_score,
  MAX(score) AS maximum_score
FROM analyses
WHERE user_id NOT IN (SELECT id FROM owner_accounts);


-- ============================================================
-- 7. WEEKLY ANALYSIS ACTIVITY
-- Weekly aggregation reduces the disclosure risk of very small daily counts.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
)

SELECT
  DATE_TRUNC('week', created_at)::date AS analysis_week,
  COUNT(*) AS analyses,
  COUNT(DISTINCT user_id) AS unique_users
FROM analyses
WHERE user_id NOT IN (SELECT id FROM owner_accounts)
GROUP BY 1
ORDER BY analysis_week;


-- ============================================================
-- 8. EXTERNAL USERS WHO NEVER ANALYZED
-- Measures the signup date of users who registered but never
-- performed an analysis.
--
-- This output should NOT be published with emails/user IDs.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
)

SELECT
  COUNT(*) AS external_users_never_analyzed,
  DATE_TRUNC('month', MIN(u.created_at))::date AS earliest_signup_month,
  DATE_TRUNC('month', MAX(u.created_at))::date AS latest_signup_month
FROM auth.users u
WHERE u.id NOT IN (SELECT id FROM owner_accounts)
  AND NOT EXISTS (
    SELECT 1
    FROM analyses a
    WHERE a.user_id = u.id
  );


-- ============================================================
-- 9. JOB TRACKER ADOPTION
-- Measures external users who have created at least one
-- job application.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
external_users AS (
  SELECT id
  FROM auth.users
  WHERE id NOT IN (SELECT id FROM owner_accounts)
)

SELECT
  (SELECT COUNT(*) FROM external_users) AS external_registered_users,

  (SELECT COUNT(DISTINCT user_id)
   FROM job_applications
   WHERE user_id IN (SELECT id FROM external_users)
  ) AS users_using_tracker,

  (SELECT COUNT(*)
   FROM job_applications
   WHERE user_id IN (SELECT id FROM external_users)
  ) AS total_job_applications;


-- ============================================================
-- 10. TIME TO FIRST ANALYSIS
-- Measures how long external users take to reach the first
-- analysis after signup.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
first_analysis AS (
  SELECT
    a.user_id,
    MIN(a.created_at) AS first_analysis_at
  FROM analyses a
  WHERE a.user_id NOT IN (SELECT id FROM owner_accounts)
  GROUP BY a.user_id
),
user_activation AS (
  SELECT
    u.id,
    u.created_at AS signup_at,
    fa.first_analysis_at,
    EXTRACT(
      EPOCH FROM (fa.first_analysis_at - u.created_at)
    ) / 86400.0 AS days_to_first_analysis
  FROM auth.users u
  JOIN first_analysis fa
    ON fa.user_id = u.id
)

SELECT
  COUNT(*) AS external_analyzed_users,
  ROUND(AVG(days_to_first_analysis), 2) AS average_days_to_first_analysis,
  ROUND(
    PERCENTILE_CONT(0.5)
    WITHIN GROUP (ORDER BY days_to_first_analysis)::numeric,
    2
  ) AS median_days_to_first_analysis
FROM user_activation;


-- ============================================================
-- 11. SCORE CHANGE PER REPEATING USER
-- Measures whether a user's analysis score changes between
-- their first and latest analysis.
--
-- External users only.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
ranked_analyses AS (
  SELECT
    user_id,
    score,
    created_at,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at ASC
    ) AS first_rank,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at DESC
    ) AS latest_rank
  FROM analyses
  WHERE user_id NOT IN (SELECT id FROM owner_accounts)
),
user_score_change AS (
  SELECT
    user_id,
    MAX(score) FILTER (WHERE first_rank = 1) AS first_score,
    MAX(score) FILTER (WHERE latest_rank = 1) AS latest_score
  FROM ranked_analyses
  GROUP BY user_id
  HAVING COUNT(*) >= 2
)

SELECT
  COUNT(*) AS repeat_users,
  ROUND(AVG(first_score), 2) AS average_first_score,
  ROUND(AVG(latest_score), 2) AS average_latest_score,
  ROUND(AVG(latest_score - first_score), 2) AS average_score_change
FROM user_score_change;


-- ============================================================
-- 12. WEEKLY SIGNUP & ACTIVATION
-- Measures external user signups by week and how many of those
-- users have analyzed vs never analyzed.
--
-- External users only.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
)

SELECT
  DATE_TRUNC('week', u.created_at)::date AS signup_week,
  COUNT(*) AS signups,
  COUNT(*) FILTER (
    WHERE EXISTS (
      SELECT 1
      FROM analyses a
      WHERE a.user_id = u.id
    )
  ) AS analyzed,
  COUNT(*) FILTER (
    WHERE NOT EXISTS (
      SELECT 1
      FROM analyses a
      WHERE a.user_id = u.id
    )
  ) AS never_analyzed
FROM auth.users u
WHERE u.id NOT IN (SELECT id FROM owner_accounts)
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 13. WEEKLY ANALYSIS ACTIVITY (TOP USER EXCLUDED)
-- Measures weekly external analysis activity while excluding
-- the single highest-volume external user.
--
-- External users only.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
top_user AS (
  SELECT user_id
  FROM analyses
  WHERE user_id NOT IN (SELECT id FROM owner_accounts)
  GROUP BY user_id
  ORDER BY COUNT(*) DESC
  LIMIT 1
)

SELECT
  DATE_TRUNC('week', created_at)::date AS week,
  COUNT(*) AS analyses,
  COUNT(DISTINCT user_id) AS users
FROM analyses
WHERE user_id NOT IN (SELECT id FROM owner_accounts)
  AND user_id NOT IN (SELECT user_id FROM top_user)
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 14. SCORE CHANGE DISTRIBUTION (TOP USER EXCLUDED)
-- Measures how scores change between first and latest analysis
-- among repeating external users, excluding the single
-- highest-volume external user.
--
-- External users only.
-- ============================================================

WITH owner_accounts AS (
  -- Replace these placeholders with your own account UUIDs locally.
  -- Never commit real owner UUIDs or email addresses to a public repository.
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
),
top_user AS (
  SELECT user_id
  FROM analyses
  WHERE user_id NOT IN (SELECT id FROM owner_accounts)
  GROUP BY user_id
  ORDER BY COUNT(*) DESC
  LIMIT 1
),
ranked AS (
  SELECT
    user_id,
    score,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at ASC
    ) AS first_rank,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at DESC
    ) AS latest_rank
  FROM analyses
  WHERE user_id NOT IN (SELECT id FROM owner_accounts)
    AND user_id NOT IN (SELECT user_id FROM top_user)
),
changes AS (
  SELECT
    user_id,
    MAX(score) FILTER (WHERE first_rank = 1) AS first_score,
    MAX(score) FILTER (WHERE latest_rank = 1) AS latest_score
  FROM ranked
  GROUP BY user_id
  HAVING COUNT(*) >= 2
)

SELECT
  COUNT(*) AS repeat_users,
  COUNT(*) FILTER (
    WHERE latest_score > first_score
  ) AS improved,
  COUNT(*) FILTER (
    WHERE latest_score = first_score
  ) AS unchanged,
  COUNT(*) FILTER (
    WHERE latest_score < first_score
  ) AS declined,
  ROUND(
    AVG(latest_score - first_score),
    2
  ) AS avg_change,
  PERCENTILE_CONT(0.5)
    WITHIN GROUP (
      ORDER BY latest_score - first_score
    ) AS median_change
FROM changes;


-- ============================================================
-- 15. SCORE DATA COMPLETENESS
-- Measures total external analyses and how many have missing
-- score values.
--
-- External users only.
-- ============================================================

SELECT
  COUNT(*) AS total,
  COUNT(*) FILTER (
    WHERE score IS NULL
  ) AS null_scores
FROM analyses
WHERE user_id NOT IN (
  SELECT id
  FROM auth.users
  WHERE id IN (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid
  )
);