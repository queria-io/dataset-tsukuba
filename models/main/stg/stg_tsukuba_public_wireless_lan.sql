{{ config(materialized='view') }}

SELECT
    "都道府県コード又は市区町村コード"              AS local_government_code,
    "番号"                                            AS facility_id,
    "名称"                                            AS name,
    NULLIF("名称_カナ", '')                          AS name_kana,
    NULLIF("名称_英語", '')                          AS name_en,
    "住所"                                            AS full_address,
    "都道府県名"                                      AS prefecture,
    "市区町村名"                                      AS city,
    NULLIF("方書", '')                               AS building_name,
    NULLIF("設置者", '')                             AS installer,
    NULLIF("電話番号", '')                           AS phone_number,
    NULLIF("内線番号", '')                           AS phone_ext,
    NULLIF("SSID", '')                               AS ssid,
    NULLIF("提供エリア", '')                         AS coverage_area,
    NULLIF("URL", '')                                AS url,
    NULLIF("備考", '')                               AS notes
FROM {{ ref('raw_tsukuba_public_wireless_lan') }}
