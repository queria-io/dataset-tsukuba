{{ config(materialized='view') }}

{# 自治体標準オープンデータセット「介護サービス事業所一覧」（データ項目定義書 A の 09）の定義書どおりの
   列名・並びで出す。Queria からこのまま CSV / Excel でダウンロードすれば納品物になる。
   市の一覧に無い項目（カナ・英字・緯度経度・法人番号・利用可能曜日など）は空欄。実施サービスは市の一覧のサービス種類の書き方のまま #}
SELECT
    municipality_code                                  AS "全国地方公共団体コード",
    facility_id                                        AS "ID",
    '茨城県つくば市'                                          AS "地方公共団体名",
    name                                               AS "介護サービス事業所名称",
    CAST(NULL AS VARCHAR)                              AS "介護サービス事業所名称_カナ",
    CAST(NULL AS VARCHAR)                              AS "介護サービス事業所名称_英字",
    service_type                                       AS "実施サービス",
    CASE WHEN city = 'つくば市' THEN '082201' END          AS "所在地_全国地方公共団体コード",
    CAST(NULL AS VARCHAR)                              AS "町字ID",
    address                                            AS "所在地_連結表記",
    prefecture                                         AS "所在地_都道府県",
    city                                               AS "所在地_市区町村",
    CAST(NULL AS VARCHAR)                              AS "所在地_町字",
    CAST(NULL AS VARCHAR)                              AS "所在地_番地以下",
    CAST(NULL AS VARCHAR)                              AS "建物名等(方書)",
    CAST(NULL AS VARCHAR)                              AS "緯度",
    CAST(NULL AS VARCHAR)                              AS "経度",
    CAST(NULL AS VARCHAR)                              AS "高度の種別",
    CAST(NULL AS VARCHAR)                              AS "高度の値",
    phone_number                                       AS "電話番号",
    CAST(NULL AS VARCHAR)                              AS "内線番号",
    fax_number                                         AS "FAX番号",
    CAST(NULL AS VARCHAR)                              AS "連絡先メールアドレス",
    CAST(NULL AS VARCHAR)                              AS "連絡先FormURL",
    CAST(NULL AS VARCHAR)                              AS "連絡先備考（その他、SNSなど）",
    postal_code                                        AS "郵便番号",
    CAST(NULL AS VARCHAR)                              AS "法人番号",
    corporate_name                                     AS "法人の名称",
    business_number                                    AS "事業所番号",
    CAST(NULL AS VARCHAR)                              AS "利用可能曜日",
    CAST(NULL AS VARCHAR)                              AS "利用可能曜日特記事項",
    capacity                                           AS "定員",
    CAST(NULL AS VARCHAR)                              AS "URL",
    CAST(NULL AS VARCHAR)                              AS "画像",
    CAST(NULL AS VARCHAR)                              AS "画像_ライセンス",
    CAST(NULL AS VARCHAR)                              AS "備考"
FROM {{ ref('mart_tsukuba_care_service') }}
ORDER BY TRY_CAST(facility_id AS INTEGER)
