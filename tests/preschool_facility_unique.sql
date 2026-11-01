{# 子育て施設は 4 つの一覧をつないでいる。一覧どうしで同じ施設が載っていれば
   stg で 1 行に絞っているが、名称か住所の書き方が変わると絞れずに 2 行になる。
   同じ名称・所在地の行が 2 行以上あれば落とす #}
SELECT name, address, count(*) AS n
FROM {{ ref('mart_tsukuba_preschool') }}
GROUP BY name, address
HAVING count(*) > 1
