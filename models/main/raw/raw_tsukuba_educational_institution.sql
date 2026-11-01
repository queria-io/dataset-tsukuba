{{ config(materialized='table') }}

{# 市立小学校・中学校・義務教育学校・幼稚園一覧の XLSX（CKAN l010_001）。学校の種類ごとのシートを
   pipelines/ods.py が 1 本の CSV につなぎ、元のシート名を「シート」列に入れている #}
SELECT *
FROM read_csv(
    'data/educational_institution.csv',
    header = true,
    all_varchar = true
)
