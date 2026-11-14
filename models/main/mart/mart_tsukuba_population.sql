SELECT
    *,
    lg_code AS local_government_code
FROM {{ ref('stg_tsukuba_population') }}
