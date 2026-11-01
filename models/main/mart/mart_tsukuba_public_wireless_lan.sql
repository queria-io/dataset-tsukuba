{{ config(materialized='view') }}

SELECT * FROM {{ ref('stg_tsukuba_public_wireless_lan') }}
