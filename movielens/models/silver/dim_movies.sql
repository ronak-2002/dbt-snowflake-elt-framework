WITH active_movies AS (
    SELECT
        dbt_scd_id AS movie_version_key,
        movie_id,
        title,
        genres,
        _loaded_at,
        dbt_valid_from
    FROM {{ ref('movies_snapshot') }}
    WHERE dbt_valid_to IS NULL
),

transformed AS (
    SELECT
        movie_version_key,
        movie_id,
        _loaded_at,
        dbt_valid_from,
        TRIM(REGEXP_REPLACE(title, '\\s*\\(\\d{4}\\)[^()]*$', '')) AS movie_name,
        TRY_CAST(REGEXP_SUBSTR(title, '\\((\\d{4})\\)[^()]*$', 1, 1, 'e', 1) AS INTEGER) AS release_year
    FROM active_movies
)

SELECT
    movie_version_key,
    movie_id,
    movie_name,
    release_year,
    _loaded_at,
    dbt_valid_from
FROM transformed
