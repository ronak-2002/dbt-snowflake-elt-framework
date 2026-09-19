-- Singular test: Rating values in the ratings model must be between 0 and 5
-- and only include values at 0.5 intervals (i.e. 0, 0.5, 1.0, 1.5, ... 5.0).
-- The test fails if any rating falls outside the 0–5 range or is not a
-- multiple of 0.5.

SELECT
    user_id,
    movie_id,
    rating
FROM {{ ref('ratings') }}
WHERE rating < 0
   OR rating > 5
   OR MOD(rating, 0.5) != 0
