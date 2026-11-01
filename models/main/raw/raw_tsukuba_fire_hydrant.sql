{{ config(materialized='table') }}

{# 消防水利の CSV（CKAN n007_001）。防火水槽と消火栓が別ファイルで、
   列も少し違う（防火水槽は容量、消火栓は管径を持つ）ので、列名で縦につなぐ #}
SELECT *
FROM read_csv(
    'data/fire_hydrant/*.csv',
    header = true,
    all_varchar = true,
    union_by_name = true
)
