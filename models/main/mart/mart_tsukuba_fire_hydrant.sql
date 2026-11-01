{{ config(materialized='view') }}

SELECT * FROM {{ ref('stg_tsukuba_fire_hydrant') }}
