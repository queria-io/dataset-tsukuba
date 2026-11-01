{{ config(materialized='table') }}

{# 自転車等駐車場一覧の XLSX（CKAN j008_001）。3 段の見出しを pipelines/ods.py が
   「料金_定期_自転車」のような 1 段の列名に組み直している。工区に分かれた駐輪場は工区ごとに行があり、
   料金と台数は先頭の工区の行にだけ入っている #}
SELECT *
FROM read_csv(
    'data/bicycle_parking.csv',
    header = true,
    all_varchar = true
)
