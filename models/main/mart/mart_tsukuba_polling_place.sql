{{ config(materialized='view') }}

SELECT * FROM {{ ref('stg_tsukuba_polling_place') }}
