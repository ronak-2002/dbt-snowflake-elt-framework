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

-- Check for EXTRA columns (column N+1 has data when only N columns expected)

SELECT 'movies' AS model_name, 3 AS expected_col_count, 'csv has more columns than expected' AS issue
FROM @{{ source('raw_data', 'raw_movies') }}
    (FILE_FORMAT => '{{ csv_format }}')
WHERE $4 IS NOT NULL
LIMIT 1

UNION ALL

SELECT 'ratings', 4, 'csv has more columns than expected'
FROM @{{ source('raw_data', 'raw_ratings') }}
    (FILE_FORMAT => '{{ csv_format }}')
WHERE $5 IS NOT NULL
LIMIT 1

UNION ALL

SELECT 'tags', 4, 'csv has more columns than expected'
FROM @{{ source('raw_data', 'raw_tags') }}
    (FILE_FORMAT => '{{ csv_format }}')
WHERE $5 IS NOT NULL
LIMIT 1

UNION ALL

SELECT 'genome_scores', 3, 'csv has more columns than expected'
FROM @{{ source('raw_data', 'raw_genome_scores') }}
    (FILE_FORMAT => '{{ csv_format }}')
WHERE $4 IS NOT NULL
LIMIT 1

UNION ALL

SELECT 'genome_tags', 2, 'csv has more columns than expected'
FROM @{{ source('raw_data', 'raw_genome_tags') }}
    (FILE_FORMAT => '{{ csv_format }}')
WHERE $3 IS NOT NULL
LIMIT 1

UNION ALL

SELECT 'links', 3, 'csv has more columns than expected'
FROM @{{ source('raw_data', 'raw_links') }}
    (FILE_FORMAT => '{{ csv_format }}')
WHERE $4 IS NOT NULL
LIMIT 1

-- Check for FEWER columns (column N is NULL for all rows)

UNION ALL

SELECT 'movies', 3, 'csv has fewer columns than expected'
WHERE NOT EXISTS (
    SELECT 1 FROM @{{ source('raw_data', 'raw_movies') }}
        (FILE_FORMAT => '{{ csv_format }}')
    WHERE $3 IS NOT NULL
    LIMIT 1
)

UNION ALL

SELECT 'ratings', 4, 'csv has fewer columns than expected'
WHERE NOT EXISTS (
    SELECT 1 FROM @{{ source('raw_data', 'raw_ratings') }}
        (FILE_FORMAT => '{{ csv_format }}')
    WHERE $4 IS NOT NULL
    LIMIT 1
)

UNION ALL

SELECT 'tags', 4, 'csv has fewer columns than expected'
WHERE NOT EXISTS (
    SELECT 1 FROM @{{ source('raw_data', 'raw_tags') }}
        (FILE_FORMAT => '{{ csv_format }}')
    WHERE $4 IS NOT NULL
    LIMIT 1
)

UNION ALL

SELECT 'genome_scores', 3, 'csv has fewer columns than expected'
WHERE NOT EXISTS (
    SELECT 1 FROM @{{ source('raw_data', 'raw_genome_scores') }}
        (FILE_FORMAT => '{{ csv_format }}')
    WHERE $3 IS NOT NULL
    LIMIT 1
)

UNION ALL

SELECT 'genome_tags', 2, 'csv has fewer columns than expected'
WHERE NOT EXISTS (
    SELECT 1 FROM @{{ source('raw_data', 'raw_genome_tags') }}
        (FILE_FORMAT => '{{ csv_format }}')
    WHERE $2 IS NOT NULL
    LIMIT 1
)

UNION ALL

SELECT 'links', 3, 'csv has fewer columns than expected'
WHERE NOT EXISTS (
    SELECT 1 FROM @{{ source('raw_data', 'raw_links') }}
        (FILE_FORMAT => '{{ csv_format }}')
    WHERE $3 IS NOT NULL
    LIMIT 1
)
