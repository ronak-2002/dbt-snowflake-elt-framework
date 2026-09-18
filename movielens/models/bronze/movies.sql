{{
    config(
        pre_hook="""
            CREATE OR REPLACE FILE FORMAT
                {{ source('raw_data', 'raw_movies').database }}.{{ source('raw_data', 'raw_movies').schema }}.CSV_FORMAT
                TYPE = 'CSV'
                FIELD_DELIMITER = ','
                SKIP_HEADER = 1
                FIELD_OPTIONALLY_ENCLOSED_BY = '\"'
                TRIM_SPACE = true
                NULL_IF = ('', 'NULL', 'null');
        """
    )
}}

{% set raw_src = source('raw_data', 'raw_movies') %}
{% set csv_format = raw_src.database ~ '.' ~ raw_src.schema ~ '.CSV_FORMAT' %}

WITH stage_data AS (
    SELECT
        $1::NUMBER AS movie_id,
        $2::VARCHAR AS title,
        $3::VARCHAR AS genres,
        metadata$start_scan_time AS _loaded_at
    FROM
        @{{ raw_src }}
        (
            FILE_FORMAT => '{{ csv_format }}'
        )
)

SELECT * FROM stage_data
