WITH user_ratings AS (
    SELECT
        user_id,
        MIN(rated_at) AS first_rated_at,
        MAX(rated_at) AS last_rated_at,
        MIN(rating) AS min_rating_given,
        MAX(rating) AS max_rating_given,
        COUNT(*) AS total_ratings,
        ROUND(AVG(rating), 2) AS avg_rating_given,
        COUNT(DISTINCT movie_id) AS unique_movies_rated
    FROM {{ ref('fct_ratings') }}
    GROUP BY user_id
),

user_tags AS (
    SELECT
        user_id,
        MIN(tagged_at) AS first_tagged_at,
        MAX(tagged_at) AS last_tagged_at,
        COUNT(*) AS total_tags,
        COUNT(DISTINCT movie_id) AS unique_movies_tagged
    FROM {{ ref('fct_tags') }}
    GROUP BY user_id
),

user_genre_counts AS (
    SELECT
        r.user_id,
        g.genre,
        COUNT(*) AS genre_ratings_count
    FROM {{ ref('fct_ratings') }} AS r
    INNER JOIN {{ ref('dim_genres') }} AS g
        ON r.movie_id = g.movie_id
    GROUP BY
        r.user_id,
        g.genre
),

user_top_genre AS (
    SELECT
        user_id,
        genre AS most_reviewed_genre,
        genre_ratings_count AS most_reviewed_genre_count
    FROM user_genre_counts
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY user_id
        ORDER BY
            genre_ratings_count DESC,
            genre ASC
    ) = 1
),

all_users AS (
    SELECT user_id FROM user_ratings
    UNION DISTINCT
    SELECT user_id FROM user_tags
),

user_summary AS (
    SELECT
        u.user_id,
        tg.most_reviewed_genre,
        r.avg_rating_given,
        r.min_rating_given,
        r.max_rating_given,
        COALESCE(r.total_ratings, 0) AS total_ratings,
        ROUND(COALESCE(r.max_rating_given - r.min_rating_given, 0), 2) AS rating_spread,
        COALESCE(r.unique_movies_rated, 0) AS unique_movies_rated,
        COALESCE(t.total_tags, 0) AS total_tags,
        COALESCE(t.unique_movies_tagged, 0) AS unique_movies_tagged,
        COALESCE(tg.most_reviewed_genre_count, 0) AS most_reviewed_genre_count,
        CASE
            WHEN r.first_rated_at IS NOT NULL AND t.first_tagged_at IS NOT NULL
                THEN LEAST(r.first_rated_at, t.first_tagged_at)
            ELSE COALESCE(r.first_rated_at, t.first_tagged_at)
        END AS first_activity_at,
        CASE
            WHEN r.last_rated_at IS NOT NULL AND t.last_tagged_at IS NOT NULL
                THEN GREATEST(r.last_rated_at, t.last_tagged_at)
            ELSE COALESCE(r.last_rated_at, t.last_tagged_at)
        END AS last_activity_at
    FROM all_users AS u
    LEFT JOIN user_ratings AS r
        ON u.user_id = r.user_id
    LEFT JOIN user_tags AS t
        ON u.user_id = t.user_id
    LEFT JOIN user_top_genre AS tg
        ON u.user_id = tg.user_id
),

final_profile AS (
    SELECT
        user_id,
        most_reviewed_genre,
        first_activity_at,
        last_activity_at,
        total_ratings,
        avg_rating_given,
        min_rating_given,
        max_rating_given,
        rating_spread,
        unique_movies_rated,
        total_tags,
        unique_movies_tagged,
        most_reviewed_genre_count,
        DATEDIFF('day', first_activity_at, last_activity_at) AS active_lifespan_days,
        CASE
            WHEN total_ratings >= 100 THEN 'Power Reviewer'
            WHEN total_ratings >= 20 THEN 'Active Reviewer'
            ELSE 'Casual Rater'
        END AS user_segment
    FROM user_summary
)

SELECT
    user_id,
    user_segment,
    total_ratings,
    avg_rating_given,
    min_rating_given,
    max_rating_given,
    rating_spread,
    unique_movies_rated,
    total_tags,
    unique_movies_tagged,
    most_reviewed_genre,
    most_reviewed_genre_count,
    first_activity_at,
    last_activity_at,
    active_lifespan_days
FROM final_profile
