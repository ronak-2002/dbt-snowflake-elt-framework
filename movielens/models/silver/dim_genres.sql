WITH active_movies AS (
    SELECT
        movie_id,
        genres
    FROM {{ ref('movies_snapshot') }}
    WHERE dbt_valid_to IS NULL
),

flattened_genres AS (
    SELECT
        active_movies.movie_id,
        TRIM(f.value::VARCHAR) AS genre
    FROM active_movies,
        LATERAL FLATTEN(INPUT => SPLIT(active_movies.genres, '|')) AS f
)

SELECT
    movie_id,
    genre
FROM flattened_genres
WHERE genre IS NOT NULL AND genre != ''
