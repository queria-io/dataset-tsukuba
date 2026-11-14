{# 自治体標準オープンデータセット「教育機関一覧」（データ項目定義書 C の 24）の定義書どおりの
   列名・並びで出す。Queria からこのまま CSV / Excel でダウンロードすれば納品物になる。
   学校コードは市の一覧に無いので空欄。設置区分は 2（公立）、設置者情報は つくば市。通学区域は定義書に列が無いので出さない #}
SELECT
    CAST(NULL AS VARCHAR)                              AS "学校コード",
    school_type                                        AS "学校種",
    '08'                                               AS "都道府県番号",
    '2'                                                AS "設置区分",
    'つくば市'                                             AS "設置者情報",
    CAST(NULL AS VARCHAR)                              AS "本分校",
    CAST(NULL AS VARCHAR)                              AS "本校学校コード",
    CAST(NULL AS VARCHAR)                              AS "本校学校名",
    name                                               AS "学校名",
    CAST(NULL AS VARCHAR)                              AS "学校名カナ表記",
    CAST(NULL AS VARCHAR)                              AS "学校略称",
    city                                               AS "教育機関_学校所在地_市区町村",
    town                                               AS "教育機関_学校所在地_町字",
    street_number                                      AS "教育機関_学校所在地_番地以下",
    CAST(NULL AS VARCHAR)                              AS "郵便番号",
    CAST(NULL AS VARCHAR)                              AS "緯度",
    CAST(NULL AS VARCHAR)                              AS "経度",
    CAST(NULL AS VARCHAR)                              AS "連絡先名称",
    phone_number                                       AS "連絡先電話番号",
    CAST(NULL AS VARCHAR)                              AS "属性情報設定年月日",
    CAST(NULL AS VARCHAR)                              AS "属性情報廃止年月日",
    CAST(NULL AS VARCHAR)                              AS "旧学校調査番号",
    CAST(NULL AS VARCHAR)                              AS "移行後の学校コード"
FROM {{ ref('mart_tsukuba_educational_institution') }}
ORDER BY school_type, name
