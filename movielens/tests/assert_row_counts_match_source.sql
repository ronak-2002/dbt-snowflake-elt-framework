-- Singular test: For every bronze model the row count must equal the source CSV
-- data row count (excluding the header).
-- Both the models and this test use the named CSV_FORMAT (SKIP_HEADER=1),
-- so the stage count already excludes the header row.
-- The test fails (returns rows) when model_row_count != source_row_count.

{% set csv_format = source('raw_data', 'raw_movies').database ~ '.' ~ source('raw_data', 'raw_movies').schema ~ '.CSV_FORMAT' %}

WITH model_counts AS (
    SELECT 'movies' AS model_name, COUNT(*) AS row_count FROM {{ ref('movies') }}
    UNION ALL
    SELECT 'ratings', COUNT(*) FROM {{ ref('ratings') }}
    UNION ALL
    SELECT 'tags', COUNT(*) FROM {{ ref('tags') }}
    UNION ALL
    SELECT 'genome_scores', COUNT(*) FROM {{ ref('genome_scores') }}
    UNION ALL
    SELECT 'genome_tags', COUNT(*) FROM {{ ref('genome_tags') }}
    UNION ALL
    SELECT 'links', COUNT(*) FROM {{ ref('links') }}
),

source_counts AS (
    SELECT 'movies' AS model_name, COUNT(*) AS row_count
    FROM @{{ source('raw_data', 'raw_movies') }}
        (FILE_FORMAT => '{{ csv_format }}')
    UNION ALL
    SELECT 'ratings', COUNT(*)
    FROM @{{ source('raw_data', 'raw_ratings') }}
        (FILE_FORMAT => '{{ csv_format }}')
    UNION ALL
    SELECT 'tags', COUNT(*)
    FROM @{{ source('raw_data', 'raw_tags') }}
        (FILE_FORMAT => '{{ csv_format }}')
    UNION ALL
    SELECT 'genome_scores', COUNT(*)
    FROM @{{ source('raw_data', 'raw_genome_scores') }}
        (FILE_FORMAT => '{{ csv_format }}')
    UNION ALL
    SELECT 'genome_tags', COUNT(*)
    FROM @{{ source('raw_data', 'raw_genome_tags') }}
        (FILE_FORMAT => '{{ csv_format }}')
    UNION ALL
    SELECT 'links', COUNT(*)
    FROM @{{ source('raw_data', 'raw_links') }}
        (FILE_FORMAT => '{{ csv_format }}')
)

SELECT
    m.model_name,
    m.row_count AS model_row_count,
    s.row_count AS expected_row_count
FROM model_counts AS m
INNER JOIN source_counts AS s
    ON m.model_name = s.model_name
WHERE m.row_count != s.row_count
