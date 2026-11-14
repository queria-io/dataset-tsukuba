{# 子育て施設は 4 つの一覧に分かれているので、列を揃えて縦につなぐ。
   - 私立幼稚園・認定こども園一覧の認定こども園は、認可保育所等一覧にも同じ名称・住所で載っているので、
     認可保育所等一覧の行を残す（列が多い）
   - 地域子育て支援拠点の一覧に同居している出張子育て広場は、交流センターなどで開く催しで施設ではないので除く
   - 市立幼稚園一覧は種別と区分の列を持たないので、一覧の名前から 幼稚園 / 公立 を入れる #}
WITH nursery AS (
    SELECT * FROM {{ ref('raw_tsukuba_nursery') }}
),
unioned AS (
    SELECT
        'o019_001'                                    AS source_dataset,
        "区分"                                        AS ownership,
        "種別"                                        AS facility_type,
        "名称"                                        AS name,
        NULLIF("名称_カナ", '')                      AS name_kana,
        "住所"                                        AS address_raw,
        NULLIF("方書", '')                           AS building_name,
        "緯度（世界測地系）"                          AS lat_raw,
        "経度（世界測地系）"                          AS lon_raw,
        NULLIF("アクセス方法", '')                   AS access,
        TRY_CAST("定員" AS INTEGER)                   AS capacity,
        NULLIF("電話", '')                           AS phone_number,
        NULLIF("FAX番号", '')                        AS fax_number,
        NULLIF("団体名", '')                         AS corporate_name,
        NULLIF("保育年齢", '')                       AS age_range,
        NULLIF("送迎バス", '')                       AS school_bus,
        NULLIF("利用可能曜日", '')                   AS available_days,
        NULLIF("開園（平日）", '')                   AS start_time,
        NULLIF("閉園（平日）", '')                   AS end_time,
        NULLIF("利用可能日時特記事項", '')           AS available_notes,
        NULLIF("開園（土曜日）", '')                 AS saturday_start_time,
        NULLIF("閉園（土曜日）", '')                 AS saturday_end_time,
        NULLIF("一時預かりの有無", '')               AS temporary_care,
        CAST(NULL AS VARCHAR)                         AS attendance_area,
        NULLIF("URL", '')                            AS url,
        NULLIF("備考", '')                           AS notes,
        NULLIF("法人番号", '')                       AS legal_entity_number,
        NULLIF("認可等年月日", '')                   AS authorized_date
    FROM nursery

    UNION ALL

    SELECT
        'l012_001', "区分", "種別", "名称", NULL, "住所", NULL,
        "緯度（世界測地系）", "経度（世界測地系）", NULL, NULL,
        NULLIF("電話番号", ''), NULLIF("FAX番号", ''), NULL, NULLIF("対象児", ''), NULLIF("バス", ''),
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULLIF("ホームページ", ''), NULL, NULL, NULL
    FROM {{ ref('raw_tsukuba_private_kindergarten') }} AS k
    WHERE NOT EXISTS (
        SELECT 1 FROM nursery AS n WHERE n."名称" = k."名称" AND n."住所" = k."住所"
    )

    UNION ALL

    SELECT
        'o014_001', NULL, "種別", "名称", NULL, "住所", NULLIF("方書", ''),
        "緯度", "経度", NULL, NULL,
        NULLIF("電話", ''), NULL, NULL, NULL, NULL,
        NULLIF("実施日", ''),
        {# 「9:00～16:00」のように 1 区間だけのときに開始・終了へ分ける。
           「9:30～12:00／13:00～15:30」のような 2 区間は特記事項に残す #}
        CASE WHEN regexp_full_match("実施時間", '\d{1,2}:\d{2}～\d{1,2}:\d{2}')
             THEN lpad(split_part("実施時間", '～', 1), 5, '0') END,
        CASE WHEN regexp_full_match("実施時間", '\d{1,2}:\d{2}～\d{1,2}:\d{2}')
             THEN lpad(split_part("実施時間", '～', 2), 5, '0') END,
        NULLIF("実施時間", ''),
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    FROM {{ ref('raw_tsukuba_childcare_support') }}
    WHERE "種別" = '地域子育て支援拠点'

    UNION ALL

    SELECT
        'sirituyoutien', '公立', '幼稚園', "幼稚園名", NULL, "所在地", NULL,
        TRIM("JGD2011_10進_Y"), TRIM("JGD2011_10進_X"), NULL, NULL,
        NULLIF("電話番号", ''), NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULLIF("通園区域", ''), NULL, NULL, NULL, NULL
    FROM {{ ref('raw_tsukuba_public_kindergarten') }}
    WHERE NULLIF("幼稚園名", '') IS NOT NULL
)
SELECT
    '082201'                                          AS local_government_code,
    source_dataset,
    name,
    name_kana,
    ownership,
    facility_type,
    {{ tsukuba_address('address_raw') }}              AS full_address,
    '茨城県'                                          AS prefecture,
    'つくば市'                                        AS city,
    building_name,
    {{ tsukuba_coordinate('lat_raw', 'lon_raw', 'lat') }} AS latitude,
    {{ tsukuba_coordinate('lat_raw', 'lon_raw', 'lon') }} AS longitude,
    access,
    capacity,
    phone_number,
    fax_number,
    corporate_name,
    legal_entity_number,
    TRY_CAST(authorized_date AS DATE)                 AS authorized_date,
    age_range,
    school_bus,
    available_days,
    start_time,
    end_time,
    available_notes,
    saturday_start_time,
    saturday_end_time,
    temporary_care,
    attendance_area,
    url,
    notes
FROM unioned
