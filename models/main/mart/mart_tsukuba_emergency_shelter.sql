{{ config(materialized='view') }}

SELECT
    *,
    lg_code AS local_government_code,
    address AS full_address,
    pref AS prefecture
FROM {{ ref('stg_tsukuba_emergency_shelter_20241201') }}
