WITH movie_ratings AS (
    SELECT
        movie_id,
        MIN(rated_at) AS first_rated_at,
        MAX(rated_at) AS last_rated_at,
        COUNT(*) AS total_ratings,
        AVG(rating) AS avg_rating,
        STDDEV(rating) AS stddev_rating,
        COUNT(CASE WHEN rating = 5.0 THEN 1 END) AS rating_5_star_count,
        COUNT(CASE WHEN rating = 1.0 THEN 1 END) AS rating_1_star_count
    FROM {{ ref('fct_ratings') }}
    GROUP BY movie_id
),

global_stats AS (
    SELECT
        25.0 AS min_ratings_threshold,
        AVG(rating) AS global_avg_rating
    FROM {{ ref('fct_ratings') }}
),

movies AS (
    SELECT
        movie_id,
        movie_name,
        release_year
    FROM {{ ref('dim_movies') }}
),

links AS (
    SELECT
        movie_id,
        imdb_id,
        tmdb_id
    FROM {{ ref('dim_links') }}
),

combined AS (
    SELECT
        m.movie_id,
        m.movie_name,
        m.release_year,
        l.imdb_id,
        l.tmdb_id,
        r.first_rated_at,
        r.last_rated_at,
        COALESCE(r.total_ratings, 0) AS total_ratings,
        ROUND(r.avg_rating, 2) AS avg_rating,
        ROUND(COALESCE(r.stddev_rating, 0), 2) AS stddev_rating,
        COALESCE(r.rating_5_star_count, 0) AS rating_5_star_count,
        COALESCE(r.rating_1_star_count, 0) AS rating_1_star_count,
        ROUND(
            (
                (COALESCE(r.total_ratings, 0) * COALESCE(r.avg_rating, g.global_avg_rating))
                + (g.min_ratings_threshold * g.global_avg_rating)
            ) / (COALESCE(r.total_ratings, 0) + g.min_ratings_threshold),
            2
        ) AS bayesian_avg_rating
    FROM movies AS m
    CROSS JOIN global_stats AS g
    LEFT JOIN movie_ratings AS r
        ON m.movie_id = r.movie_id
    LEFT JOIN links AS l
        ON m.movie_id = l.movie_id
),

ranked AS (
    SELECT
        movie_id,
        movie_name,
        release_year,
        imdb_id,
        tmdb_id,
        total_ratings,
        avg_rating,
        stddev_rating,
        rating_5_star_count,
        rating_1_star_count,
        first_rated_at,
        last_rated_at,
        bayesian_avg_rating,
        DENSE_RANK() OVER (
            ORDER BY bayesian_avg_rating DESC
        ) AS rating_rank_bayesian
    FROM combined
)

SELECT
    movie_id,
    movie_name,
    release_year,
    imdb_id,
    tmdb_id,
    total_ratings,
    avg_rating,
    stddev_rating,
    rating_5_star_count,
    rating_1_star_count,
    first_rated_at,
    last_rated_at,
    bayesian_avg_rating,
    rating_rank_bayesian
FROM ranked
