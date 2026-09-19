-- Singular test: The composite key (user_id, movie_id) must be unique in the ratings model.
-- In the MovieLens dataset each user submits at most one rating per movie,
-- so this combination should never be duplicated.
-- The test fails if any duplicate composite keys are found.

SELECT
    user_id,
    movie_id,
    COUNT(*) AS duplicate_count
FROM {{ ref('ratings') }}
GROUP BY user_id, movie_id
HAVING COUNT(*) > 1
