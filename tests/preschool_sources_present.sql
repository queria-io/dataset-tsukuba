{# 子育て施設の元の一覧は 4 つ。どれかの行が 1 件も無ければ、上流の書き方が変わって
   stg の絞り込み（地域子育て支援拠点の種別など）から外れた可能性があるので落とす #}
SELECT expected.source_dataset
FROM (VALUES ('o019_001'), ('l012_001'), ('sirituyoutien'), ('o014_001')) AS expected(source_dataset)
WHERE NOT EXISTS (
    SELECT 1 FROM {{ ref('mart_tsukuba_preschool') }} AS p
    WHERE p.source_dataset = expected.source_dataset
)
