WITH src_movies AS (
    SELECT * FROM {{ source('raw_data', 'raw_movies') }}
)
SELECT * FROM src_movies