{{
    config(
        pre_hook="""
            CREATE OR REPLACE FILE FORMAT {{ source('raw_data', 'raw_genome_scores').database }}.{{ source('raw_data', 'raw_genome_scores').schema }}.CSV_FORMAT
                TYPE = 'CSV'
                FIELD_DELIMITER = ','
                SKIP_HEADER = 1
                FIELD_OPTIONALLY_ENCLOSED_BY = '\"'
                TRIM_SPACE = true
                NULL_IF = ('', 'NULL', 'null');
        """
    )
}}

WITH stage_data AS (
    SELECT
        $1::NUMBER AS movie_id,
        $2::NUMBER AS tag_id,
        $3::FLOAT AS relevance,
        metadata$start_scan_time AS _loaded_at
    FROM @{{ source('raw_data', 'raw_genome_scores') }}
        (FILE_FORMAT => '{{ source('raw_data', 'raw_genome_scores').database }}.{{ source('raw_data', 'raw_genome_scores').schema }}.CSV_FORMAT')
)
SELECT * FROM stage_data

