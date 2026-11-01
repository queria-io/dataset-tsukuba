{{ config(materialized='view') }}

{# 自治体標準オープンデータセット「子育て施設一覧」（データ項目定義書 A の 05）の定義書どおりの
   列名・並びで出す。Queria からこのまま CSV / Excel でダウンロードすれば納品物になる。
   ID は市の一覧に無いので空欄。種別は定義書の選択肢に読み替えている（保育所は公立・民間で認可公立保育所・認可私立保育所、幼稚園は公立幼稚園・私立幼稚園、小規模保育事業所と地域子育て支援拠点は その他）。型が書かれていない認定こども園は種別を空欄にしている #}
SELECT
    municipality_code                                  AS "全国地方公共団体コード",
    CAST(NULL AS VARCHAR)                              AS "ID",
    '茨城県つくば市'                                          AS "地方公共団体名",
    name                                               AS "名称",
    name_kana                                          AS "名称_カナ",
    CAST(NULL AS VARCHAR)                              AS "名称_英字",
    CASE
        WHEN ownership = '公立' AND facility_type = '保育所' THEN '認可公立保育所'
        WHEN ownership = '民間' AND facility_type = '保育所' THEN '認可私立保育所'
        WHEN ownership = '公立' AND facility_type = '幼稚園' THEN '公立幼稚園'
        WHEN ownership = '民間' AND facility_type = '幼稚園' THEN '私立幼稚園'
        WHEN facility_type IN ('小規模保育事業所', '地域子育て支援拠点') THEN 'その他'
    END AS "種別",
    CASE WHEN city = 'つくば市' THEN '082201' END          AS "所在地_全国地方公共団体コード",
    CAST(NULL AS VARCHAR)                              AS "町字ID",
    address                                            AS "所在地_連結表記",
    prefecture                                         AS "所在地_都道府県",
    city                                               AS "所在地_市区町村",
    CAST(NULL AS VARCHAR)                              AS "所在地_町字",
    CAST(NULL AS VARCHAR)                              AS "所在地_番地以下",
    building_name                                      AS "建物名等(方書)",
    lat                                                AS "緯度",
    lon                                                AS "経度",
    CAST(NULL AS VARCHAR)                              AS "高度の種別",
    CAST(NULL AS VARCHAR)                              AS "高度の値",
    access                                             AS "アクセス方法",
    CAST(NULL AS VARCHAR)                              AS "駐車場情報",
    phone_number                                       AS "電話番号",
    CAST(NULL AS VARCHAR)                              AS "内線番号",
    fax_number                                         AS "FAX番号",
    CAST(NULL AS VARCHAR)                              AS "連絡先メールアドレス",
    CAST(NULL AS VARCHAR)                              AS "連絡先FormURL",
    CAST(NULL AS VARCHAR)                              AS "連絡先備考（その他、SNSなど）",
    CAST(NULL AS VARCHAR)                              AS "郵便番号",
    corporate_number                                   AS "法人番号",
    corporate_name                                     AS "団体名",
    authorized_date                                    AS "認可等年月日",
    capacity                                           AS "収容定員",
    age_range                                          AS "受入年齢",
    available_days                                     AS "利用可能曜日",
    start_time                                         AS "開始時間",
    end_time                                           AS "終了時間",
    available_notes                                    AS "利用可能日時特記事項",
    temporary_care                                     AS "一時預かりの有無",
    CAST(NULL AS VARCHAR)                              AS "子供預かり料金種別",
    CAST(NULL AS VARCHAR)                              AS "子供預かり料金",
    CAST(NULL AS VARCHAR)                              AS "子供預かり料金備考",
    CAST(NULL AS VARCHAR)                              AS "子供預かり開所時間",
    CAST(NULL AS VARCHAR)                              AS "子供預かり閉所時間",
    CAST(NULL AS VARCHAR)                              AS "病児保育の有無",
    CAST(NULL AS VARCHAR)                              AS "授乳室",
    CAST(NULL AS VARCHAR)                              AS "おむつ替えコーナー",
    CAST(NULL AS VARCHAR)                              AS "飲食可否",
    CAST(NULL AS VARCHAR)                              AS "ベビーカー貸出",
    CAST(NULL AS VARCHAR)                              AS "ベビーカー利用",
    url                                                AS "URL",
    CAST(NULL AS VARCHAR)                              AS "画像",
    CAST(NULL AS VARCHAR)                              AS "画像_ライセンス",
    notes                                              AS "備考"
FROM {{ ref('mart_tsukuba_preschool') }}
ORDER BY source_dataset, name
