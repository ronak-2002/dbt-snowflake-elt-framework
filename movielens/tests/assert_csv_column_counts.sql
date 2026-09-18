-- Singular test: The number of columns in each source CSV file must equal the
-- number of non-metadata columns defined in the corresponding bronze model.
-- Uses the named CSV_FORMAT (SKIP_HEADER=1) to read data rows and checks
-- positional columns to verify column count:
--   - If $N+1 IS NOT NULL for any row -> CSV has MORE columns than expected
--   - If $N IS NULL for ALL rows     -> CSV has FEWER columns than expected
--
-- Expected non-metadata columns per model:
--   movies        -> 3  (movie_id, title, genres)
--   ratings       -> 4  (user_id, movie_id, rating, timestamp)
--   tags          -> 4  (user_id, movie_id, tag, timestamp)
--   genome_scores -> 3  (movie_id, tag_id, relevance)
--   genome_tags   -> 2  (tag_id, tag)
--   links         -> 3  (movie_id, imdb_id, tmdb_id)

{% set csv_format = source('raw_data', 'raw_movies').database ~ '.' ~ source('raw_data', 'raw_movies').schema ~ '.CSV_FORMAT' %}

SELECT
    'movies' AS model_name,
    3 AS expected_col_count,
    COUNT(CASE WHEN $4 IS NOT NULL THEN 1 END) AS extra_col_rows,
    COUNT($3) AS last_col_rows
FROM @{{ source('raw_data', 'raw_movies') }}
    (FILE_FORMAT => '{{ csv_format }}')
GROUP BY 1, 2
HAVING COUNT(CASE WHEN $4 IS NOT NULL THEN 1 END) > 0
    OR COUNT($3) = 0

UNION ALL

SELECT
    'ratings',
    4,
    COUNT(CASE WHEN $5 IS NOT NULL THEN 1 END),
    COUNT($4)
FROM @{{ source('raw_data', 'raw_ratings') }}
    (FILE_FORMAT => '{{ csv_format }}')
GROUP BY 1, 2
HAVING COUNT(CASE WHEN $5 IS NOT NULL THEN 1 END) > 0
    OR COUNT($4) = 0

UNION ALL

SELECT
    'tags',
    4,
    COUNT(CASE WHEN $5 IS NOT NULL THEN 1 END),
    COUNT($4)
FROM @{{ source('raw_data', 'raw_tags') }}
    (FILE_FORMAT => '{{ csv_format }}')
GROUP BY 1, 2
HAVING COUNT(CASE WHEN $5 IS NOT NULL THEN 1 END) > 0
    OR COUNT($4) = 0

UNION ALL

SELECT
    'genome_scores',
    3,
    COUNT(CASE WHEN $4 IS NOT NULL THEN 1 END),
    COUNT($3)
FROM @{{ source('raw_data', 'raw_genome_scores') }}
    (FILE_FORMAT => '{{ csv_format }}')
GROUP BY 1, 2
HAVING COUNT(CASE WHEN $4 IS NOT NULL THEN 1 END) > 0
    OR COUNT($3) = 0

UNION ALL

SELECT
    'genome_tags',
    2,
    COUNT(CASE WHEN $3 IS NOT NULL THEN 1 END),
    COUNT($2)
FROM @{{ source('raw_data', 'raw_genome_tags') }}
    (FILE_FORMAT => '{{ csv_format }}')
GROUP BY 1, 2
HAVING COUNT(CASE WHEN $3 IS NOT NULL THEN 1 END) > 0
    OR COUNT($2) = 0

UNION ALL

SELECT
    'links',
    3,
    COUNT(CASE WHEN $4 IS NOT NULL THEN 1 END),
    COUNT($3)
FROM @{{ source('raw_data', 'raw_links') }}
    (FILE_FORMAT => '{{ csv_format }}')
GROUP BY 1, 2
HAVING COUNT(CASE WHEN $4 IS NOT NULL THEN 1 END) > 0
    OR COUNT($3) = 0
