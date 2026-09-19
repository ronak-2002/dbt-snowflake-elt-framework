WITH source AS (
    SELECT * FROM {{ ref('tags') }}
),

deduped AS (
    SELECT
        user_id,
        movie_id,
        _loaded_at,
        TRIM(tag) AS tag,
        TO_TIMESTAMP_NTZ(timestamp) AS tagged_at
    FROM source
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_id, movie_id, tag
        ORDER BY timestamp DESC
    ) = 1
)

SELECT
    user_id,
    movie_id,
    tag,
    tagged_at,
    _loaded_at
FROM deduped
