{# 自治体標準オープンデータセット「消防水利施設一覧」の定義書どおりの列名・並びで出す。
   Queria からこのまま CSV / Excel でダウンロードすれば納品物になる。
   市の CSV は住所を持たないので所在地の列は空欄。口径は消火栓の管径で、防火水槽は空欄。
   防火水槽の容量・管轄署所・公私別区分は定義書に列が無いので出さない #}
SELECT
    local_government_code                                 AS "全国地方公共団体コード",
    facility_id                                       AS "ID",
    '茨城県つくば市'                                  AS "地方公共団体名",
    facility_type                                     AS "種別",
    CAST(NULL AS VARCHAR)                             AS "所在地_全国地方公共団体コード",
    CAST(NULL AS VARCHAR)                             AS "町字ID",
    CAST(NULL AS VARCHAR)                             AS "所在地_連結表記",
    CAST(NULL AS VARCHAR)                             AS "所在地_都道府県",
    CAST(NULL AS VARCHAR)                             AS "所在地_市区町村",
    CAST(NULL AS VARCHAR)                             AS "所在地_町字",
    CAST(NULL AS VARCHAR)                             AS "所在地_番地以下",
    CAST(NULL AS VARCHAR)                             AS "建物名等(方書)",
    latitude                                               AS "緯度",
    longitude                                               AS "経度",
    diameter                                          AS "口径",
    CAST(NULL AS VARCHAR)                             AS "備考"
FROM {{ ref('mart_tsukuba_fire_hydrant') }}
ORDER BY facility_type, facility_id
