{{ config(materialized='table') }}

{# 投票所一覧の XLSX（CKAN m027_001）。地区ごとのシートを pipelines/ods.py が
   1 本の CSV につなぎ、元のシート名を「地区」列に入れている。
   各シートの末尾にある「計」の行もそのまま入っている #}
SELECT *
FROM read_csv(
    'data/polling_place.csv',
    header = true,
    all_varchar = true
)
