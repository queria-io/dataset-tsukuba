{{ config(materialized='view') }}

SELECT * FROM {{ ref('stg_tsukuba_educational_institution') }}
