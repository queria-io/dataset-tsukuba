{{ config(materialized='view') }}

{# 自治体標準オープンデータセット「公衆無線LANアクセスポイント一覧」の定義書どおりの列名・並びで出す。
   Queria からこのまま CSV / Excel でダウンロードすれば納品物になる。
   市の CSV に無い項目（法人番号・町字・緯度経度・連絡先メールなど）は空欄。
   所在地の市区町村コードは、市区町村名がつくば市の行にだけ入れる #}
SELECT
    municipality_code                                 AS "全国地方公共団体コード",
    CAST(NULL AS VARCHAR)                             AS "法人番号",
    facility_id                                       AS "ID",
    '茨城県つくば市'                                  AS "地方公共団体名",
    name                                              AS "名称",
    name_kana                                         AS "名称_カナ",
    name_en                                           AS "名称_英語",
    CASE WHEN prefecture = '茨城県' AND city = 'つくば市'
         THEN '082201' END                            AS "所在地_全国地方公共団体コード",
    CAST(NULL AS VARCHAR)                             AS "町字ID",
    address                                           AS "所在地_連結表記",
    prefecture                                        AS "所在地_都道府県",
    city                                              AS "所在地_市区町村",
    CAST(NULL AS VARCHAR)                             AS "所在地_町字",
    CAST(NULL AS VARCHAR)                             AS "所在地_番地以下",
    building_name                                     AS "建物名等(方書)",
    CAST(NULL AS VARCHAR)                             AS "緯度",
    CAST(NULL AS VARCHAR)                             AS "経度",
    installer                                         AS "設置者",
    phone_number                                      AS "電話番号",
    phone_ext                                         AS "内線番号",
    CAST(NULL AS VARCHAR)                             AS "連絡先メールアドレス",
    CAST(NULL AS VARCHAR)                             AS "連絡先FormURL",
    CAST(NULL AS VARCHAR)                             AS "連絡先備考（その他、SNSなど）",
    CAST(NULL AS VARCHAR)                             AS "郵便番号",
    ssid                                              AS "SSID",
    coverage_area                                     AS "提供エリア",
    url                                               AS "URL",
    notes                                             AS "備考"
FROM {{ ref('mart_tsukuba_public_wireless_lan') }}
ORDER BY TRY_CAST(facility_id AS INTEGER)
