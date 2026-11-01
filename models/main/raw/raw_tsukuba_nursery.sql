{{ config(materialized='table') }}

{# 認可保育所等一覧の XLSX（CKAN o019_001）。pipelines/ods.py がシートを CSV にして置く #}
SELECT *
FROM read_csv(
    'data/preschool/nursery.csv',
    header = true,
    all_varchar = true
)
