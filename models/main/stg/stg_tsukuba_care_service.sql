{{ config(materialized='view') }}

{# 1 行が事業所 × サービスの組。介護保険事業所番号は 10 桁だが、Excel の数値として
   保存されているせいで先頭の 0 が落ちている（872001813 は 0872001813）ので、数字だけの番号は 10 桁に戻す #}
SELECT
    '082201'                                          AS municipality_code,
    "No."                                             AS facility_id,
    "事業所名"                                        AS name,
    "サービスコード"                                  AS service_code,
    "サービス種類"                                    AS service_type,
    {{ tsukuba_address('"所在地"') }}                 AS address,
    '茨城県'                                          AS prefecture,
    'つくば市'                                        AS city,
    CASE WHEN regexp_full_match("郵便番号", '[0-9]+') THEN lpad("郵便番号", 7, '0')
         ELSE NULLIF("郵便番号", '') END              AS postal_code,
    NULLIF("電話番号", '')                           AS phone_number,
    NULLIF("FAX番号", '')                            AS fax_number,
    NULLIF("法人名", '')                             AS corporate_name,
    CASE WHEN regexp_full_match("介護保険事業所番号", '[0-9]+') THEN lpad("介護保険事業所番号", 10, '0')
         ELSE NULLIF("介護保険事業所番号", '') END    AS business_number,
    TRY_CAST("定員" AS INTEGER)                       AS capacity,
    COALESCE("介護予防" IN ('〇', '○'), false)       AS preventive_care,
    COALESCE("総合事業" IN ('〇', '○'), false)       AS comprehensive_service,
    NULLIF("圏域", '')                               AS service_area,
    TRY_CAST("指定年月日" AS DATE)                    AS designated_date,
    NULLIF("みなし区分", '')                         AS deemed_category
FROM {{ ref('raw_tsukuba_care_service') }}
