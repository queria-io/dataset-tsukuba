{# 市の一覧の住所は「つくば市」から、ときには町字から書かれている。
   定義書の連結表記は都道府県から書くので、足りない頭の部分を付ける。
   市の一覧に載っている施設は市内にあるので、付けるのは茨城県つくば市に限る #}
{% macro tsukuba_address(column) -%}
CASE
    WHEN NULLIF({{ column }}, '') IS NULL THEN NULL
    WHEN {{ column }} LIKE '茨城県%' THEN {{ column }}
    WHEN {{ column }} LIKE 'つくば市%' THEN '茨城県' || {{ column }}
    ELSE '茨城県つくば市' || {{ column }}
END
{%- endmacro %}

{# 緯度経度は日本の範囲（緯度 20〜46、経度 122〜154.5）に入るときだけ採る。
   part は 'lat' か 'lon' #}
{% macro tsukuba_coordinate(lat, lon, part) -%}
CASE WHEN TRY_CAST({{ lat }} AS DOUBLE) BETWEEN 20.0 AND 46.0
      AND TRY_CAST({{ lon }} AS DOUBLE) BETWEEN 122.0 AND 154.5
     THEN TRY_CAST({{ lat if part == 'lat' else lon }} AS DOUBLE) END
{%- endmacro %}
