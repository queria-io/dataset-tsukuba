{{ config(materialized='table') }}

{# 市立幼稚園一覧の CSV（CKAN sirituyoutien）。pipelines/ods.py が UTF-8 に揃えて置く。末尾に空行がある #}
SELECT *
FROM read_csv(
    'data/preschool/public_kindergarten/*.csv',
    header = true,
    all_varchar = true
)
