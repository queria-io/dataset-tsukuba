{{ config(materialized='table') }}

{# 私立幼稚園・認定こども園一覧の XLSX（CKAN l012_001）。pipelines/ods.py がシートを CSV にして置く #}
SELECT *
FROM read_csv(
    'data/preschool/private_kindergarten.csv',
    header = true,
    all_varchar = true
)
