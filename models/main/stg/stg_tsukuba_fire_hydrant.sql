{{ config(materialized='view') }}

{# 緯度経度は日本の範囲に入るものだけを採る（tsukuba_coordinate）。
   元データには 0.0046, 0.01 のように明らかに座標でない値の行があり、
   そのまま地図に出すと緯度経度 0 の付近に点が立つ #}
SELECT
    '082201'                                          AS municipality_code,
    "支援系水利番号"                                  AS facility_id,
    "種別"                                            AS facility_type,
    {{ tsukuba_coordinate('"緯度"', '"経度"', 'lat') }} AS lat,
    {{ tsukuba_coordinate('"緯度"', '"経度"', 'lon') }} AS lon,
    TRY_CAST(REPLACE("管径", ',', '') AS INTEGER)                       AS diameter,
    TRY_CAST(REPLACE("容量", ',', '') AS DOUBLE)                     AS capacity,
    NULLIF("管轄署所", '')                           AS fire_station,
    NULLIF("公私別区分", '')                         AS ownership
FROM {{ ref('raw_tsukuba_fire_hydrant') }}
