WITH genre_ratings AS (
    SELECT
        g.genre,
        DATE_TRUNC('month', r.rated_at) AS activity_date_month,
        COUNT(r.rating) AS rating_count,
        ROUND(AVG(r.rating), 2) AS avg_rating,
        COUNT(DISTINCT r.user_id) AS unique_users_rating,
        COUNT(DISTINCT r.movie_id) AS unique_movies_rated
    FROM {{ ref('fct_ratings') }} AS r
    INNER JOIN {{ ref('dim_genres') }} AS g
        ON r.movie_id = g.movie_id
    GROUP BY
        g.genre,
        DATE_TRUNC('month', r.rated_at)
),

genre_tags AS (
    SELECT
        g.genre,
        DATE_TRUNC('month', t.tagged_at) AS activity_date_month,
        COUNT(t.tag) AS tag_count,
        COUNT(DISTINCT t.user_id) AS unique_users_tagging
    FROM {{ ref('fct_tags') }} AS t
    INNER JOIN {{ ref('dim_genres') }} AS g
        ON t.movie_id = g.movie_id
    WHERE t.tagged_at IS NOT NULL
    GROUP BY
        g.genre,
        DATE_TRUNC('month', t.tagged_at)
),

merged AS (
    SELECT
        gr.avg_rating,
        COALESCE(gr.genre, gt.genre) AS genre,
        COALESCE(gr.activity_date_month, gt.activity_date_month) AS activity_date_month,
        EXTRACT(YEAR FROM COALESCE(gr.activity_date_month, gt.activity_date_month)) AS activity_year,
        EXTRACT(MONTH FROM COALESCE(gr.activity_date_month, gt.activity_date_month)) AS activity_month,
        COALESCE(gr.rating_count, 0) AS rating_count,
        COALESCE(gr.unique_users_rating, 0) AS unique_users_rating,
        COALESCE(gr.unique_movies_rated, 0) AS unique_movies_rated,
        COALESCE(gt.tag_count, 0) AS tag_count,
        COALESCE(gt.unique_users_tagging, 0) AS unique_users_tagging
    FROM genre_ratings AS gr
    FULL OUTER JOIN genre_tags AS gt
        ON
            gr.genre = gt.genre
            AND gr.activity_date_month = gt.activity_date_month
)

SELECT
    genre,
    activity_date_month,
    activity_year,
    activity_month,
    rating_count,
    avg_rating,
    unique_users_rating,
    unique_movies_rated,
    tag_count,
    unique_users_tagging
FROM merged
