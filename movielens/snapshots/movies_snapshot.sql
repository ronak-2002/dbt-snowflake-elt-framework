{% snapshot movies_snapshot %}

{{
    config(
        target_schema='bronze',
        unique_key='movie_id',
        strategy='check',
        check_cols=['title', 'genres']
    )
}}

    SELECT * FROM {{ ref('movies') }}

{% endsnapshot %}
