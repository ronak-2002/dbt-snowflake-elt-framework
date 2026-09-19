WITH ranked_tags AS (
    SELECT
        movie_id,
        tag_name,
        relevance,
        ROW_NUMBER() OVER (
            PARTITION BY movie_id
            ORDER BY relevance DESC
        ) AS tag_rank
    FROM {{ ref('dim_genome_relevance') }}
),

top_tags AS (
    SELECT
        movie_id,
        MAX(relevance) AS max_tag_relevance,
        ARRAY_AGG(tag_name) WITHIN GROUP (
            ORDER BY relevance DESC
        ) AS top_genome_tags
    FROM ranked_tags
    WHERE tag_rank <= 5
    GROUP BY movie_id
),

movies AS (
    SELECT
        movie_id,
        movie_name,
        release_year
    FROM {{ ref('dim_movies') }}
)

SELECT
    m.movie_id,
    m.movie_name,
    m.release_year,
    t.max_tag_relevance,
    t.top_genome_tags
FROM movies AS m
INNER JOIN top_tags AS t
    ON m.movie_id = t.movie_id
