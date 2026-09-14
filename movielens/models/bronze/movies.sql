with src_movies as (
    Select * from {{ source('raw_data', 'raw_movies')}}
)
Select * from src_movies