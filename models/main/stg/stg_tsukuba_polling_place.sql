{{ config(materialized='view') }}

{# 投票区番号が数値の行だけが投票所。各シート末尾の「計」の行を落とす。
   名称にはセル内の折り返しの改行が混ざっている（「市立福祉支援セン\nターやたべ」）ので消す。
   同じ折り返しは住所・投票区名のセルにも入りうるので、そちらも消す。
   所在地は市内の番地だけで書かれているので、都道府県と市を前に付ける。
   住所が空の行に「茨城県つくば市」だけが入らないよう、空は NULL のまま残す #}
SELECT
    '082201'                                          AS municipality_code,
    "投票区番号"                                      AS voting_district_number,
    REPLACE(REPLACE("投票所", chr(13), ''), chr(10), '') AS name,
    '茨城県つくば市'
        || NULLIF(REPLACE(REPLACE("投票所住所", chr(13), ''), chr(10), ''), '') AS address,
    '茨城県'                                          AS prefecture,
    'つくば市'                                        AS city,
    '投票所'                                          AS polling_place_type,
    REPLACE(REPLACE("投票区", chr(13), ''), chr(10), '') AS voting_district,
    NULLIF("対象地区", '')                           AS target_areas,
    "地区"                                            AS region
FROM {{ ref('raw_tsukuba_polling_place') }}
WHERE TRY_CAST("投票区番号" AS INTEGER) IS NOT NULL
