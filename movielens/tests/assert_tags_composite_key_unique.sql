-- Singular test: The composite key (user_id, movie_id, timestamp) must be unique in the tags model.
-- A user can apply multiple tags to the same movie, but each tag event
-- is distinguished by its timestamp, so this combination should be unique.
-- The test fails if any duplicate composite keys are found.
{{ 
    config(
        severity = 'warn'
    )
}}

SELECT
    user_id,
    movie_id,
    timestamp,
    COUNT(*) AS duplicate_count
FROM {{ ref('tags') }}
GROUP BY user_id, movie_id, timestamp
HAVING COUNT(*) > 1
