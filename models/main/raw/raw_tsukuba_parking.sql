{{ config(materialized='table') }}

{# 駅前広場駐車場一覧の XLSX（CKAN j009_001）。名称の見出しは元のまま「駐輪場名称」 #}
SELECT *
FROM read_csv(
    'data/parking.csv',
    header = true,
    all_varchar = true
)
