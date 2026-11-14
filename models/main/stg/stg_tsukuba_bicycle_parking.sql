{% set counts = ['capacity_regular_bicycle', 'capacity_regular_moped', 'capacity_regular_motorcycle',
                 'capacity_temporary_bicycle', 'capacity_temporary_moped', 'capacity_temporary_motorcycle'] %}
{% set fees = ['fee_regular_bicycle', 'fee_regular_moped', 'fee_regular_motorcycle',
               'fee_temporary_bicycle', 'fee_temporary_moped', 'fee_temporary_motorcycle'] %}

{# 工区に分かれた駐輪場は工区ごとに行があり、料金と台数は先頭の工区の行にだけ入っている。
   No ごとに 1 行にまとめ、工区（区画）と所在地は「;」でつなぐ。
   行の順はブックの中の順（「行」列）で決める。
   台数は「770台」「３台」のような書き方なので、全角数字を半角にして数にする。「-」は車種ごとの列では空にし、合計では 0 台として数える #}
WITH source AS (
    SELECT
        *,
        CAST("行" AS INTEGER) AS row_no,
        {{ tsukuba_address('"所在地"') }} AS address_full
    FROM {{ ref('raw_tsukuba_bicycle_parking') }}
    WHERE NULLIF("No", '') IS NOT NULL
),
{# 工区で所在地が同じものは 1 回だけ数え、ブックの中で先に出た順につなぐ #}
numbered AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY "No", address_full ORDER BY row_no) = 1 AS first_address
    FROM source
),
grouped AS (
    SELECT
        "No"                                                          AS facility_id,
        arg_min("TX駅", row_no)                                       AS nearest_station,
        arg_min("駐輪場名称", row_no)                                 AS name,
        string_agg(NULLIF("区画", ''), ';' ORDER BY row_no)           AS sections,
        string_agg(address_full, ';' ORDER BY row_no) FILTER (WHERE first_address) AS full_address,
        arg_min("駐車区分", row_no)                                   AS parking_category,
        arg_min("利用時間_平日", row_no)                              AS hours_weekday,
        arg_min("利用時間_土日祝日・12/29〜12/31・1/2〜1/3", row_no)                AS hours_holiday,
        arg_min("利用時間_元旦", row_no)                              AS hours_new_year,
        arg_min("駐車可能な車両_定期", row_no)                        AS vehicles_regular,
        arg_min("駐車可能な車両_一時", row_no)                        AS vehicles_temporary,
        arg_min("料金_定期_自転車", row_no)                           AS fee_regular_bicycle,
        arg_min("料金_定期_原付", row_no)                             AS fee_regular_moped,
        arg_min("料金_定期_自動二輪車", row_no)                       AS fee_regular_motorcycle,
        arg_min("料金_一時_自転車", row_no)                           AS fee_temporary_bicycle,
        arg_min("料金_一時_原付", row_no)                             AS fee_temporary_moped,
        arg_min("料金_一時_自動二輪車", row_no)                       AS fee_temporary_motorcycle,
        arg_min("供用台数_定期_自転車", row_no)                       AS capacity_regular_bicycle,
        arg_min("供用台数_定期_原付", row_no)                         AS capacity_regular_moped,
        arg_min("供用台数_定期_自動二輪車", row_no)                   AS capacity_regular_motorcycle,
        arg_min("供用台数_一時_自転車", row_no)                       AS capacity_temporary_bicycle,
        arg_min("供用台数_一時_原付", row_no)                         AS capacity_temporary_moped,
        arg_min("供用台数_一時_自動二輪車", row_no)                   AS capacity_temporary_motorcycle,
        min(row_no)                                                   AS first_row
    FROM numbered
    GROUP BY "No"
),
counted AS (
    SELECT
        * EXCLUDE (
            capacity_regular_bicycle, capacity_regular_moped, capacity_regular_motorcycle,
            capacity_temporary_bicycle, capacity_temporary_moped, capacity_temporary_motorcycle
        ),
        {% for c in counts %}
        TRY_CAST(regexp_replace(translate(NULLIF(NULLIF({{ c }}, ''), '-'), '０１２３４５６７８９', '0123456789'), '[台,]', '', 'g') AS INTEGER) AS {{ c }}{{ ',' if not loop.last }}
        {% endfor %}
    FROM grouped
)
SELECT
    '082201'                                          AS local_government_code,
    facility_id,
    name,
    sections,
    nearest_station,
    full_address,
    '茨城県'                                          AS prefecture,
    'つくば市'                                        AS city,
    parking_category,
    hours_weekday,
    hours_holiday,
    hours_new_year,
    vehicles_regular,
    vehicles_temporary,
    {% for f in fees %}
    NULLIF(NULLIF({{ f }}, ''), '-') AS {{ f }},
    {% endfor %}
    {% for c in counts %}
    {{ c }},
    {% endfor %}
    {# 台数の列がどれも空の駐輪場は合計も空にする #}
    CASE WHEN {% for c in counts %}{{ c }} IS NOT NULL{{ ' OR ' if not loop.last }}{% endfor %}
         THEN {% for c in counts %}COALESCE({{ c }}, 0){{ ' + ' if not loop.last }}{% endfor %}
    END                                               AS capacity,
    {# 料金のどれかに金額があれば有料、金額が無く「無料」だけなら無料 #}
    CASE WHEN {% for f in fees %}{{ f }} LIKE '%円%'{{ ' OR ' if not loop.last }}{% endfor %} THEN '有料'
         WHEN {% for f in fees %}{{ f }} = '無料'{{ ' OR ' if not loop.last }}{% endfor %} THEN '無料'
    END                                               AS fee_type
FROM counted
ORDER BY first_row
