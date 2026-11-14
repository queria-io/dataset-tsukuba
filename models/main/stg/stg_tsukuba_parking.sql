SELECT
    '082201'                                          AS local_government_code,
    "No"                                              AS facility_id,
    "駐輪場名称"                                      AS name,
    NULLIF("TX駅", '')                               AS nearest_station,
    {{ tsukuba_address('"所在地"') }}                 AS full_address,
    '茨城県'                                          AS prefecture,
    'つくば市'                                        AS city,
    NULLIF("駐車区分", '')                           AS parking_category,
    NULLIF("利用時間", '')                           AS available_notes,
    NULLIF("駐車可能な車両", '')                     AS vehicles,
    NULLIF("料金", '')                               AS fee_details,
    TRY_CAST("供用台数" AS INTEGER)                   AS capacity,
    NULLIF("備考", '')                               AS notes
FROM {{ ref('raw_tsukuba_parking') }}
WHERE NULLIF("No", '') IS NOT NULL
