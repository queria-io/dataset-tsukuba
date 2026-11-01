{{ config(materialized='table') }}

{# 介護保険事業所一覧の XLSX（CKAN o009_001）。pipelines/ods.py がシートを CSV にして置く #}
SELECT *
FROM read_csv(
    'data/care_service.csv',
    header = true,
    all_varchar = true
)
