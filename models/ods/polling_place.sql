{{ config(materialized='view') }}

{# 自治体標準オープンデータセット「投票所一覧」（データ項目定義書 C の 27）の定義書どおりの
   列名・並びで出す。Queria からこのまま CSV / Excel でダウンロードすれば納品物になる。
   ID には投票区番号を使う。市の一覧に無い項目（カナ・英字・緯度経度・連絡先など）は空欄。
   対象地区は定義書に列が無いので出さない #}
SELECT
    local_government_code                                 AS "全国地方公共団体コード",
    voting_district_number                            AS "ID",
    '茨城県つくば市'                                  AS "地方公共団体名",
    name                                              AS "名称",
    CAST(NULL AS VARCHAR)                             AS "名称_カナ",
    CAST(NULL AS VARCHAR)                             AS "名称_英字",
    CAST(NULL AS VARCHAR)                             AS "施設通称",
    CAST(NULL AS VARCHAR)                             AS "概要",
    CAST(NULL AS VARCHAR)                             AS "説明",
    CAST(NULL AS VARCHAR)                             AS "町字ID",
    full_address                                           AS "連結表記",
    prefecture                                        AS "都道府県",
    city                                              AS "市区町村",
    CAST(NULL AS VARCHAR)                             AS "町字",
    CAST(NULL AS VARCHAR)                             AS "番地以下",
    CAST(NULL AS VARCHAR)                             AS "建物名等_方書",
    CAST(NULL AS VARCHAR)                             AS "緯度",
    CAST(NULL AS VARCHAR)                             AS "経度",
    CAST(NULL AS VARCHAR)                             AS "座標参照系",
    CAST(NULL AS VARCHAR)                             AS "座標参照系コード",
    CAST(NULL AS VARCHAR)                             AS "連絡先名称",
    CAST(NULL AS VARCHAR)                             AS "連絡先電話番号",
    CAST(NULL AS VARCHAR)                             AS "連絡先内線番号",
    CAST(NULL AS VARCHAR)                             AS "連絡先メールアドレス",
    CAST(NULL AS VARCHAR)                             AS "連絡先FormURL",
    CAST(NULL AS VARCHAR)                             AS "連絡先備考",
    CAST(NULL AS VARCHAR)                             AS "郵便番号",
    polling_place_type                                AS "投票所区分",
    voting_district                                   AS "投票区名",
    CAST(NULL AS VARCHAR)                             AS "選挙区分",
    CAST(NULL AS VARCHAR)                             AS "備考"
FROM {{ ref('mart_tsukuba_polling_place') }}
ORDER BY TRY_CAST(voting_district_number AS INTEGER)
