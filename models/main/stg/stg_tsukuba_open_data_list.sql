{{ config(materialized='view') }}

SELECT
    "都道府県コード又は市区町村コード"              AS local_government_code,
    NULLIF("NO", '')                                 AS dataset_id,
    "都道府県名"                                      AS prefecture,
    "市区町村名"                                      AS city,
    "データ名称"                                      AS title,
    NULLIF("データ概要", '')                         AS description,
    NULLIF("データ形式", '')                         AS file_format,
    NULLIF("分類", '')                               AS category,
    NULLIF("更新頻度", '')                           AS update_frequency,
    NULLIF("URL", '')                                AS url,
    NULLIF("API対応有無", '')                        AS api_available,
    NULLIF("ライセンス", '')                         AS license,
    TRY_CAST(NULLIF("登録日", '') AS DATE)            AS published_date,
    TRY_CAST(NULLIF("最終更新日", '') AS DATE)        AS last_modified_date,
    NULLIF("備考", '')                               AS notes
FROM {{ ref('raw_tsukuba_open_data_list') }}
WHERE NULLIF("データ名称", '') IS NOT NULL
