WITH scores AS (
    SELECT * FROM {{ ref('genome_scores') }}
),

tags AS (
    SELECT * FROM {{ ref('genome_tags') }}
),

merged AS (
    SELECT
        s.movie_id,
        s.tag_id,
        t.tag AS tag_name,
        s.relevance,
        s._loaded_at
    FROM scores AS s
    INNER JOIN tags AS t
        ON s.tag_id = t.tag_id
)

SELECT * FROM merged
