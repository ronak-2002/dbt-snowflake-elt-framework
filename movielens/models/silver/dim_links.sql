WITH source AS (
    SELECT * FROM {{ ref('links') }}
),

transformed AS (
    SELECT
        movie_id,
        imdb_id,
        tmdb_id,
        _loaded_at
    FROM source
)

SELECT * FROM transformed
