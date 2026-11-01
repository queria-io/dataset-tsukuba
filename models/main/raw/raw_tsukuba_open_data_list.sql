{{ config(materialized='table') }}

{# オープンデータ一覧の CSV（CKAN m009_001）。pipelines/ods.py が UTF-8 に揃えて置く #}
SELECT *
FROM read_csv(
    'data/open_data_list/*.csv',
    header = true,
    all_varchar = true
)
