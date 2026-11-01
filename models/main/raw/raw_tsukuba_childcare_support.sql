{{ config(materialized='table') }}

{# 地域子育て支援拠点の XLSX（CKAN o014_001）。出張子育て広場の行も同じシートに入っている #}
SELECT *
FROM read_csv(
    'data/preschool/childcare_support.csv',
    header = true,
    all_varchar = true
)
