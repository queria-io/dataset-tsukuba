{# 指定緊急避難場所の seed（定義書の様式で整備済み）。定義書どおりの列で出すため、列も値も raw のまま使う #}
{{ config(materialized='ephemeral') }}

SELECT * FROM {{ ref('raw_tsukuba_emergency_shelter_20241201') }}
