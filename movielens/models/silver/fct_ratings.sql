WITH source AS (
    SELECT * FROM {{ ref('ratings') }}
),

deduped AS (
    SELECT
        user_id,
        movie_id,
        rating,
        _loaded_at,
        TO_TIMESTAMP_NTZ(timestamp) AS rated_at
    FROM source
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_id, movie_id
        ORDER BY timestamp DESC
    ) = 1
)

SELECT
    user_id,
    movie_id,
    rating,
    rated_at,
    _loaded_at
FROM deduped
