{# 緯度経度は日本の範囲に入るものだけを採る（tsukuba_in_japan）。
   元データには 0.0046, 0.01 のように明らかに座標でない値の行があり、
   そのまま地図に出すと緯度経度 0 の付近に点が立つ #}
WITH source AS (
    SELECT
        *,
        TRY_CAST("緯度" AS DOUBLE) AS lat_raw,
        TRY_CAST("経度" AS DOUBLE) AS lon_raw
    FROM {{ ref('raw_tsukuba_fire_hydrant') }}
),
located AS (
    SELECT
        *,
        {{ tsukuba_in_japan('lat_raw', 'lon_raw') }} AS in_japan
    FROM source
)
SELECT
    '082201'                                          AS local_government_code,
    "支援系水利番号"                                  AS facility_id,
    "種別"                                            AS facility_type,
    CASE WHEN in_japan THEN lat_raw END               AS latitude,
    CASE WHEN in_japan THEN lon_raw END               AS longitude,
    TRY_CAST(REPLACE("管径", ',', '') AS INTEGER)     AS diameter,
    TRY_CAST(REPLACE("容量", ',', '') AS DOUBLE)      AS capacity,
    NULLIF("管轄署所", '')                           AS fire_station,
    NULLIF("公私別区分", '')                         AS ownership
FROM located
