-- Singular test: Timestamp fields in ratings and tags must not be in the future.
-- Both models store timestamps as Unix epoch seconds (BIGINT).
-- The test converts them to TIMESTAMP and compares against CURRENT_TIMESTAMP().
-- The test fails if any timestamp value is later than the current time.

WITH future_rating_timestamps AS (
    SELECT
        'ratings' AS model_name,
        user_id,
        movie_id,
        timestamp AS epoch_value,
        TO_TIMESTAMP(timestamp) AS timestamp_value
    FROM {{ ref('ratings') }}
    WHERE TO_TIMESTAMP(timestamp) > CURRENT_TIMESTAMP()
),

future_tag_timestamps AS (
    SELECT
        'tags' AS model_name,
        user_id,
        movie_id,
        timestamp AS epoch_value,
        TO_TIMESTAMP(timestamp) AS timestamp_value
    FROM {{ ref('tags') }}
    WHERE TO_TIMESTAMP(timestamp) > CURRENT_TIMESTAMP()
)

SELECT * FROM future_rating_timestamps
UNION ALL
SELECT * FROM future_tag_timestamps
