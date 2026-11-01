{{ config(materialized='view') }}

{# 学校の種類はシート名から決め、定義書の学校種コード（注1）にする。
   所在地は「つくば市大曽根2917番地」の形なので、市のあとを最初の算用数字の手前で
   町字（「研究学園二丁目」のような漢数字の丁目を含む）と番地以下に分ける #}
WITH source AS (
    SELECT
        *,
        regexp_replace("所在地", '^(茨城県)?つくば市', '') AS rest
    FROM {{ ref('raw_tsukuba_educational_institution') }}
)
SELECT
    '082201'                                          AS municipality_code,
    CASE "シート"
        WHEN '幼稚園' THEN 'A1'
        WHEN '小学校' THEN 'B1'
        WHEN '中学校' THEN 'C1'
        WHEN '義務教育学校' THEN 'C2'
    END                                               AS school_type,
    "シート"                                          AS school_type_name,
    "学校名"                                          AS name,
    {{ tsukuba_address('"所在地"') }}                 AS address,
    'つくば市'                                        AS city,
    NULLIF(regexp_extract(rest, '^([^0-9０-９]+)', 1), '') AS town,
    NULLIF(regexp_replace(rest, '^[^0-9０-９]+', ''), '')  AS street_number,
    NULLIF("電話番号", '')                           AS phone_number,
    NULLIF("通学区域", '')                           AS school_district
FROM source
