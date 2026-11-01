{{ config(materialized='table') }}

{# 公衆無線LANアクセスポイント一覧の CSV（CKAN k006_001）。
   pipelines/ods.py が UTF-8 に揃えて data/public_wireless_lan/ に置く。
   ファイル名は時点で変わる（public_wireless_lan202412.csv など）ので、名前では指さない #}
SELECT *
FROM read_csv(
    'data/public_wireless_lan/*.csv',
    header = true,
    all_varchar = true
)
